# S32 — Resolve original effect timing and scheduler order

Parent: F01 (#8) · Epic: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

## Completion

Completed 2026-11-20. [Acceptance review](../S32_ACCEPTANCE_REVIEW.md) and
[research/approved handoff](../S32_ST_TIMING_RESEARCH.md): 18 original-code cases,
13 prior probes and 23 validation tests pass. S30 remains Backlog pending the
S03-CLOCK and S08-SPEED implementations.

## User story

As a developer, I can implement S30's timed effects using verified timing and ordering rules rather than guessing how the original scheduler works.

## Scope and starting evidence

Research and contract refinement only. Continue the original-ST investigation from S28/S29 using the unchanged Kroah ST City v2.0 archive, the pinned candidate disk, `docs/S29_ST_EFFECT_RESEARCH.md`, and `tools/extract_s29_st_evidence.py` / `tools/probe_s29_st_effects.py`. Kroah remains the canonical rules baseline; executable discrepancies must be recorded explicitly. Preserve any new references in the documentation library with provenance and hashes.

S29 is complete. Its probes deliberately forced effect updates; they did not establish clock cadence. Physical Speed's raw timers 1 and 30 and the documented 30-minute duration are evidence to reconcile, not proof of a tick conversion.

## Acceptance criteria

- [x] **S32-AC1 — Unit and phase:** trace the original updater's callers and clock/counter sources; establish raw timer units, cadence and first-update phase, including ordinary versus accelerated operation. Record exact module offsets, source hashes and derivations.
- [x] **S32-AC2 — Execution order:** establish local expiry/incubation/action/counter/removal order and the order of coincident effects, linked cleanup and entity-event/timer ties. Explain which conclusions are measured, statically derived or still limited by the probe environment.
- [x] **S32-AC3 — Boundary fixtures:** provide reproducible executable research cases for initial zero, interval zero, finite versus zero counter, first expiry with incubation, simultaneous expiry/removal and Physical Speed's first/last update. Use synthetic inputs explicitly; do not claim a forced update establishes a time unit.
- [x] **S32-AC4 — Bounded support contract:** update the research ledger, runtime contract and fixtures with the units/precision/valid domains required by S30. Specify supported timer/counter/text state and required versus rejected operations, including the permitted exclusion of natural cure. Record discrepancies and any explicitly approved adaptation; do not invent unresolved rules.
- [x] **S32-AC5 — Handoff:** identify the exact elapsed-time semantics S03 must supply and the operation ordering S08's Speed-bonus API must support. Update S30's readiness checklist with evidence links, then verify provenance checks and the research probes.

## Completion rule

This story closes only when the timing questions needed by the bounded S30 slice are resolved by evidence or an explicitly recorded approved decision. An unresolved result is useful progress, but does not satisfy the affected acceptance criterion or make S30 Ready. If genuinely new out-of-scope work emerges, give it an explicit issue and preserve the unresolved S30 gate.

## Dependencies and boundaries

Depends on completed S28 (#62) and S29 (#63), not on completion of S03 or S08. Research findings feed the narrow interface work in S03 (#36) and S08 (#41); those interface designs may proceed in parallel without selecting undocumented timing defaults.

No production scheduler, stat mutation, save integration or player-facing change belongs here. S30 (#64) owns timed runtime implementation; S31 (#65) owns gameplay/save integration.

## S30 readiness relationship

S32 owns the remaining **timer-unit/phase** and **simultaneous-work/incubation** research gates. S30 also needs the explicitly named S03 clock-input and S08 stat-action deliverables; closing S32 alone does not automatically start S30.

Live issue: https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/66
