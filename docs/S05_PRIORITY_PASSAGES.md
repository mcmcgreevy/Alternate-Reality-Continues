# S05 — Priority passage review

2026-11-22. Research and proposed scope only; no game changes, original-code probes or playtest. Builds on [candidate map evidence](S05_ST_MAP_DATA.md).

## Sixteen faces, twelve distinct boundaries

Reviewed all 16 ordinary-code differences crossing the candidate movement threshold. The [row-level ledger](s05/priority-passage-review.csv) preserves every direction, evidence classification and exact current save-door key. The [annotated contact sheet](s05/priority-face-review.png) contains nearest-neighbor crops from unchanged Kroah Map.png; red boxes identify the source cell, labels give coordinate/direction/current-to-candidate values. It is derived analysis, not a new historical source. Outer-map crops are clamped inside the image; they cannot show an outside cell.

| Group | Directed faces | Finding and proposed disposition |
| --- | ---: | --- |
| Three missing doorways | 6 | Image visibly shows doors between (10,30)–(10,31), (11,31)–(12,31), and (10,32)–(11,32). Both candidate faces are 3, both current faces 13. Evidence supports a bounded future correction from walls to doors, after the playtest hold. This does not establish the original E/open interaction. |
| Wall pair | 2 | (26,34) south and (26,35) north have a continuous wall line in the canonical crop; both candidate faces are 13, current faces 5. Candidate closure scope, subject to the save/route policy below. |
| Arena directionality | 3 | (6,7) east, (16,12) east and (16,12) west are candidate 14 with opposite faces 3. The image shows door-like boundaries, not a reliable indication of which side blocks. Current faces are 3 in both directions. Keep these out of the simple doorway patch until original directional behavior is reconciled. |
| One asymmetric current face | 1 | (34,46) west: current 5, candidate 13; the opposite face is already 13 in both. This visual pass does not resolve the canonical face confidently. Hold, rather than inferring confirmation from the opposite side. |
| Outer-map faces | 4 | (14,0) north, (15,0) north, (0,49) west, (12,63) south: current 5, candidate 13. Current movement checks that a destination cell exists first, so these do not currently permit leaving the map. No playable crossing fix established; do not invent wraparound. |

This is eight faces with visually corroborated proposed geometry corrections, three requiring directionality reconciliation, one visually unresolved face, and four non-traversable outer edges. It is not sixteen confirmed gameplay bugs.

## What original movement establishes so far

The previously inspected candidate routine at module-05 `$1058..$10a4` reads the approached face's nibble. Values >=7 restore the partial coordinate and do not advance the integer coordinate on that branch. Values below 7 proceed, with separate feedback setup for 1–4 and 5–6. Therefore the Arena's 14/3 pairs are meaningful directional data, not grounds to convert both faces to doors. This static branch trace is still short of a full original-game access test or proof of all surrounding input/collision handling.

The remake stores opened doors by direction and checks that direction's current boundary support before moving. Original nibble equality and remake E-to-open semantics remain separate questions.

## Save and route impact investigation

A temporary in-memory graph substituted all 16 candidate values while retaining current movement eligibility for every other face. It did not modify the map file. Like the earlier access inventory, it assumes supported doors can be examined and opened and ignores UI restrictions, elapsed time and chapter transitions.

- Reachable cells from (39,34): 3267 before, 3287 after; 20 gained, none lost.
- Cells with a directed path back to (39,34): 3790 before, 3810 after; 20 gained, none lost.
- These aggregate results cover the hypothetical 16-face set, not every possible smaller patch. Recompute for the exact correction set before implementation.

The 20 newly reachable cells are (7,32), (8,28), (8,29), (8,30), (8,32), (9,28), (9,29), (9,32), (10,29), (10,30), (10,32), (10,33), (11,29), (11,33), (12,31), (12,33), (13,31), (14,31), (14,32), (14,33). This demonstrates why the three missing doors matter; it is not an executed route test.

Current `_validated_save` checks that the saved cell exists, not that it has a return route. It checks that door values are booleans but does not validate each key against map geometry. Thus a map update cannot rely on existing save validation to detect stranded characters or obsolete door state.

Proposed implementation policy to finalize with the exact patch:

1. Preserve saved coordinates: these proposed changes remove no cells. Verify reachability and return routes for affected positions before deciding migration is unnecessary; no silent teleport.
2. Preserve unrelated door keys. Explicitly retire only keys for faces deliberately changed from examinable passage to wall, using the ledger's exact keys and a versioned migration policy. Existing movement already blocks a wall even if its old key remains true; stale keys must not be mistaken for permission to traverse.
3. Newly added doors should start closed unless an approved migration rule says otherwise. Do not mirror an existing opposite-side key.
4. Check both directions of each changed boundary, saves on both sides, stale opened keys, the tavern's two cells/south exit, and the northern chapter round trip. Southeast travel must remain unchanged.

## Completion boundary

S05 remains open. This review narrows a potential first correction batch to three doorways and one wall pair; it does not authorize implementation during the user's playtest hold. Arena asymmetry, the unresolved face, full 256-difference reconciliation, service identity lookup and complete canonical face classification remain outstanding. No new standalone story is needed yet: these bounded geometry findings remain within S05's existing correction/migration scope.

Inputs are the unchanged canonical Map.png, candidate/current face ledger, `original_world.gd` movement/door/save methods and current City JSON. The contact sheet is a 4-by-4 set of 48-by-48-pixel source crops enlarged fourfold. No external source was fetched and no source document was altered.
