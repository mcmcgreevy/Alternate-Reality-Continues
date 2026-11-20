# S30 — Execute timed effects through the game clock

## Current readiness after S08

**Ready; implementation has not started.** All listed prerequisites now have
completed deliverables and passing checks. The historical reviews below are
retained as history, not current blockers.

- [x] S29: generic-owner lifecycle and scoped cleanup; 303 regression checks pass.
- [x] S32: verified timing/order, supported domains and explicit user reconciliation.
- [x] [S03-CLOCK](../S03_CLOCK.md): exact elapsed input and timestamp boundaries,
  fractional conversion, ordinary/pause/accelerated time and save compatibility.
- [x] [S08-SPEED](../S08_STATS.md): typed saturating byte Add/Sub, supplied-order
  execution, atomic rejection and no implicit rollback; 107 focused checks pass.

Use activation-relative deadlines, one raw positive timer unit = 60,000,000 game
microseconds; zero remains dormant. Physical Speed's immediate grant plus
1800-second expiry is a normalized content schedule, not literal raw-template
replay. Preserve owner-event-before-timer ties and ascending scheduling-slot
order independently of instance IDs. See the complete S32 contract before coding.

## Prerequisites recorded before S32 research
S30 remains **Backlog, not Ready**. The required follow-up work is now explicitly tracked:

- [ ] **S32 (#66):** resolve timer units/first-update phase (ER06/ER13), verify incubation and local expiry boundaries (ER07/ER08/ER09), and settle simultaneous timers, linked removal and timer/entity-event ties (ER03). Deliver the supported state/operation contract and reproducible evidence.
- [ ] **S03-CLOCK in S03 (#36):** deliver the elapsed-game-time interface and clock fixtures described in `docs/stories/S03_CLOCK_INTERFACE.md`.
- [ ] **S08-SPEED in S08 (#41):** deliver the typed Speed-bonus Add/Sub interface and action fixtures described in `docs/stories/S08_STAT_ACTION_INTERFACE.md`.

S29 is complete. S03 and S08 need not close in full. S32 is research work that can begin first; interface refinement may proceed in parallel, but final contracts must reflect its findings. Reassess S30 only when these deliverables have evidence and passing checks. ER identifiers refer to research-ledger entries, not additional GitHub sub-issues.

Parent: F01 (#8) · Epic: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

City source: Kroah Atari ST City v2.0. Start with `docs/SOURCE_BASELINE.md`,
`docs/RULE_MODEL.md` and `data/reference/rules.json`. Sources below are unchanged
HTML in `assets/documentation/kroah-city-st-v2/`, with hashes in the documentation
catalog. New research must follow the archive policy. No Dungeon fidelity claim.

## User story
As a system developer, I can advance effects by elapsed game time with repeatable execution and removal, independent of rendering frame rate.

## Scope and evidence
Sources: technicalNotes.html Effect / incubation, Counter, Timer, Interval, Probability of natural cure, Action and updated variable; world.html Time Span. Implement the bounded operation set approved in S28, including the timed Physical Speed path required by S31. This is not all spell, poison or disease content.

## Acceptance criteria
- [ ] Consume one explicit elapsed-game-time input; retain the precision/unit agreed in S28. No wall-clock, rendering or audio clock drives effects. S03 owns real/game conversion, pause and accelerated services; effects must not perform a second conversion.
- [ ] Implement distinct initial timer and repeat interval, finite counters and counter-zero non-expiry-by-execution, incubation and required action dispatch according to approved traces. A zero counter remains removable by other supported causes.
- [ ] Implement required natural-cure handling with injected deterministic randomness and the resolved probability scale/order, or explicitly reject cure-bearing definitions if S28 excludes them from this bounded operation set. A rejection must be tested and documented, not a silent omission.
- [ ] Tests compare one large elapsed update with equivalent smaller updates for the same event schedule and random stream, covering multiple due executions, exact boundaries, no elapsed time, removal during execution and linked cleanup. For a synthetic first timer 3 and interval 2 in agreed timer units with no cure/expiry, trace executions at 3, 5 and 7; these numbers are test inputs, not historical constants.
- [ ] Preserve the resolved order of simultaneous timers/events and avoid executing removed instances or skipping due work. Invalid negative elapsed time and unsupported operations follow the documented robustness policy.
- [ ] Validate clock adapter behavior for ordinary, paused and accelerated time against S03's settled interface; update CODE_GUIDE and provenance coverage. Add no second scheduler or duplicate metabolism updates.

## Dependencies and exclusions
S28 timing/action decisions, S29 core and the relevant S03 clock interface/semantics are prerequisites, not completion of every S03 calendar task. S08 supplies typed stat targets and contribution semantics. S09 retains metabolism formulas and cadence. Save/reload integration belongs to S31. Undefined timer units or execution order block Ready; do not guess them.

## Validation and readiness
Headless deterministic trace and clock-integration checks; rule-catalog validation; relevant clock regressions when wiring changes. Planning status: Ready after S08; implementation not started. No production timer unit or unspecified source behavior is selected by this plan.

## Live tracking

- [F01 — issue #8](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/8)
- [S01 — issue #34](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/34)
- [S28 — issue #62](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/62)
- [S29 — issue #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63)
- [S30 — issue #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64)
- [S31 — issue #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65)

## Readiness review after S29 completion

**Not Ready; keep Backlog.** S29's non-timed lifecycle is complete, but S30's timing/clock/stat prerequisites are not yet settled. Implementation has not started.

| Gate | Current evidence | Required before In Progress |
| --- | --- | --- |
| S29 lifecycle | Complete; acceptance review and all tests pass. | Met. |
| Raw timer unit/phase (ER06/ER13) | Physical Speed uses timers 1 and 30; probes force effect updates. | Trace scheduler cadence and map raw ticks to elapsed game time, including first-update phase. Spell duration alone does not prove the mapping. |
| Local expiry sequence (ER07/ER08/ER09) | Candidate reloads interval, handles incubation, checks cure, executes action, then decrements finite counter/removes. Zero timer is skipped. | Convert static findings into boundary/incubation fixtures; do not repeat the older blanket claim that local order is wholly unknown. |
| Simultaneous work (ER03) | S29 establishes per-owner event-bit order only. | Settle coincident timer execution, linked removal and timer/entity-event ties. |
| Clock input (S03, ER10/ER11) | Working tree has uncommitted continuous real-seconds/fractional-minute edits; committed world has integer-minute advancement. | Settle a single elapsed-game-time interface and precision, pause and accelerated-service behavior. Preserve unrelated changes. |
| Typed actions (S08, ER12) | Original one-byte Speed-bonus saturating Add/Sub is verified; world has flat fields. | Establish bounded typed action API and state schema. S29 stores comparison data, not executable targets or timers. |
| Natural cure | Existing S30 criterion permits explicit rejection. | No need to complete all RNG research if this exclusion is encoded and tested; never silently ignore a cure-bearing definition. |

S03 and S08 do not need to finish every feature before S30 starts. Their narrow elapsed-time and Speed-bonus contracts do need to be settled. Next: trace the original scheduler/cadence, specify those interfaces and supported state/operations, add exact-boundary/order expectations, then reassess readiness. No production code or project status was changed by this review.
