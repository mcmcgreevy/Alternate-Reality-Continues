"""Emit focused timing listings from already checksum-verified S29 modules.

Run extract_s29_st_evidence.py first. Capstone 5.0.9 is a research dependency.
Listings are derived analysis, never modifications of the archived source.
"""
import hashlib
import json

from capstone import Cs, CS_ARCH_M68K, CS_MODE_BIG_ENDIAN, CS_MODE_M68K_000
from extract_s29_st_evidence import ROOT, ZIP_SHA256, IMAGE_SHA256

DIRECTORY = ROOT / 'tools/reference/s29-verified'
RANGES = {
    5: [(0x84, 0x92), (0x21c, 0x234), (0x38e, 0x3b6), (0xb86, 0xb92),
        (0x1570, 0x159e), (0x1628, 0x16ae), (0x2434, 0x256c),
        (0x257a, 0x260c), (0x261c, 0x267a), (0x267a, 0x26ae)],
    8: [(0x3ea, 0x44c), (0x54e, 0x59c)],
    9: [(0x4a6, 0x4f4)],
    10: [(0x794, 0x7e2)],
    15: [(0x190, 0x1be)],
}


def main():
    manifest = json.loads((DIRECTORY / 'manifest.json').read_text())
    assert manifest['archive_sha256'] == ZIP_SHA256
    assert manifest['image_sha256'] == IMAGE_SHA256
    hashes = {r['index']: r['sha256'] for r in manifest['records']}
    decoder = Cs(CS_ARCH_M68K, CS_MODE_BIG_ENDIAN | CS_MODE_M68K_000)
    lines = ['; Module-relative offsets. Inline jsr (a5) dispatch words are data.']
    for module, ranges in RANGES.items():
        data = (DIRECTORY / f'module-{module:02d}.bin').read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        assert digest == hashes[module]
        lines.append(f'; MODULE {module:02d} SHA-256 {digest}')
        for begin, end in ranges:
            position = begin
            while position < end:
                instruction = next(decoder.disasm(data[position:end], position, count=1), None)
                assert instruction is not None, (module, hex(position))
                line = f'{module:02d}:${position:04x} {instruction.bytes.hex():20} {instruction.mnemonic} {instruction.op_str}'
                position += instruction.size
                if instruction.bytes == b'\x4e\x95':
                    line += f' [dispatch ${data[position:position+2].hex()}]'
                    position += 2
                lines.append(line)
            assert position == end
    path = DIRECTORY / 's32-timing-routines.asm'
    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(f'Verified {len(RANGES)} module hashes; timing listing: {path}')


if __name__ == '__main__':
    main()
