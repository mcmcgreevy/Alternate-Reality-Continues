"""Rebuild the bounded S05 identity inventory; never mutate map/source payloads.

Spatial components describe equal current location codes, not proven ST entrances.
Canonical labels, candidate runtime identity and implementation ownership stay separate.
"""
from pathlib import Path
import csv
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/s05'


def read_json(path):
    raw = (ROOT / path).read_bytes()
    try:
        return json.loads(raw.decode('utf-8-sig'))
    except UnicodeDecodeError:
        return json.loads(raw.decode('cp1252'))


def rows(name):
    with (OUT / name).open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream))


def write_csv(name, records):
    with (OUT / name).open('w', encoding='utf-8', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(records[0]))
        writer.writeheader()
        writer.writerows(records)


def positions(text):
    return {tuple(map(int, cell.split(','))) for cell in text.split(';') if cell}


def cell_text(cells):
    return ';'.join(f'{x},{y}' for x, y in sorted(cells))


def main():
    plan = read_json('docs/LOCATION_STORY_PLAN.json')
    index = read_json('docs/GITHUB_BACKLOG_INDEX.json')['issues']
    live = {i['number']: i for i in read_json('tools/reference/s05-live-issues.json')}
    occurrence_owner = {(str(i['marker']), str(i['component'])): i['key']
                        for i in plan if 'marker' in i}
    legends = rows('st-legend.csv')
    occurrences = rows('st-occurrences.csv')
    labels = rows('st-labeled-cells.csv')
    candidate = {(int(r['x']), int(r['y'])): r for r in rows('candidate-st-cells.csv')}
    world = read_json('data/maps/city.json')['cells']
    world = {tuple(map(int, key.split(','))): value for key, value in world.items()}
    canonical = {(int(r['x']), int(r['y'])): r['st_marker'] for r in labels}
    assert len(world) == len(candidate) == 4096
    assert set(world) == set(candidate)
    assert all(world[cell]['location'] == int(candidate[cell]['current_raw_location']) for cell in world)
    assert len(legends) == 67 and len(occurrences) == 73 and len(canonical) == 463
    assert len({r['marker'] for r in occurrences}) == 66
    assert {r['marker'] for r in legends} - {r['marker'] for r in occurrences} == {'(38)'}
    assert len(occurrence_owner) == 73 and len(plan) == 75
    covered = set()
    owner_by_cell = {}
    occurrence_records = []
    for occurrence in occurrences:
        cells = positions(occurrence['cells'])
        assert len(cells) == int(occurrence['cell_count']) and not covered.intersection(cells)
        covered.update(cells)
        owner = occurrence_owner[(occurrence['marker'], occurrence['component'])]
        for cell in cells:
            assert canonical[cell] == occurrence['marker'] == candidate[cell]['candidate_marker']
            owner_by_cell[cell] = owner
        occurrence_records.append(dict(identity=f"st-marker-{occurrence['marker']}-occurrence-{occurrence['component']}",
            marker=occurrence['marker'], component=occurrence['component'], cells=cell_text(cells),
            owner=owner, issue=index[owner]['number'], source='world.html Map legend; Map.png; st-labeled-cells.csv',
            confidence='canonical_label_and_candidate_marker_agree; entrance_behavior_not_certified'))
    assert covered == set(canonical)
    for entry in plan:
        issue = live[index[entry['key']]['number']]
        assert issue['title'].startswith('[' + entry['key'] + ']')
        assert issue['state'] == 'OPEN', (entry['key'], issue['state'])

    # Unnumbered approaches retain explicit owners, without promoting ARX names
    # to canonical identity. The actual scenario implementation stays with them.
    unlabeled_owner = {9: 'S104', 10: 'S103', 11: 'S105', 60: 'S106',
                       61: 'S107', 64: 'S79', 67: 'S77', 90: 'S80'}
    pending = {cell for cell, data in world.items() if data['location'] >= 16 or data['location'] in (9, 10, 11)}
    components = []
    while pending:
        start = min(pending)
        raw = world[start]['location']
        cells, queue = set(), [start]
        while queue:
            cell = queue.pop()
            if cell not in pending or world[cell]['location'] != raw:
                continue
            pending.remove(cell)
            cells.add(cell)
            x, y = cell
            queue.extend([(x-1, y), (x+1, y), (x, y-1), (x, y+1)])
        components.append((raw, cells))
    assert len(components) == 81
    records, owners_used = [], set()
    for raw, cells in sorted(components, key=lambda item: (item[0], min(item[1]))):
        owners = {owner_by_cell[cell] for cell in cells if cell in owner_by_cell}
        if not owners:
            owners = {unlabeled_owner[raw]}
        assert len(owners) == 1, (raw, owners)
        owner = owners.pop()
        owners_used.add(owner)
        marker_values = sorted({candidate[cell]['candidate_marker'] for cell in cells}, key=int)
        types = sorted({candidate[cell]['candidate_type_low5'] for cell in cells}, key=int)
        # Resident array indices are candidate evidence, not implemented save IDs.
        state = []
        for category, marker in sorted({(int(candidate[c]['candidate_type_low5']), int(candidate[c]['candidate_marker'])) for c in cells}):
            offsets = {1: 0, 2: 7, 3: 21, 4: 24, 5: 39, 8: 55}
            if category in offsets:
                state.append(f'candidate-category-{category}-index-{marker-offsets[category]}')
            elif category == 7:
                state.append(f'candidate-healer-offset-{8 if marker % 2 else 0}')
            else:
                state.append('not_a_verified_service_state')
        note = 'candidate_index_only; downstream_state_and_access_require_owner_acceptance'
        if types == ['4'] and marker_values == ['37']:
            note = 'shared_Da_Place_friendship_visit_day_frequency_refresh_hour_six_stock_words; other_fields_unverified'
        if raw in unlabeled_owner:
            note += '; unlabeled_approaches_require_owner_evidence_not_ARX_identity_assumption'
        if owner in ['S84', 'S87', 'S91', 'S93', 'S101']:
            note += '; documented_inaccessible_duplicate_not_service_activation'
        if owner == 'S49':
            note += '; approved_Tail_of_the_Dog_Grimthorn_music_adaptation'
        if owner in ['S80', 'S81']:
            note += '; north_cross_edition_travel_approved; southeast_not_authorized'
        records.append(dict(identity=f'current-raw-{raw}-anchor-{min(cells)[0]}-{min(cells)[1]}',
            raw_location=raw, cells=cell_text(cells), cell_count=len(cells),
            canonical_markers=';'.join(sorted({canonical[c] for c in cells if c in canonical}, key=int)),
            candidate_markers=';'.join(marker_values), candidate_categories=';'.join(types),
            candidate_state_identity=';'.join(state), owner=owner, issue=index[owner]['number'],
            source='world.html Map/Remarks; Map.png; candidate-st-cells.csv; S05_CATEGORY_DISPATCH.md',
            confidence='label_inventory_reconciled; candidate_runtime_identity; access_not_certified',
            remaining_evidence_owner=f'{owner}; S109 classification; S111 held_passages_if_applicable', notes=note))
    assert owners_used == {entry['key'] for entry in plan}
    assert len({record['identity'] for record in records}) == len(records)
    assert len({record['identity'] for record in occurrence_records}) == len(occurrence_records)
    comparison = rows('location-comparison.csv')
    assert sorted((int(r['raw_location']), int(r['current_cell_count'])) for r in comparison) == sorted((r['raw_location'], r['cell_count']) for r in records)
    assert sum(int(r['perimeter_faces']) for r in rows('current-location-access.csv')) == 710
    legend_records = []
    for legend in legends:
        matches = [r for r in occurrence_records if r['marker'] == legend['marker']]
        legend_records.append(dict(marker=legend['marker'], source_name=legend['source_name'], category=legend['category'],
            occurrence_count=len(matches), owners=';'.join(r['owner'] for r in matches),
            disposition='inventoried_occurrences' if matches else 'Trade_Winds_absent_no_implementation_story',
            source=legend['source_locator']))
    write_csv('identity-inventory.csv', records)
    write_csv('identity-occurrences.csv', occurrence_records)
    write_csv('identity-legend-coverage.csv', legend_records)
    inputs = ['data/maps/city.json', 'assets/documentation/kroah-city-st-v2/Map.png',
              'assets/documentation/kroah-city-st-v2/world.html', 'docs/s05/candidate-st-cells.csv',
              'docs/s05/st-occurrences.csv', 'docs/s05/st-labeled-cells.csv', 'docs/s05/st-legend.csv']
    report = dict(legend_entries=67, observed_markers=66, numbered_cells=463, labeled_components=73,
        current_components=81, perimeter_faces=710, location_owners=75, live_issue_links_verified=75,
        missing_owners=[], duplicate_identities=[],
        legacy_inventory_note='current-location-occurrences.csv is historical 78-component evidence; identity-inventory.csv includes the three gate components',
        limitations='Inventory acceptance only; candidate indices do not prove all state fields or entrance behavior.',
        inputs={name: hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in inputs})
    (OUT/'identity-audit-results.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
