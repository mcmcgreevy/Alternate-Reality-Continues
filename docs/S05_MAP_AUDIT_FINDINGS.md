# S05 City map audit — first evidence pass

2026-11-22. Research in progress; no game code, map payload, tests or original source changed. No claim of complete City fidelity. All coordinates below use the zero-based northwest origin, X east/Y south.

## Inventory established

- [ST legend inventory](s05/st-legend.csv): 67 entries — 7 inns, 14 taverns, 3 banks, 15 shop labels, 4 smithies, 2 healers, 12 guild labels, 10 scenario labels. These are legend entries, not verified accessible establishments. Parenthesized shop (38) is explicitly absent according to Kroah.
- [Current-map location components](s05/current-location-occurrences.csv): 78 four-neighbor spatial components for raw location codes >=16. Connectedness does not establish service identity, accessibility or a source footprint; ordinary lower-code cells are excluded from this component inventory.
- [Current-map directed faces](s05/current-city-faces.csv): all 4096 cells and 16384 faces enumerated, with opposite-side codes where present. **All remain not_yet_compared_to_ST** in this new face ledger. Enumeration is not comparison completion; earlier verified location anchors remain documented separately in ST_LOCATION_CORRECTION.md.
- Current edge-code frequencies: 0:9292; 3:427; 5:426; 13:6046; 27:32; 28:8; 29:22; 30:6; 31:5; 32:4; 33:2; 37:108; 38:6.
- 1356 directed interior faces have a different raw code from their neighbor's opposite face (678 adjacent pairs). This is not a bug count: asymmetric passage semantics and establishment entry encodings may be intentional.

## Findings and confidence

| ID | Evidence | Disposition |
| --- | --- | --- |
| MAP-01 | Earlier verified anchors match ST markers 14,16,49 to current raw locations 30,32,65 respectively | Verified anchors; do not extrapolate a universal +16 mapping |
| MAP-02 | ST image marks healer 53 at the 3x3 block x28–30/y34–36; current payload uses location 74. ST healer 54 at x3–5/y44–46 uses current location 75. A +16 conversion would incorrectly assign them markers 58 and 59 | Confirmed numbering-namespace difference, not by itself a gameplay defect. Build explicit identity crosswalk before any renaming |
| MAP-03 | Kroah's Map Remarks explicitly identifies two #37 Da Place! occurrences and no #38 Trade Winds. Image shows #37 at (60,2) and (19,58); current raw location 53 occurs at both | Preserve documented ambiguity. Kroah's suggestion that one should be Trade Winds is not authority to silently rename it |
| MAP-04 | Map Remarks describes inaccessible/reused scenario labels 53,54,57 near Arena, and inaccessible/reused guild labels 65,58 replacing older identities | Research cluster, not five confirmed implementation bugs. Record category and accessibility separately from numeric label |
| MAP-05 | Previously verified marker 49 occurs at (50,3) and (59,62); current raw location 65 likewise occurs twice | Identity occurrences, not authorization for a second cross-edition crossing. Existing northern route stays supported |
| MAP-06 | Raw edge namespace includes establishment codes 27–33,37,38 as well as 0/3/5/13; opposite faces can differ | Resolve ST directional semantics and ARX encoding correspondence before classifying discrepancies. Do not symmetrize |

MAP-02 and MAP-03 coordinates were checked against the archived full-size ST map and the current JSON. This pass does not establish their entrance direction or service behavior. MAP-04's historical replacement names are preserved in the unchanged source remarks; they must not be substituted for the documented ST labels.

## Likely follow-up work, not yet new story IDs

| Candidate | Scope / acceptance prerequisite | Existing owner overlap |
| --- | --- | --- |
| Establishment identity crosswalk | Every source marker occurrence maps explicitly to current cells/code/category; duplicates and absent labels remain explicit; entrance evidence separately graded | S05/F05; service behavior stays F15–F22 |
| ST directional-map evidence | Locate/decode same-edition runtime/data evidence and resolve ambiguous image faces; cross-check against known anchors before proposing map correction | S05/F05; do not assume a static image proves one-way flags |
| Confirmed geography corrections and save migration | Only after a discrepancy is demonstrated; list exact changed faces/cells, save-position/door-key policy and regression routes | F05, with F02 persistence dependency |
| Duplicate/inaccessible scenario reconciliation | Explicit disposition for Da Place!/Trade Winds and Arena cluster; preserve source bugs/ambiguities unless an adaptation is deliberately approved | F05, service-content features only when applicable |

These are proposed work boundaries, not hidden sub-issues. Creating one story per marker would duplicate service features and inflate the backlog before knowing whether a defect exists. Promote independently deliverable work to real linked stories when the crosswalk/evidence pass establishes its scope. No new implementation is authorized while testing is pending.

## Next research step and completion boundary

Continue the occurrence-by-occurrence crosswalk, starting with healer/guild and Arena clusters where the numeric-offset assumption demonstrably fails. Then seek ST map/door data in the already archived executable research collection for unresolved passage semantics. No new probe or gameplay code during the user's coding pause.

S05 remains open: this pass inventories the source legend and current data and identifies concrete reconciliation questions. It does not complete the requested comparison of every ST occurrence or directed face, settle migrations, or certify gameplay accessibility.

## Provenance

Unchanged local sources already cataloged; no new download:

- world.html SHA-256: `3c49f286cbceb272615fa7f8cbc3bec501da6bd7eedde17c2e14fe0b5a8e3214` — Map legend and Remarks.
- Map.png SHA-256: `6f90a1f6ad1da0dabb53b5242f3e112c52dc66f9d273fb684208ae732c8af835` — 1024x1024, 16 pixels per cell.
- Current data/maps/city.json SHA-256: `2ff715f0272dc469ba1d86f670d049b5d2ac3e2907e2143c4b0db5ebda715914` — ARX-derived representation, not an ST dump.

The CSVs are derived analysis artifacts, not source documents or runtime assets. Source legend extraction uses the existing convenience text; the Map Remarks and numbered cells were also inspected in the archive/image. No executable analysis tool was added to the repository.

## Subsequent research

The earlier candidate-only backlog wording is superseded by [75 actual location stories](LOCATION_STORIES.md). The [current access and dispatch inventory](S05_LOCATION_ACCESS.md) adds 710 perimeter faces across all 81 components. Neither update completes historical directional verification.

## Candidate ST map comparison — 2026-11-22

[Executable/data evidence](S05_ST_MAP_DATA.md) identifies a four-byte-per-cell map block matching all 463 canonical numbered cells. All 16384 directed faces now have a separate candidate-data comparison: 16128 raw equal, 256 raw different. Canonical image verification and full passage semantics remain open; no gameplay corrections made.
