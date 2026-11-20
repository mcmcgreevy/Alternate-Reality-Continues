# S29 — Instantiate effects and handle entity events

Parent: F01 (#8) · Epic: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

City source: Kroah Atari ST City v2.0. Start with `docs/SOURCE_BASELINE.md`,
`docs/RULE_MODEL.md` and `data/reference/rules.json`. Sources below are unchanged
HTML in `assets/documentation/kroah-city-st-v2/`, with hashes in the documentation
catalog. New research must follow the archive policy. No Dungeon fidelity claim.

## User story
As a system developer, I can activate and remove owner-linked effect instances through one shared event lifecycle.

## Scope and evidence
Implement the non-timed core from S28. Sources: technicalNotes.html Entity / Events and Effects; Effect introduction, +01 Active index and +02 Allow multiple & Required events. S01 EFFECT-001/002 are the starting evidence, not a full implementation specification.

## Acceptance criteria
- [ ] Separate effect definitions, owning entity instances and active instances. Activation creates independent state without mutating the definition; two owners remain distinguishable. Runtime IDs are explicitly a reconstruction design, not original active-index claims.
- [ ] Dispatch supported entity events, apply the resolved opposing-event removal rule, activate listeners and clear handled events. Unsupported bits, malformed references and invalid definitions fail explicitly without partial state changes (atomic rejection is a remake robustness choice).
- [ ] Implement documented flag-H equality over all eight fields and suppression of the current and all following definitions on a match. Tests distinguish equal contents/different IDs from unequal contents/same type; flag-H-off behavior follows S28, not a guessed stacking rule.
- [ ] Implement resolved FF/00 linkage semantics and scoped removal. Tests show removing one owner or linked group does not remove unrelated instances; repeated removal is safe and cannot undo a stat change twice. Exact rollback behavior comes from S28/S08.
- [ ] Execute the approved event trace fixtures, including a non-listener, repeat activation, duplicate suppression and opposing-event case. No unresolved pair or ordering is introduced as historical fact.
- [ ] Document the API and ownership in CODE_GUIDE; register rule/implementation locations and supported/deferred operations. Preserve current gameplay and saves until the integration story wires the new subsystem in.

## Dependencies and exclusions
Requires S28's identity/event/removal decisions, with no unresolved blocker for this slice. S08 owns stat arithmetic and modifier composition; this story owns dispatch and instance lifecycle. Timers, natural-cure RNG and game-clock wiring belong to S30. Serialization and real-world use belong to S31. No complete inventory, spells UI, diseases, combat or binary-memory emulation.

## Validation and readiness
Focused headless lifecycle tests plus rule-catalog validation; no need to launch unrelated gameplay for an unwired core. Before Ready: S28 trace expectations and supported operations are settled. Planning status: Backlog, dependency-gated; not implementation-ready today.

## Live tracking

- [F01 — issue #8](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/8)
- [S01 — issue #34](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/34)
- [S28 — issue #62](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/62)
- [S29 — issue #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63)
- [S30 — issue #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64)
- [S31 — issue #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65)


## Implementation progress — 2026-11-19

Work started at the user's request. Added the supported foundation in
`scripts/effect_definitions.gd`: immutable definition storage, stable definition
identity/revision, precise raw eight-field comparison, H-gated suppression result
and atomic invalid-input rejection. `tests/test_effect_definitions.gd` passes 29
headless checks including ET02/ET03. CODE_GUIDE and EFFECT-002 coverage updated.

This is partial progress, not completion of any whole lifecycle acceptance
criterion. The module returns a suppression decision; actual iteration/activation
of current and following effects is not yet implemented. No runtime gameplay or
persisted fields changed. S29 remains open.

Remaining gates: active-instance/owner identity and FF/00 edge cases (ER01),
opposing pairs (ER02), simultaneous order (ER03), repeated activation consequences
(ER04), scoped cleanup/rollback (ER05), typed execution targets (ER12). The source
archive was rechecked; the linked disassembly project is explicitly 8-bit and
cannot substitute for ST evidence. A limited web discovery search did not provide
new applicable ST evidence; no new external document was used as a rule source.

Next: targeted original-ST research, or explicit remake-policy proposals for
review. No behavior-changing policy has been inferred from the instruction to
start work. Current lifecycle criteria remain unchanged.

## Original ST research follow-up — 2026-11-19

The user chose original-ST research before remake-policy decisions. See [the executable evidence report](../S29_ST_EFFECT_RESEARCH.md) and `tools/extract_s29_st_evidence.py`. The candidate has a V2.0 banner; 32 encoded records pass the original loader sector checksums. Static analysis establishes opposing pairs, event branch order, first-00 linkage and slot-only group removal. Byte-15 ownership, H-call pointer handling and long-text traversal require further reconciliation. This supersedes the earlier statement that no applicable external evidence was found. S29 remains In Progress; no additional acceptance criterion is marked complete.

## Research questions - current status

ER references are local research-ledger entries, not GitHub sub-issues. See [current answers and executable probes](../S29_ST_EFFECT_RESEARCH.md#isolated-execution-follow-up).

- Answered for bounded cases: first-00/skipped-predecessor linkage; Get/Drop and Use/Unuse pairs; dispatcher branch order; fresh H-off copies; Physical Speed duplicate suppression; one-byte Speed-bonus mapping and saturation.
- Cleanup finding: removal invalidates records without undo. Physical Speed uses separate Add/Sub records; early removal is not automatic rollback.
- Open: trace template byte-15 group binding with real equipment; reconcile Delete/held-state and clear-before-processing behavior; constrain long-text traversal.
- Candidate defect reproduced: duplicate suppression can compare a skipped definition. Preserve Kroah's current-effect rule, not that defect.
- Validation: 10 isolated original-code scenarios; not full-game emulation. No whole S29 lifecycle acceptance criterion is newly complete.
