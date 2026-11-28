# S05 inventory and identity acceptance

Reviewed November 28, 2026 against main baseline `a560c72` and the explicitly approved [scope split](S05_SCOPE_SPLIT.md). S05's retained inventory/identity criteria are satisfied by the evidence below. The former whole-map obligations remain in S108–S111 and existing location stories; this review does not complete F05 or certify every historical entrance.

## Accepted inventory

| Retained criterion | Evidence and result |
| --- | --- |
| Every legend entry and occurrence has an identity and owner | 67 legend entries, 66 observed markers, 463 numbered cells, 73 labeled occurrences; all are reconciled. Trade Winds (38) is explicitly absent, with no invented implementation story. |
| Current spatial components are accounted for | 81 components reconstructed directly from the current map, matching the later comparison ledger; 710 perimeter faces corroborated by the access inventory. The older 78-component file omitted three gate components and remains historical evidence. |
| Distinct identity namespaces remain distinct | Each record separates current raw code, spatial anchor/footprint, canonical marker, candidate runtime category, candidate state identity and location owner. All 463 canonical labels agree with candidate markers; this does not verify entrance behavior. |
| Shared state and duplicates are explicit | Both Da Place occurrences retain separate spatial IDs and the same candidate shop index 13. The specifically traced friendship, visit-day/frequency, refresh-hour and six stock-word fields are shared. Other fields and original disk serialization remain unverified. Inaccessible duplicates retain separate research owners. |
| Adaptations and uncertainties are owned | Tail of the Dog/Grimthorn/music and the approved northern City/Dungeon journey remain explicit adaptations. Gates, scenario approaches and southeast travel retain their evidence gates; details below. |
| Final count and link validation | The repeatable audit checks uniqueness, coverage, live issue identity and ownership. All 75 location owners exist and are open; there are no orphan components. Location issues receive the split-aware dependency handoff without being promoted to Ready. |

## Inventory artifacts and reproduction

- [Current component identity inventory](s05/identity-inventory.csv): 81 spatial records with footprints, evidence, confidence, state identities and owners.
- [Canonical occurrence crosswalk](s05/identity-occurrences.csv): 73 occurrences covering all 463 numbered cells.
- [Legend coverage](s05/identity-legend-coverage.csv): all 67 entries, including the absent Trade Winds entry.
- [Audit results and input hashes](s05/identity-audit-results.json).
- Run `python tools/audit_s05_inventory.py` from the repository root after refreshing `tools/reference/s05-live-issues.json` with `gh issue list --state all --limit 250 --json number,title,state,body`. The live snapshot is ignored and is not source evidence. Regenerate it if the backlog changes.

The audit reads the current map, candidate-cell data, canonical labeled cells and existing story mappings independently. It reconstructs current equal-code connected components rather than copying the old component count. The generated inventory is analysis, not a replacement game map or archival source. Recorded input hashes allow later changes to be identified.

## Unresolved identity and behavior register

| Case | Established identity boundary | Remaining evidence and owner |
| --- | --- | --- |
| Da Place, two occurrences | Category 4, marker 37, shared candidate index 13 and traced fields | S70 #104 / S71 #105 and shared shop system retain other state, transaction, persistence and entrance acceptance. |
| Acrinimiril's Gate, (31,27) | Current raw 60; name is ARX comparison, not a numbered canonical identity | S106 #140 must resolve same-edition identity/dispatch and any destination. |
| Floating Gate, (35,36) | Current raw 61; name is ARX comparison, not a numbered canonical identity | S107 #141 retains identity/dispatch and destination research. |
| Palace approach (53,22) and labeled gate (61,21) | Separate footprints; only the latter has canonical marker 48 | S79 #113 retains gate identity/behavior; S111 #147 supplies held passage contracts where applicable. |
| Arena approach components, raw 67 | Five unlabeled cells plus one canonical Arena cell; category and marker remain separate | S77 #111 owns scenario implementation and approach consequences; S111 #147 owns held direction/access evidence. No raw recoding or free scenario exploration. |
| Five inaccessible duplicates | Separate spatial occurrences, not automatically active services | S84 #118, S87 #121, S91 #125, S93 #127 and S101 #135 retain same-edition access/identity research. Valid guild indices do not authorize opening them. |
| Northern approach (49,3) and entrance (50,3) | Distinct approach and labeled destination; existing cross-edition travel is approved | S80 #114 retains full entrance acceptance and adaptation documentation. |
| Southeast Dungeon marker (59,62) | Distinct occurrence of marker 49 | S81 #115 retains destination/access evidence; no extra crossing authorized. |
| Northern, Southern and Western gates | Canonical labels identify one boundary cell each; larger current areas are not therefore invalid | S104 #138, S103 #137 and S105 #139 own their full gate behavior. S109/S111 apply only where their face evidence intersects these locations. |
| Service-coded approaches and unimplemented services | 79 faces have matching candidate door/category correspondence | Their location/shared-system owners retain entrance and service acceptance. Preserve encodings until integration; S05 closure does not activate services. |

Candidate runtime indices are recorded as qualified executable evidence, not as verified remake save identifiers or proof of every downstream state field. Category dispatch was traced in the earlier research; unresolved callbacks and behavior remain owned above. Historical notes saying dispatch or shared shop fields were wholly untraced are superseded only to the extent documented in S05_CATEGORY_DISPATCH.md and S05_SHOP_STATE_AND_TRIAGE.md.

## Acceptance limits and next work

No gameplay, source archive, map payload or save format changes are part of this acceptance. No additional manual playtest is needed for this inventory-only deliverable. Validation consists of inventory reconstruction, count/identity consistency, live issue verification and review of the exception register.

S108 owns the three-doorway/one-wall implementation and its future playtest. S109 owns the remaining canonical face classifications; S110 owns visual reconciliation; S111 owns the 30 held passage contracts. Completing S05 does not mark those stories Ready or complete. F05 remains open.
