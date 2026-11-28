"""Reproduce S29 candidate-media evidence, never padding missing sectors.

Standard library extraction; optional Capstone 5.0.9 produces the focused listing.
This is a research tool for the pinned image, not a general STX converter.
See docs/S29_ST_EFFECT_RESEARCH.md for provenance and interpretation limits.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = ROOT / 'assets/documentation/s29-st-research/alternate-reality-city-st-v2-candidate.zip'
ZIP_SHA256 = '1ee57ea2362345c6b6389f4ff5c813ea1c4ca311311d6d503ea7d507368a9000'
IMAGE_SHA256 = 'e8088c06a27e87369aaabc714a22b1964787c0c344134a5c5fde5931302eca56'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_sectors(image):
    assert digest(image) == IMAGE_SHA256, 'Different image: research assumptions must be reviewed'
    assert image[:4] == b'RSY\0'
    sectors = {}
    track_offset = 16
    for _ in range(image[10]):
        block_size, fuzzy_size, count, _, _, _, _ = struct.unpack_from('<IIHHHBB', image, track_offset)
        block_end = track_offset + block_size
        assert block_end <= len(image)
        data_base = track_offset + 16 + count * 16 + fuzzy_size
        for index in range(count):
            data_offset, _, _, track, head, sector, size_code, _, status, _ = struct.unpack_from(
                '<IHHBBBBHBB', image, track_offset + 16 + index * 16)
            if head != 0 or track >= 80 or not 1 <= sector <= 9 or size_code != 2:
                continue
            start = data_base + data_offset
            assert start + 512 <= block_end
            assert status == 0, f'STX sector error: {track}/{sector}'
            logical_sector = track * 9 + sector - 1
            assert logical_sector not in sectors, 'Ambiguous duplicate sector'
            sectors[logical_sector] = image[start:start + 512]
        track_offset = block_end
    assert track_offset == len(image)
    return sectors


def checksum(data, seed):
    # Loader $c5c: CRC-CCITT polynomial, followed by byte swap, no final XOR.
    for value in data:
        seed ^= value << 8
        for _ in range(8):
            seed = ((seed << 1) ^ (0x1021 if seed & 0x8000 else 0)) & 0xffff
    return ((seed << 8) | (seed >> 8)) & 0xffff


def decoded_sector(sectors, logical_sector, seed):
    raw = sectors[logical_sector]  # Missing data is an error, never zero-filled.
    decoded = bytearray()
    previous = 0
    for value in raw:
        previous ^= value  # Loader $c3e: previous DECODED byte.
        decoded.append(previous)
    stored_checksum = int.from_bytes(decoded[510:], 'big')
    decoded[510:] = bytes((logical_sector // 9, logical_sector % 9 + 1))
    assert checksum(decoded, seed) == stored_checksum, f'Checksum failure: sector {logical_sector}'
    return decoded[:510]


def read_record(sectors, track, sector, size, seed):
    start = track * 9 + sector - 1
    used = list(range(start, start + (size + 509) // 510))
    return b''.join(decoded_sector(sectors, index, seed) for index in used)[:size], used


def focused_disassembly(module):
    from capstone import Cs, CS_ARCH_M68K, CS_MODE_BIG_ENDIAN, CS_MODE_M68K_000
    decoder = Cs(CS_ARCH_M68K, CS_MODE_BIG_ENDIAN | CS_MODE_M68K_000)
    lines = ['; Derived candidate evidence. Addresses are module-05 offsets, not runtime addresses.',
             '; Inline dispatch words after jsr (a5) are data, not instructions.']
    # Exclude operation-pointer table $256c..$2579 from instruction decoding.
    for begin, end in [(0x2434, 0x256c), (0x257a, 0x267a), (0x283c, 0x2b2c)]:
        position = begin
        while position < end:
            instruction = next(decoder.disasm(module[position:end], position, count=1), None)
            assert instruction is not None, f'Cannot decode {position:x}'
            line = f'{position:04x}: {instruction.bytes.hex():20} {instruction.mnemonic} {instruction.op_str}'
            position += instruction.size
            if instruction.bytes == b'\x4e\x95':
                line += f' [dispatch ${int.from_bytes(module[position:position + 2], "big"):04x}]'
                position += 2
            lines.append(line)
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disassemble', action='store_true')
    args = parser.parse_args()
    assert digest(ARCHIVE.read_bytes()) == ZIP_SHA256
    with zipfile.ZipFile(ARCHIVE) as archive:
        assert len(archive.namelist()) == 1
        image = archive.read(archive.namelist()[0])
    sectors = read_sectors(image)
    # Loader $6f0..$714 sets directory seed $0101, track 4, sector 5, size $05fa.
    directory, directory_sectors = read_record(sectors, 4, 5, 0x5fa, 0x101)
    output = ROOT / 'tools/reference/s29-verified'
    output.mkdir(parents=True, exist_ok=True)
    records = []
    # Records 1/2 describe the resident bootstrap, loaded raw by AUTO/AR.PRG.
    # They do not use the encoded-sector path used by subsequent overlays.
    for index in range(3, 100):
        seed, track, sector, size = struct.unpack_from('>HBBI', directory, index * 8)
        if size == 0:
            continue
        assert 0 <= track < 80 and 1 <= sector <= 9
        data, used = read_record(sectors, track, sector, size, seed)
        (output / f'module-{index:02d}.bin').write_bytes(data)
        records.append(dict(index=index, size=size, seed=seed, sectors=used, sha256=digest(data)))
    module = (output / 'module-05.bin').read_bytes()
    if args.disassemble:
        (output / 'effect-routines.asm').write_text(focused_disassembly(module), encoding='utf-8')
    bootstrap = b''.join(sectors[index] for index in range(43, 51))
    assert b'V2.0' in bootstrap, 'Version banner missing'
    report = dict(archive_sha256=ZIP_SHA256, image_sha256=IMAGE_SHA256,
                  missing_sectors=[index for index in range(720) if index not in sectors],
                  directory_sectors=directory_sectors, records=records,
                  note='All listed record sectors pass the original loader checksum. No emulator run.')
    (output / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(f'Verified {len(records)} records; module 05 SHA-256 {digest(module)}')
    print(f'Missing sectors (not used by these records): {report["missing_sectors"]}')


if __name__ == '__main__':
    main()
