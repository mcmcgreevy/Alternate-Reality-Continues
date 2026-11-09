"""Build the original-map milestone from pinned sources. No ARX code is ported."""
import hashlib
import json
import re
from collections import deque
from pathlib import Path
from import_dungeon_maps import assemble, REV

ROOT = Path(__file__).resolve().parents[1]
REF = ROOT / 'tools/reference'
OUT = ROOT / 'data/maps'
DIRECTIONS = [(0, -1), (1, 0), (0, 1), (-1, 0)]


def parse_arx(path):
    result = {}
    for block in path.read_text().split('# Map Cell Item: ')[1:]:
        head, *lines = block.splitlines()
        match = re.match(r'(\d+),(\d+)', head)
        xy = tuple(map(int, match.groups()))
        record = {key: int(value) for key, value in re.findall(r'^(.+?) = (\d+)', '\n'.join(lines), re.M)}
        result[xy] = record
    if len(result) != 4096: raise ValueError('Expected full 64x64 source map')
    return result


def path_between(cells, start, end):
    queue = deque([start]); parents = {start: None}
    while queue:
        p = queue.popleft()
        if p == end: break
        for d, (dx, dy) in enumerate(DIRECTIONS):
            n = p[0] + dx, p[1] + dy
            if n in cells and n not in parents and cells[p]['edges'][d] in range(8):
                parents[n] = p; queue.append(n)
    if end not in parents: raise ValueError(f'No route from {start} to {end}')
    path = []; p = end
    while p is not None: path.append(list(p)); p = parents[p]
    return path[::-1]


def build():
    city_file = REF / 'arx/data/map/cityCells.txt'
    city_raw = parse_arx(city_file)
    city = {xy: {'edges': [r[d + ' wall'] for d in ['North', 'East', 'South', 'West']],
                 'location': r['Location'], 'special': r['Special']} for xy, r in city_raw.items()}
    source = REF / ('ardungeon-' + REV) / '21-s052.asm'
    raw = assemble(source)
    dungeon = {}
    for y in range(32):
        for x in range(32):
            a, b, location, special = raw[1024 + (y * 32 + x) * 4:1028 + (y * 32 + x) * 4]
            dungeon[x + 32, y] = {'edges': [a & 15, a >> 4, b & 15, b >> 4],
                                    'location': location, 'special': special}
    # Independent data cross-check: ARX altered just the arrival's east edge.
    comparison = parse_arx(REF / 'arx/data/map/dungeon1Cells.txt')
    differences = []
    for xy, cell in dungeon.items():
        other = [comparison[xy][d + ' wall'] for d in ['North', 'East', 'South', 'West']]
        if other != cell['edges']: differences.append([list(xy), cell['edges'], other])
    assert differences == [[[49, 3], [13, 13, 13, 1], [13, 3, 13, 1]]], differences
    OUT.mkdir(parents=True, exist_ok=True)
    for name, cells, origin, size in [('city', city, [0, 0], [64, 64]), ('dungeon', dungeon, [32, 0], [32, 32])]:
        payload = {'schema': 1, 'id': name, 'origin': origin, 'size': size,
                   'cells': {f'{x},{y}': c for (x, y), c in cells.items()}}
        (OUT / (name + '.json')).write_text(json.dumps(payload, separators=(',', ':')) + '\n')
    # Only the geometry is imported. Original events and economies are not guessed.
    route = {'tavern': [20, 1], 'city_entrance_front': [49, 3], 'city_entrance_door': [50, 3],
             'dungeon_arrival': [49, 3], 'dungeon_facing': 3,
             'outward': path_between(city, (20, 1), (49, 3)),
             'return': path_between(city, (49, 3), (20, 1)),
             'source_revision': REV, 'city_source_sha256': hashlib.sha256(city_file.read_bytes()).hexdigest(),
             'dungeon_source_sha1': hashlib.sha1(raw).hexdigest(),
             'dungeon_crosscheck_differences': differences,
             'city_status': 'ARX geometry; milestone route cross-checked against 8-bit handbook map; other districts provisional',
             'dungeon_status': 'original NE segment, checksum verified; events and other segments not enabled',
             'tavern_name': 'The Tavern',
             'tavern_name_source': '8-bit handbook printed page 7; ARX labels the same cell Lost Oasis'}
    (OUT / 'route.json').write_text(json.dumps(route, indent=2) + '\n')
    print(f"Built City and original Dungeon NE: {len(city)} + {len(dungeon)} cells.")
    print(f"Outward: {len(route['outward'])-1} steps; return: {len(route['return'])-1} steps.")
    print('Dungeon cross-check: 1023 identical cells; original arrival east wall retained.')


if __name__ == '__main__': build()
