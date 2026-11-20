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
- [x] Separate effect definitions, owning entity instances and active instances. Activation creates independent state without mutating the definition; two owners remain distinguishable. Runtime IDs are explicitly a reconstruction design, not original active-index claims.
- [x] Dispatch supported entity events, apply the resolved opposing-event removal rule, activate listeners and clear handled events. Unsupported bits, malformed references and invalid definitions fail explicitly without partial state changes (atomic rejection is a remake robustness choice).
- [x] Implement documented flag-H equality over all eight fields and suppression of the current and all following definitions on a match. Tests distinguish equal contents/different IDs from unequal contents/same type; flag-H-off behavior follows S28, not a guessed stacking rule.
- [x] Implement resolved FF/00 linkage semantics and scoped removal. Tests show removing one owner or linked group does not remove unrelated instances; repeated removal is safe and cannot undo a stat change twice. Exact rollback behavior comes from S28/S08.
- [x] Execute the approved event trace fixtures, including a non-listener, repeat activation, duplicate suppression and opposing-event case. No unresolved pair or ordering is introduced as historical fact.
- [x] Document the API and ownership in CODE_GUIDE; register rule/implementation locations and supported/deferred operations. Preserve current gameplay and saves until the integration story wires the new subsystem in.

## Dependencies and exclusions
Requires S28's identity/event/removal decisions, with no unresolved blocker for this slice. S08 owns stat arithmetic and modifier composition; this story owns dispatch and instance lifecycle. Timers, natural-cure RNG and game-clock wiring belong to S30. Serialization and real-world use belong to S31. No complete inventory, spells UI, diseases, combat or binary-memory emulation.

## Completion and acceptance review

S29 is complete for its non-timed generic-owner scope. All six criteria above are verified in [the acceptance review](../S29_ACCEPTANCE_REVIEW.md). Get, Drop, Use/Cast, Unuse and terminal Delete are supported. Get/Drop update held state; Drop while unheld is skipped. Delete removes the owner's records without activating listeners. Unknown bits and Delete listener definitions fail explicitly.

Explicit owner/group/listener bindings, monotonically increasing session IDs, owner tombstones and atomic rejection are reconstruction architecture. They implement the canonical lifecycle intent without copying the candidate's ambiguous byte-15 lookup or demonstrated stale-pointer defect. No stat change occurs during activation or removal, so there is no generic inverse action or double undo. Stat execution belongs to S30/S08.

The runtime is callback-free and processes one owner's captured bits in Get, Drop, Use, Unuse, Delete order. It clears pending bits before processing; no observer can see an intermediate callback state. Special-use/stackable item consumption, inventory/floor updates, binary long-text slots, unknown event bits, global scheduler ties, timed execution and persistence are outside this story's existing scope. They are not silently implemented.

Validation: 303 Godot checks (29 definitions, 41 instances, 233 events), including ten data-driven lifecycle traces; 23 Python checks; both provenance validators; 13 isolated original-code scenarios. See CODE_GUIDE for commands and the report for criterion-by-criterion evidence.

No gameplay or save integration is claimed. F01 remains open for S30 and S31.

## Live tracking

- [F01 — issue #8](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/8)
- [S29 — issue #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63)
- [S30 — issue #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64)
- [S31 — issue #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65)
