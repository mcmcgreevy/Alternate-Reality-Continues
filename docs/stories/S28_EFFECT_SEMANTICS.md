# S28 — Resolve the bounded effect-runtime contract

Parent: F01 (#8) · Epic: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

City source: Kroah Atari ST City v2.0. Start with `docs/SOURCE_BASELINE.md`,
`docs/RULE_MODEL.md` and `data/reference/rules.json`. Sources below are unchanged
HTML in `assets/documentation/kroah-city-st-v2/`, with hashes in the documentation
catalog. New research must follow the archive policy. No Dungeon fidelity claim.

## User story
As a developer, I can implement a specified effect lifecycle without inventing missing original-engine behavior.

## Scope and evidence
Research and design only. Review technicalNotes.html: Entity +02 Events; Effect introduction, active index, required events, counter, timer, interval, natural cure, action and updated-variable fields. Review characterStats.html Primary and Secondary / Walking Speed; world.html Time Span; establishmentsGuilds.html Spells / Physical Speed. Read raw tables, not only flattened text.

The deliverable is `docs/EFFECT_RUNTIME_CONTRACT.md`, updated provenance records and source-derived trace fixtures. Define the minimal shared runtime needed by S29–S31; a complete original bytecode emulator is excluded.

## Acceptance criteria
- [x] Resolve or explicitly classify each relevant S01 question (IDENTITY-Q1, EVENT-Q1/Q2/Q3 and TIME-Q1/Q2): definition/owner/instance identity, capacity/index reuse, links, opposing pairs, repeated and simultaneous events, removal consequences, timer units, first tick, intervals, finite/zero counter, incubation, natural-cure sampling and execution/removal order. Each entry has a source locator, finding, affected story and disposition.
- [x] Specify named runtime quantities, units, scheduling interface, action targets and valid input domain; distinguish source facts from reconstruction architecture. Compare original Type/Interval/ProbToRemove/Action/Offset/NbBlocks/Gab/Param equality with typed runtime fields without replacing it with identity equality.
- [x] Produce an operation-support matrix: required for the bounded slice, deferred with named owner, or unresolved. Cover documented Set/Add/Sub/bitwise operations, text/link behavior and uncertain fields. Unsupported definitions must be rejected explicitly by future code, never silently run as no-ops.
- [x] Define trace fixtures for activation, duplicate suppression (including following definitions), opposing removal, linked text, first/repeat tick, expiry and explicit removal. Every expected historical result has provenance; synthetic inputs and adaptations are labeled separately.
- [x] Pin the integration example to Physical Speed: the Spells table documents +5 Speed bonus for 30 game minutes. Verify implementation semantics needed to apply/remove that contribution without asserting undocumented stacking. At base Speed 13, no other modifiers: effective 18 during the effect, 13 afterward; walking rate remains 6 in both cases. Do not use this example to claim a walking-rate tier change.
- [x] List blockers separately for S29, S30 and S31. An unresolved research result may close S28, but does not make blocked implementation Ready. Any behavior-changing adaptation requires an explicit recorded decision; this planning task does not approve guessed rules.

## Dependencies and boundaries
S01 complete. Consult S03 for the elapsed-game-time interface and S08 for modifier ownership; neither entire feature must be finished to write this contract. No runtime/save changes, broad disassembly, full content transcription or new player-facing spell UI.

## Validation and readiness
Review source-to-trace derivations; run rule-catalog validation and focused fixture checks after extending reference data. Done means the contract, support matrix, fixtures and per-story blocker disposition are reviewable, including honest unresolved findings. Research completed 2026-11-19; implementation readiness is evaluated separately. No estimates or dates committed.

## Live tracking

- [F01 — issue #8](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/8)
- [S01 — issue #34](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/34)
- [S28 — issue #62](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/62)
- [S29 — issue #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63)
- [S30 — issue #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64)
- [S31 — issue #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65)

## Completion record — 2026-11-19

All six research acceptance criteria met. Delivered `docs/EFFECT_RUNTIME_CONTRACT.md`,
`data/reference/effect_contract.json` (13 source-linked decisions), and
`tests/fixtures/effect_traces.json` (13 classified traces). S01 question records
link to these dispositions. Both validators pass; 10 effect-contract and 13
rule-catalog tests pass. No runtime, save or archive bytes changed by S28.

S29–S31 remain Backlog, not Ready. Opposition/ordering, timer units and modifier
removal need further evidence or an explicitly approved adaptation. Research
completion does not waive those implementation criteria or complete F01.
