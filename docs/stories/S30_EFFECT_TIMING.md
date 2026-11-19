# S30 — Execute timed effects through the game clock

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
Headless deterministic trace and clock-integration checks; rule-catalog validation; relevant clock regressions when wiring changes. Planning status: Backlog, dependency-gated. No production timer unit or unspecified source behavior is selected by this plan.

## Live tracking

- [F01 — issue #8](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/8)
- [S01 — issue #34](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/34)
- [S28 — issue #62](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/62)
- [S29 — issue #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63)
- [S30 — issue #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64)
- [S31 — issue #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65)
