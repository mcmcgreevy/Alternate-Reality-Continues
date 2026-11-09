"""Decode ardungeon's data-only map segments; refuse unsupported syntax.

Every assembled payload must match the upstream .sha1 before any output is written.
This is a data reader, not a port of the game's assembly implementation.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

FILES = ['21-s011', '21-s052', '21-s093', '21-s134', '21-s175', '21-s216', '21-s257']
REV = '823aaf1bc3b797070cbb0f79223a06b02491e792'


def tokens(text):
    return [x.strip() for x in re.split(r',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)', text)]


def number(text, labels):
    text = text.strip()
    if text.startswith("'") and text.endswith("'") and len(text) == 3:
        return ord(text[1])
    if text in labels:
        return labels[text]
    return int(text[1:], 16) if text.startswith('$') else int(text)


def assemble(path):
    lines = []
    repeat = None
    for raw in path.read_text(encoding='latin-1').splitlines():
        quoted = False
        stop = len(raw)
        for i, char in enumerate(raw):
            if char == '"': quoted = not quoted
            if char == ';' and not quoted:
                stop = i
                break
        line = raw[:stop].strip()
        if not line or line.lower().startswith('.include') or line.upper() == '.END':
            continue
        if line.upper().startswith('.REPEAT'):
            if repeat is not None: raise ValueError('Nested repeat unsupported')
            repeat = (int(line.split()[1]), [])
        elif line.upper() == '.ENDREPEAT':
            lines.extend(repeat[1] * repeat[0])
            repeat = None
        elif repeat is not None:
            repeat[1].append(line)
        else:
            lines.append(line)
    labels = {}
    for pass_index in range(2):
        out = bytearray()
        for line in lines:
            if ':' in line.split('"')[0]:
                label, line = line.split(':', 1)
                labels[label.strip()] = 0xAC00 + len(out)
                line = line.strip()
            if not line: continue
            op, args = line.split(None, 1)
            op = op.upper()
            if op == '.BYTE':
                for token in tokens(args):
                    if token.startswith('"'):
                        out.extend(token[1:-1].encode('latin-1'))
                    else:
                        out.append(number(token, labels))
            elif op == '.WORD':
                value = 0 if pass_index == 0 else number(args, labels)
                out.extend(value.to_bytes(2, 'little'))
            elif op == 'HBSTR':
                value = bytearray(args.strip()[1:-1].encode('latin-1'))
                value[-1] |= 128
                out.extend(value)
            elif op == '.RES':
                count, value = tokens(args)
                out.extend([number(value, labels)] * number(count, labels))
            else:
                raise ValueError(f'{path.name}: unsupported directive {line}')
    expected = path.with_suffix('.sha1').read_text().split()[0]
    actual = hashlib.sha1(out).hexdigest()
    if expected != actual:
        raise ValueError(f'{path.name}: SHA1 mismatch {actual} != {expected}; {len(out)} bytes')
    if len(out) != 5120:
        raise ValueError(f'{path.name}: unexpected payload size {len(out)}')
    return bytes(out)


def decode(path):
    raw = assemble(path)
    # Original runtime sub_3531 indexes four-byte records at $B000.
    # Two nibbles each in bytes 0/1; retain them without collapsing one-way edges.
    cells = []
    for y in range(32):
        row = []
        for x in range(32):
            record = list(raw[1024 + (y * 32 + x) * 4:1028 + (y * 32 + x) * 4])
            row.append({'raw': record, 'edges': [record[0] & 15, record[0] >> 4,
                                                record[1] & 15, record[1] >> 4]})
        cells.append(row)
    return {'segment': raw[0], 'source_file': path.name,
            'source_sha1': hashlib.sha1(raw).hexdigest(), 'payload_bytes': len(raw),
            'cells': cells}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('checkout', type=Path)
    parser.add_argument('--output', type=Path, default=Path('tools/reference/dungeon-decoded.json'))
    args = parser.parse_args()
    segments = [decode(args.checkout / (stem + '.asm')) for stem in FILES]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({'revision': REV, 'segments': segments}, separators=(',', ':')) + '\n')
    print('Seven 5120-byte payloads match upstream SHA1; decoded 7168 raw cell records.')
