# S108 — Correct three City doorways and one wall

## Player outcome
Traverse the three source-supported missing doorways while the documented wall blocks movement, without damaging an existing journey.

## Exact scope
Eight directed faces only: (10,30) south/(10,31) north, (11,31) east/(12,31) west, and (10,32) east/(11,32) west change 13 to 3; (26,34) south/(26,35) north change 5 to 13. Coordinates are zero-based, northwest origin.

## Readiness gate
Before implementation, define the geometry/save revision and normalization policy, inspect arbitrary legacy door keys, and define old/new-save fixtures. Evidence supports the bounded correction; migration design still requires refinement.

## Acceptance
- Each changed face links to canonical crops and candidate evidence; retain source hashes.
- Test each boundary in both directions. A stale opened-door key must not bypass the restored wall.
- Remove only obsolete keys city:26,34:2 and city:26,35:0 under the documented migration. Preserve positions and unrelated keys; do not infer reciprocal open state. New door faces default closed unless separately justified.
- Save/load on both sides, supported legacy migrations and repeated loads preserve a valid journey.
- Verify newly accessible cells have expected exits, both tavern cells and south exit, northern City/Dungeon round trip, and no southeast crossing.
- Run focused regression and manual route acceptance; static graph reachability alone is insufficient.

## Dependencies and exclusions
Uses accepted F02/F03 and existing movement. Does not depend on completing all face research. No service-code replacement, Arena/Palace access, or other held geometry. S77/S78 gate the separate scenario approaches, not these eight faces.

Evidence: docs/S05_REVIEW_HANDOFF.md, docs/s05/review-dispositions.csv, docs/s05/proposed-eight-face-route-review.json, docs/S05_PRIORITY_PASSAGES.md.

Parent: F05 (#12). Committed to the November 30 sprint. Implemented November 28; automated checks pass, manual acceptance pending. See [implementation and migration policy](../S108_ACCEPTANCE_REVIEW.md) and [playtest](../S108_PLAYTEST.md).
GitHub: https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/144

