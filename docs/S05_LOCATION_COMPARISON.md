# S05 — ST City labeled-location comparison

Completed this bounded comparison 2026-11-22. **All visible numbered ST location cells and all current location components inventoried by S05 have been compared. Entrance behavior and the 16384 directed-face audit remain unfinished.** No gameplay code, map payload or test-build file changed.

## Results

The ST map has 463 numbered cells covering 66 distinct marker numbers, forming 73 connected label components. The legend has 67 entries: (38) Trade Winds is absent, as Kroah explicitly states. Connected components are spatial observations, not necessarily separate establishments or accessible areas.

The current-map inventory has 81 components after adding raw codes 9/10/11 for the City gates (the first pass counted only codes >=16):

- 70 components have an ST label on every current component cell.
- 7 have no ST label anywhere in the component.
- 4 have partial coverage: three gate areas (only the boundary cell is numbered), and an Arena-entry component.

These categories measure label coverage, not historical gameplay correctness. In particular, label coverage does not prove names, accessibility, doorway direction or special-event behavior match.

## Explicit identity crosswalk

| Current raw location | ST marker | Finding |
| --- | --- | --- |
| 16–53 | 0–37 | Numeric offset holds for these present codes; retain two #37 occurrences |
| 54 | (38) | No current cells and no ST map occurrence; ARX description exists but does not create a location |
| 55–59 | 39–43 | Numbered footprints align; spelling differences remain source-specific |
| 62 | 46 | 184 current Arena cells carry ST label 46; another ST Arena cell uses current code 67 |
| 63 | 47 | All 102 current Palace cells carry ST label 47 |
| 64 | 48 / unlabeled | (61,21) is labeled 48; current second Palace Gate cell (53,22) is not numbered |
| 65 | 49 | Both Dungeon entrances: (50,3) and (59,62) |
| 66,68 | 50,52 | Casino and Fitness Academy numbered footprints align |
| 69,70,73 | 53,54,57 | Arena-area scenario labels reuse healer/guild numbers; category matters |
| 74,75 | 53,54 | Actual healer footprints: x28–30/y34–36 and x3–5/y44–46 |
| 76–78 | 55–57 | Thieves, Blue Wizards, Light Wizards |
| 79,80 | 58 | Two distinct guild-colored footprints use ST label 58; preserve Kroah's inaccessible duplicate note |
| 81–85 | 59–63 | Red, Dark, Star, Chaos, Law |
| 86 | 65 | Arena-area inaccessible duplicate, not the normal Physicians location |
| 87,88,89 | 64,65,66 | Order, Physicians, Assassins |
| 9,10,11 | 74,73,75 | Northern (35,0), Southern (35,63), Western (0,36) gate labels; surrounding gate-area cells need not be numbered |

Full per-cell and component results: [numbered cells](s05/st-labeled-cells.csv), [ST label occurrences](s05/st-occurrences.csv), [current component comparison](s05/location-comparison.csv). Every row retains raw namespace rather than silently replacing numeric IDs.

## Substantive source identity differences

The existing ARX 0.82 description list gives context for current raw codes. It is secondary comparison evidence; a repository search found no game-code reference to that description file or the differing names below. These are not established onscreen defects.

| Raw code / cells | ARX description | ST evidence / disposition |
| --- | --- | --- |
| 46 / 13 cells | Ono Goods | Marker 30, Rocky's Emporium. Use ST name when this establishment is implemented |
| 48 / (0,50) | Grubron Imports | Marker 32, Special Imports Store. Use ST name |
| 69 / (25,13) | Armstrong Builders | Scenario-colored marker 53; Kroah explicitly documents inaccessible replacement. Do not route it to healer services |
| 70 / (26,16–17) | Apollo Trainers | Scenario-colored marker 54; inaccessible replacement per Kroah |
| 73 / five cells centered (22,16) | David's Weapons Trainers | Scenario-colored marker 57; inaccessible replacement per Kroah, distinct from Light Wizards at (2,59) |
| 79 / (25,19),(23–25,20) | Paladins Guild | Guild-colored ST marker 58; Kroah describes the inaccessible duplicate replacing Power Wizards Institute. ARX's identity differs from that historical replacement description too |
| 86 / (32,7–8) | Mercenary Guild | ST marker 65; inaccessible duplicate per Kroah, distinct from Physicians at (5,49) |

Minor source spelling/punctuation differences (for example Club Babalyon/Babylon and Betelguese/Betelgeuse) are retained in the CSV; canonical display spelling should come from ST evidence, not a blind import of ARX descriptions.

## Unlabeled and mixed cases requiring runtime/data evidence

Nine current high-code cells lack an ST numeric label:

- Raw 60, (31,27): ARX Acrinimiril's Gate.
- Raw 61, (35,36): ARX Floating Gate.
- Raw 64, (53,22): ARX Palace Gate; the visible doorway does not itself establish a numbered scenario cell.
- Raw 67, (16,2), (6,7), (6,8), (16,12), (25,8): ARX Arena Entrance.
- Raw 90, (49,3): ARX description explicitly says *by* an entrance to the Dungeon; this is the already documented approach to (50,3), not automatically a discrepancy.

Additionally (24,8), raw 67 Arena Entrance, is visibly ST label 46 Arena. This is a demonstrated label/raw-category difference, not proof the physical passage or event is wrong. The rest of the current Arena footprint is labeled consistently.

Gate boundary labels map to lower codes 9/10/11; the larger current gate areas include 33 unnumbered cells. A single marker on the boundary is not evidence those areas should be removed or recoded.

## Story implications

The evidence supports **two bounded research deliverables next**, followed by corrections only where justified:

1. Reconcile ST location dispatch/identity and inaccessible duplicate categories against executable/data evidence, including the nine unlabeled cells and mixed Arena cell. Deliver an explicit identity/category table and unresolved findings; no default service activation for reused labels.
2. Audit directional passage semantics and entrance faces independently of location labels. Deliver verified comparisons before proposing wall/door changes or save migration.

Identity data integration can then be a bounded implementation story after the coding pause; it should not duplicate each establishment's existing service feature. Geometry corrections/migration need actual confirmed differences first. No new story IDs or hidden sub-issues are created by this report.

## Method, checks and limitations

Inspected the unchanged 1024x1024 map and enlarged all four quadrants. Each cell occupies 16x16 pixels. Selected 66 visually read marker templates and matched their exact black-text masks in the cell interior (x=2..13, y=4..12, inclusive). [Template anchors and masks](s05/st-label-templates.csv) preserve the transcription basis; this is exact raster matching, not fuzzy OCR. The Palace Gate template uses visibly numbered (61,21), not unlabeled (53,22). Blank masks are excluded.

All nonblank black-text masks in that interior region match a selected marker template; 463 cells recognized, with no unmatched nonblank mask. The full-image/quadrant review corroborates category colors and duplicates. This does not identify unnumbered specials or prove the source map perfectly reflects the executable. Candidate entrance faces and runtime access remain unverified, apart from separately documented prior anchors.

Every recognized marker has a legend entry; every labeled cell maps to exactly one current JSON cell. All 81 current components appear exactly once in the component comparison. The 67-entry legend is accounted for as 66 observed markers plus one explicitly absent label. Earlier raw face inventory is unchanged and remains unverified against ST.

Source hashes are in [first-pass findings](S05_MAP_AUDIT_FINDINGS.md). ARX descriptions were copied unchanged from the existing local release extraction to assets/documentation/s05-arx-reference/cityDescriptions.txt and cataloged; original network download date is unknown. No new historical source was fetched and no analysis program was added to the repository.
