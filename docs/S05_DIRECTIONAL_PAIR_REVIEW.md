# S05 — Whole-map directional pair review

2026-11-27. Static map/rule analysis only; no gameplay changes, original-code execution or playtest.

## Coverage and result

Enumerated all 8064 physical interior adjacencies exactly once (east and south from each cell where a neighbor exists). These represent 16128 directed interior faces. The remaining 256 directed faces point outside the 64x64 map and are deliberately excluded from paired comparisons.

| Observation | Count |
| --- | ---: |
| Current unequal opposite raw-code pairs | 678 |
| Candidate unequal opposite nibble pairs | 599 |
| Candidate pairs with exactly one face below movement threshold 7 | 450 |
| Of those 450, current potential direction(s) agree | 445 |
| All pairs with matching candidate/current potential directions | 7972 |
| All pairs with different potential directions | 92 |
| Differences containing current service codes 27–33 | 77 |
| Differences without those service encodings | 15 |

This confirms that one-way topology is pervasive in the candidate, not an isolated Arena anomaly. Never repair the map by copying an opposite face or automatically opening a reverse door.

The [full pair ledger](s05/directional-pairs.csv) preserves both current and candidate values and separate direction eligibility. The [92-pair subset](s05/directional-pair-differences.csv) is a compact route-reconciliation inventory. It is not 92 newly discovered bugs: all input values already appear in the face comparison and existing 256-difference review.

## Movement model and limits

Candidate potential movement uses the inspected module05 branch: face nibble<7. Current potential movement uses current City routing eligibility: codes 0–7, plus 29 when its destination is one of the two Tail of the Dog cells. Doors/secrets are assumed examinable and openable. The model does not require they are currently open; it measures possible travel, not a single frame's movement result.

A candidate scenario entry may subsequently restore position or request another chapter. A current service code may remain intentionally unsupported until that service exists. UI restrictions, saves, character conditions and event effects are not included. Therefore matching directions are not runtime/historical fidelity passes.

The 77 service-containing differences correspond to the 79 service-encoding faces minus the two already-supported Tail of the Dog entries. These remain service-integration work, not a global geometry substitution.

The 15 other pair differences correspond to interior physical boundaries, not directed-face counts. The 23 non-service threshold-different faces include four outer edges and multiple pairs where both directions differ. This is why 23 faces cannot be compared directly to 15 interior pairs. These are the existing correction/hold cases, not added scope.

## Candidate one-way patterns

The 450 candidate threshold-asymmetric pairs include 0/13,3/13,5/13 and a smaller set involving14,4 or6. Reversing an ordered pair changes its direction, not its identity. Opposite-code inequality by itself still does not prove one-way movement: the other 149 asymmetric candidate pairs have matching threshold outcomes despite distinct raw values.

The candidate and current raw-pair counts (599 versus678) are different namespaces and must not be used as defect counts. Current service codes account for many intentional differences in representation. Appearance, service destination and collision must be reviewed separately.

## Acceptance implications

Any eventual correction must test the approached face and reverse face independently. Retain direction-specific save keys. For the proposed eight-face batch, keep the exact route review already recorded in [review handoff](S05_REVIEW_HANDOFF.md); do not broaden it to the 92-pair inventory without a new supported scope.

Use the five candidate one-way pairs whose current potential directions differ as targeted regression/research anchors, alongside service-entry coverage and the existing scenario holds. This report identifies them in the pair ledger but does not resolve their original-game outcome or approve corrections.

S05 remains open: numeric directional coverage is now complete at both face and pair levels, while canonical image semantics, held behaviors, implementation and acceptance remain incomplete. The previously classified 144 image-unresolved faces retain their statuses; this analysis does not relabel them as verified.

## Validation

Checked 8064 unique pair keys, 8064=64*63*2, and 7972+92=8064. Checked 77+15=92 and 445 preserved of 450 candidate one-way pairs. Source rows are the unchanged candidate/current comparison; no source document, runtime map or save was modified. Output files are derived documentation, not executable helpers.

## Five changed one-way anchors

| First cell / direction | Neighbor | Current forward / reverse | Candidate forward / reverse |
| --- | --- | --- | --- |
| (6,7) E | (7,7) | 3 / 3 | 14 / 3 |
| (24,8) E | (25,8) | 13 / 38 | 13 / 4 |
| (15,12) E | (16,12) | 3 / 3 | 3 / 14 |
| (16,12) E | (17,12) | 3 / 3 | 14 / 3 |
| (59,16) S | (59,17) | 37 / 13 | 6 / 13 |
