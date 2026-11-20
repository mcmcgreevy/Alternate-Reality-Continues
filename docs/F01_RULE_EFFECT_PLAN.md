# F01 — Rule/effect model

## Owned prerequisites for S30
S30 remains **Backlog, not Ready**. The required follow-up work is now explicitly tracked:

- [ ] **S32 (#66):** resolve timer units/first-update phase (ER06/ER13), verify incubation and local expiry boundaries (ER07/ER08/ER09), and settle simultaneous timers, linked removal and timer/entity-event ties (ER03). Deliver the supported state/operation contract and reproducible evidence.
- [ ] **S03-CLOCK in S03 (#36):** deliver the elapsed-game-time interface and clock fixtures described in `docs/stories/S03_CLOCK_INTERFACE.md`.
- [ ] **S08-SPEED in S08 (#41):** deliver the typed Speed-bonus Add/Sub interface and action fixtures described in `docs/stories/S08_STAT_ACTION_INTERFACE.md`.

S29 is complete. S03 and S08 need not close in full. S32 is research work that can begin first; interface refinement may proceed in parallel, but final contracts must reflect its findings. Reassess S30 only when these deliverables have evidence and passing checks. ER identifiers refer to research-ledger entries, not additional GitHub sub-issues.

Parent: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

## Outcome and completion boundary
Deliver a provenance-backed, bounded shared effect runtime: separate definitions
and active instances, resolved entity-event handling, timed execution, and one
real character effect surviving save/load. S01 completed the reference foundation;
F01 remains open until the required implementation and integration criteria below
pass. This feature is not a complete emulator of every original effect operation.

## Required stories
| Story | Outcome | Dependencies / readiness |
| --- | --- | --- |
| S01 | Rule provenance, six seed records, contract and validator | Done (#34); user confirmed completion. |
| S28 | Resolve bounded runtime semantics and operation support matrix | Research complete 2026-11-19; unresolved blockers recorded. |
| S29 | Active instances, entity events and removal | Complete (#63); see S29_ACCEPTANCE_REVIEW.md. |
| S32 | Resolve original timing and scheduler order | Backlog (#66); S28/S29 complete. |
| S30 | Timed execution and game-clock adapter | S32, S29, S03-CLOCK and S08-SPEED. |
| S31 | Physical Speed effect and save/load integration | S29/S30; relevant S02, S03 and S08 slices. |

Detailed acceptance criteria and source locators live in the corresponding
`docs/stories/S28_EFFECT_SEMANTICS.md`, `S29_EFFECT_EVENTS.md`,
`S30_EFFECT_TIMING.md` and `S31_EFFECT_SAVE_INTEGRATION.md` specifications.
S28 research and S29 non-timed lifecycle are complete. S30/S31 remain Backlog and dependency-gated. S28 may finish with unresolved findings, but blocked implementation
cannot proceed until an evidence-backed resolution or explicitly approved
adaptation is recorded. No deadline or estimate is implied.

## Feature acceptance criteria
- [x] F01-AC1: provenance, examples and classification foundation delivered by S01.
- [ ] F01-AC2: S28 delivers a source-linked contract and required/deferred/unresolved operation matrix; no unresolved blocker remains for the implemented slice at feature closure.
- [x] F01-AC3: S29 implements definition/instance/owner separation, supported event activation/removal, linked effects and documented duplicate suppression, with passing trace tests.
- [ ] F01-AC4: S30 implements the agreed timed operation set with deterministic execution, explicit rejection of unsupported definitions and exactly one game-clock input; elapsed-time partition tests pass.
- [ ] F01-AC5: S31 demonstrates Physical Speed through the production world/stat/effect/save paths: +5 for 30 game minutes, 20 remaining after saving at minute 10, no duplicated contribution and correct expiry after reload.
- [ ] F01-AC6: legacy/invalid-save behavior and relevant stat/clock/travel regressions pass; integrated test-hook playtest is recorded; code guide, rule coverage, adaptations and deferred ownership are current.

## Ownership and dependency boundaries
| Owner | Responsibility |
| --- | --- |
| F01 / S28–S31 | Effect definition/instance identity, lifecycle, bounded action dispatch, timing state, effect save payload and shared integration tests. |
| F02 / S02 (#35) | General save versioning, migration framework, atomic loading and deterministic test controls. |
| F03 / S03 (#36) | Game-time conversion, calendar, pause and accelerated-service policy; supplies elapsed game time once. |
| F08 / S08 (#41) | Stat storage/precision, base/effective/displayed arithmetic and owned modifier composition. |
| F09 / S09 (#42) | Metabolism formulas, thresholds and cadence; consumes agreed shared interfaces where appropriate. |
| F10 / S10 (#43) | Inventory/item instances, equip/use actions, slots, charges and item-specific effects; calls shared event APIs. |
| F13 / S13 (#46), F21 / S21 (#54) | Combat casting and guild/spell acquisition/content. F01 uses a test activation hook, not early player-facing spell UI. |

These are interface dependencies, not circular whole-feature completion gates.
Stats and persistence can implement their interfaces against fixtures while the
runtime is developed. Later content extends the support matrix with its own
provenance and tests. It does not reopen the bounded F01 acceptance by implication.

## Exclusions and fidelity policy
No full effect/content transcription, native-memory/bytecode emulation, invented
unknown event bits, crash reproduction, full inventory/metabolism/combat/magic,
or independently verified Dungeon spell behavior. Deferred operations must have
named downstream owners; runtime rejects unsupported definitions explicitly.
Kroah ST City v2.0 remains authoritative; use the existing unchanged archive and
catalog. Integration architecture and chapter carryover are labeled remake
choices. Source gaps cannot be hidden behind arbitrary timer or stacking defaults.

## Closure
Close F01 only after S01 and S28–S32 meet their criteria and the feature checks
above pass. Having no open children alone is not sufficient. S28 could close with
documented gaps; S32 must resolve the bounded S30 timing gates before closing.

## Live tracking

- [F01 — issue #8](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/8)
- [S01 — issue #34](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/34)
- [S28 — issue #62](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/62)
- [S29 — issue #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63)
- [S30 — issue #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64)
- [S31 — issue #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65)

S28 handoff: [bounded runtime contract and per-story blockers](EFFECT_RUNTIME_CONTRACT.md). F01-AC2 remains unchecked because it also requires no unresolved blocker at feature closure.
