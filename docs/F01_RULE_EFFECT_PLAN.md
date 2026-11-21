# F01 — Rule/effect model

Current 2026-11-20 status: **Done**. All six feature criteria pass.
See [feature closure](F01_ACCEPTANCE_REVIEW.md) and [S31 evidence](S31_ACCEPTANCE_REVIEW.md).
The historical planning/dependency narrative below is retained for context.

## Owned prerequisites for S30
- [x] S29: non-timed lifecycle and scoped record cleanup.
- [x] S32 (#66): bounded timing/order research and user reconciliation.
- [x] S03-CLOCK (#36): elapsed-time API, timestamp boundaries and clock fixtures.
- [x] S08-SPEED (#41): typed Speed actions, ordered saturation and atomic rejection.

ER identifiers remain research-ledger entries, not additional GitHub sub-issues.

Parent: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

## Outcome and completion boundary
Deliver a provenance-backed, bounded shared effect runtime: separate definitions
and active instances, resolved entity-event handling, timed execution, and one
real character effect surviving save/load. S01 completed the reference foundation.
The required implementation and integration criteria below now pass. This feature is not a complete emulator of every original effect operation.

## Required stories
| Story | Outcome | Dependencies / readiness |
| --- | --- | --- |
| S01 | Rule provenance, six seed records, contract and validator | Done (#34); user confirmed completion. |
| S28 | Resolve bounded runtime semantics and operation support matrix | Research complete 2026-11-19; unresolved blockers recorded. |
| S29 | Active instances, entity events and removal | Complete (#63); see S29_ACCEPTANCE_REVIEW.md. |
| S32 | Resolve original timing and scheduler order | Done (#66); 18 original-code scenarios and explicit reconciliation. |
| S30 | Timed execution and game-clock adapter | Done (#64); S30_ACCEPTANCE_REVIEW.md. |
| S31 | Physical Speed effect and save/load integration | Done (#65); S31_ACCEPTANCE_REVIEW.md. |

Detailed acceptance criteria and source locators live in the corresponding
`docs/stories/S28_EFFECT_SEMANTICS.md`, `S29_EFFECT_EVENTS.md`,
`S30_EFFECT_TIMING.md` and `S31_EFFECT_SAVE_INTEGRATION.md` specifications.
S28–S32 are complete; all bounded integration gates pass. S28 may finish with unresolved findings, but blocked implementation
cannot proceed until an evidence-backed resolution or explicitly approved
adaptation is recorded. No deadline or estimate is implied.

## Feature acceptance criteria
- [x] F01-AC1: provenance, examples and classification foundation delivered by S01.
- [x] F01-AC2: S28 delivers a source-linked contract and required/deferred/unresolved operation matrix; no unresolved blocker remains for the implemented slice at feature closure.
- [x] F01-AC3: S29 implements definition/instance/owner separation, supported event activation/removal, linked effects and documented duplicate suppression, with passing trace tests.
- [x] F01-AC4: S30 implements the agreed timed operation set with deterministic execution, explicit rejection of unsupported definitions and exactly one game-clock input; elapsed-time partition tests pass.
- [x] F01-AC5: S31 demonstrates Physical Speed through the production world/stat/effect/save paths: +5 for 30 game minutes, 20 remaining after saving at minute 10, no duplicated contribution and correct expiry after reload.
- [x] F01-AC6: legacy/invalid-save behavior and relevant stat/clock/travel regressions pass; integrated test-hook playtest is recorded; code guide, rule coverage, adaptations and deferred ownership are current.

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
