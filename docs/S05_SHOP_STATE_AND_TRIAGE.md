# S05 — Shared shop state and complete difference triage

2026-11-22. Static research only; no gameplay changes or original-game execution. Extends [service identity research](S05_SERVICE_IDENTITIES.md) and [priority passage review](S05_PRIORITY_PASSAGES.md).

## Da Place! state aliasing established in the candidate

Both physical occurrences are category 4 / marker 37 and select shop index 13; module 11 stores this at `a5+$1938`, with doubled index 26 at `a5+$1936`. Following the actual indexed reads/writes establishes shared addresses for the fields below. These are base-relative addresses, not module offsets or save-file offsets.

| State | Address calculation | Da Place! address relative to a5 | Module-11 evidence |
| --- | --- | --- | --- |
| Last visit day word | `$4ab4 + 2*index` | `$4ace` | `$00f4..$010e` reads elapsed days against `$f0c`; `$0194..$019c` writes current day. |
| Friendship fixed-point word | `$4ae2 + 2*index` | `$4afc` | `$0110..$0138` recovery; `$01da..$01e6` admission; `$04cc..$04de` subtraction with floor at zero. |
| Visit frequency byte | `$4b00 + index` | `$4b0d` | `$0128..$0130` clears; `$0506..$0528` reads/increments for greeting selection. |
| Last stock-refresh hour byte | `$4ad3 + index` | `$4ae0` | `$013c..$0156` compares with current hour `$1827`, stores it, and calls stock generation if different. |
| Six stock words | `$4a00 + 12*index` | `$4a9c..$4aa7` | `$053a..$0584` writes six generated words; `$0586..$0598` reads the same indexed block. |

Stock generation explicitly multiplies the doubled index by six. The focused listing was restarted at `$053a`, rather than continuing through the preceding greeting pointer table `$0530..$0539`; table bytes are not instructions. No coordinate or occurrence identifier participates in the listed address calculations. Thus these specific fields alias across both Da Place! entrances in the candidate, rather than merely selecting equal configuration values.

Kroah's archived establishmentsShops.html sections Friendship, Welcome Message and Wares List corroborate the field roles: relationship recovery after an absence, visit-frequency greetings and an hourly six-item selection. Candidate aliasing is additional evidence; it is not a silent change to the canonical text. Persistent here means state retained in the resident game arrays across visits, not a claim that disk-save serialization of every field has been independently traced.

Backlog consequence: retain two physical location stories and entrance identities, with a shared original shop-state identity for these verified fields. The eventual shared shop implementation and save design should represent that distinction. Do not create independent friendship/stock records for each entrance by default. Any deliberate independence would be a remake adaptation needing an explicit decision. Other fields, purchase effects and serialization remain separately unverified.

## Every raw difference now has an initial classification

The [256-row difference ledger](s05/difference-triage.csv) accounts for every unequal face exactly once. This is analytical triage, not completed historical verification.

| Class | Faces | What it establishes / still needs work |
| --- | ---: | --- |
| Service-encoding correspondence | 79 | Candidate 3 and expected destination service category match; current service integration remains incomplete. |
| Both blocked in inspected paths | 135 | 37→14 (97), 37→13 (10), 13→14 (28). No blocking-threshold difference in the inspected paths. Visual material, other behavior and category-specific effects remain unresolved. |
| Non-service blocking-threshold differences | 23 | The previously reviewed 16 ordinary-code faces plus seven special-code faces below. Not all represent a usable route or authorized correction. |
| Both below blocking threshold | 19 | 0→3 (6), 3→0 (1), 3→4 (9), 5→6 (3). Door/secret presentation and interaction differences still need reconciliation; shared passability is not equivalence. |

The threshold test is the candidate's nibble <7 branch and current support for the values occurring in this ledger. It is not a universal mapping of arbitrary boundary values. Current code 37 spans three candidate values, so replacing every 37 with one value is unsound.

## Seven additional special-code faces

| Approach face | Current → candidate | Research scope |
| --- | --- | --- |
| (16,1) south | 38 → 4 | Arena approach; trace directional behavior and scenario dispatch. |
| (5,7) east | 38 → 4 | Arena approach; same verification required. |
| (5,8) east | 38 → 4 | Arena approach; same verification required. |
| (25,8) west | 38 → 4 | Arena area; same verification required. |
| (16,13) north | 38 → 4 | Arena approach; same verification required. |
| (52,22) east | 38 → 4 | Palace gate area; entering a scenario is not proof of free movement through it. |
| (59,16) south | 37 → 6 | Distinct from the 107 other current-37 faces, whose candidate values block. Investigate this face individually. |

These seven were outside the earlier intentionally ordinary-code-only set. They do not invalidate its counts or justify adding seven doors immediately. Scenario handlers can restore the previous position or request a different chapter; geometry alone cannot establish final access.

## Remaining S05 work

Review the seven added faces against canonical imagery and full scenario handling; resolve the Arena asymmetry and visually unresolved ordinary face; trace remaining original boundary semantics and service dispatch bindings. The 135 blocked/blocked and 19 passable/passable differences still require explicit visual/semantic disposition. Raw-equal faces also retain their full canonical verification requirement. Final implementation scope, exact save policy and acceptance playtests remain outstanding during the coding pause.

Evidence inputs: unchanged checksum-verified module 11 from the existing S29 extraction, canonical archived shop documentation, and existing candidate/current map ledgers. No new external sources or source edits. Exact code evidence is module-relative; the field table above is explicitly a5-relative. Do not confuse these namespaces.
