# F01 — Feature acceptance and closure

Completed 2026-11-20. All six feature acceptance criteria pass for the agreed
bounded rule/effect model. S01, S28, S29, S32, S30 and S31 are complete; S03-CLOCK
and S08-SPEED interfaces are implemented and verified.

| Criterion | Closure evidence |
| --- | --- |
| AC1 | S01 archived provenance, six seed records, examples and validators. |
| AC2 | S28 contract plus S29/S32 research and explicit user decisions resolve the implemented slice. The ledger preserves broader unknowns and named downstream owners. |
| AC3 | S29 definition/instance/owner separation, Get/Drop/Use/Unuse/terminal Delete, H suppression and scoped linked removal; 303 checks. |
| AC4 | S30 integer elapsed-time scheduler, ordered slot/event execution, explicit operation rejection and transactional clock adapter; 157 checks. |
| AC5 | S31 Physical Speed uses production activation/ticking/save paths: +5 for 30 minutes, save at +10 restores +20 with no replay, exact expiry removes the group. |
| AC6 | Legacy/invalid saves, clock/stat/service/travel regressions and integrated rendered keyboard-handler playtest pass; guide, coverage, migration and adaptations documented. |

[S31 acceptance and playtest](S31_ACCEPTANCE_REVIEW.md),
[S30 acceptance](S30_ACCEPTANCE_REVIEW.md),
[S29 acceptance](S29_ACCEPTANCE_REVIEW.md), and
[S32 research](S32_ST_TIMING_RESEARCH.md) provide the criterion-level evidence.

## Remaining work is outside this feature

| Deferred work | Owner |
| --- | --- |
| Item/inventory owners, stacks, equip/use special hooks and unknown item-event bits | S10 / F10 |
| Poison/disease/metabolism formulas and natural-cure RNG | S09 with S13/S21 content |
| Combat/guild casting, spell acquisition and other spell content | S13 / S21 |
| Broader save-system work beyond this bounded payload | S02 / F02 |
| General modifier producers, equipment/delusion content | S08 interfaces with their content stories |
| Original memory layout, fatal capacity defects and complete executable emulation | Excluded from the approved reconstruction scope |

The runtime rejects unsupported actions/cure rather than guessing. Stable IDs,
explicit ownership, safe slot capacity, transactional validation and v7 payloads
are reconstruction architecture. The user-approved Physical Speed normalization
preserves documented 30-minute duration and all elapsed time. City/Dungeon effect
carryover is explicitly a remake policy. None of these decisions claim fidelity
for unimplemented content or other editions.
