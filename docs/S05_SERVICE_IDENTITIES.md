# S05 — Service identities and entry encodings

2026-11-22. Static candidate-executable research; no gameplay changes or executed service tests. Sources remain the cataloged ST v2.0 candidate and canonical Kroah archive. Read with [map data evidence](S05_ST_MAP_DATA.md).

## All 79 service-code faces reconciled at the encoding level

Every current face encoded 27–33 has candidate boundary nibble 3. Independently inspecting the destination cell's category yields the exact correspondence below, with no exceptions. The [79-row ledger](s05/service-entry-correspondence.csv) records each approached face, destination coordinate, category, marker and derived service index.

| Current edge | Candidate edge | Destination type | Service | Faces |
| --- | --- | --- | --- | ---: |
| 27 | 3 | 4 | Shop | 32 |
| 28 | 3 | 1 | Inn | 8 |
| 29 | 3 | 2 | Tavern | 22 |
| 30 | 3 | 5 | Smithy | 6 |
| 31 | 3 | 3 | Bank | 5 |
| 32 | 3 | 8 | Guild | 4 |
| 33 | 3 | 7 | Healer | 2 |

This supports separating door geometry from service selection. It does not justify replacing current codes globally: the current movement implementation blocks most service codes and only special-cases code 29 into Tail of the Dog. Replacing all 79 with 3 would change accessibility before services are ready. Keep that integration with each location/shared-service dependency.

These 79 rows are now classified as service-encoding correspondence rather than presumed geometry defects. The raw comparison still contains 256 differences, of which 177 are outside this group. The 16 priority ordinary-code faces are a subset of those 177, not an additional count.

## Service index evidence

All offsets below are within the named decoded module, not absolute runtime addresses. Focused sequential disassembly starts at each module's entry offset `$000a` or the specific routine shown, skips inline dispatch words after `jsr (a5)`, and does not treat jump-table words as instructions.

| Candidate routine | Marker handling | Corroborating category/marker range |
| --- | --- | --- |
| Module 08 `$0042..$0052` | Reads current marker from `a5-$253e`; stores marker and twice marker as indices; indexes a word table. | Inn type 1: markers 0–6. |
| Module 09 `$002a..$0038` | Subtracts 7; stores index and doubled index. | Tavern type 2: markers 7–20. |
| Module 10 `$0030..$005e` | Subtracts `$15` (21); derives index, doubled index, 24-byte and 34-byte offsets. | Bank type 3: markers 21–23. |
| Module 11 `$0026..$0036` | Subtracts `$18` (24); stores index and doubled index. | Shop type 4: markers 24–37 present; canonical absent marker 38 would be index 14 if dispatched, not evidence it exists. |
| Module 12 `$0026..$0036` | Subtracts `$27` (39); stores index and doubled index. | Smithy type 5: markers 39–42. |
| Module 14 `$00e4..$0100` | Marker parity selects byte offset 0 or 8; marker plus hour parity selects the following branch. | Healer type 7: marker 53 selects offset 8, marker 54 offset 0. Do not assume the healer record order equals marker order. |
| Module 15 `$0022..$0032` | Subtracts `$37` (55); stores index and doubled index. | Guild type 8: markers 55–66. |

These routine signatures and data ranges corroborate the service interpretation. The complete resident dispatch-to-overlay loading chain and every downstream table/state use have not been traced; do not treat this as full service behavior validation. Kroah's Technical Notes explicitly identifies `a5+$1846` as location type, while module 05 uses it to select category-dependent dispatch entries, as recorded in the previous report.

All candidate cell flag values are 0,32,64 or96 in the upper three bits. None sets bit7, so the previously observed negative-byte skip in the category update does not occur for this static map payload. Other high bits remain uninterpreted; do not discard them or presume they are service IDs.

## Consequences for location stories

- Category plus marker is required for interpretation. The Arena duplicates with markers 53/54/57 have scenario type 6, whereas actual healers use type 7 and guild marker 57 uses type 8. A marker-only lookup would wrongly activate services at reused scenario labels.
- The two Da Place! occurrences are type 4 / marker 37. They feed the same computed shop index 13 in the inspected routine. Keep separate spatial occurrence IDs while investigating which original shop state is shared; do not assume separate persistence per occurrence or silently rename one to Trade Winds. This establishes index equality, not the scope of every shared state field.
- Duplicate guild areas use type 8 with marker 58/65, yielding the same computed indices as the accessible occurrences. Their documented inaccessibility remains a separate constraint; category/index validity does not authorize opening them.
- Unlabeled raw60/raw61 cells retain markers 44/45 but type 0. Module 13's special-location switch at `$008c..$00a4` has entries for marker values 43 onward, with 43/44/45 all targeting `$00be`. That is a dormant handler possibility, not proof these type-0 cells invoke it. Do not activate either gate on this basis.

## Remaining verification

Trace the resident category-to-overlay bindings and downstream state indexing, especially Da Place! shared state and healer record order. Continue the 177 non-service raw differences and full canonical image classification. Preserve ordinary door geometry, category, marker and occurrence as distinct fields in any future design; a proposed data schema must wait for the implementation hold and exact migration scope.

No new source was downloaded. Existing extractor-verified module files and the map/cell ledgers were read without changing source documents. The 79-row output was checked for unique faces, candidate nibble 3 and exact destination-type correspondence. No gameplay code, map data, save files or test build changed.
