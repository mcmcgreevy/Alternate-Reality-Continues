# S29 acceptance review

**Result: complete for the planned non-timed, unwired lifecycle.** S29 is not a
playable magic system and does not close F01. S30 owns timing/actions; S31 owns
gameplay and save integration. The original six acceptance criteria are retained
in `docs/stories/S29_EFFECT_EVENTS.md` and are checked against the evidence below.

## Criterion evidence

| Criterion | Evidence | Result |
| --- | --- | --- |
| Separate definitions, owners and active instances | Three modules have distinct stores. Definitions and snapshots are deep copies. Instance tests verify input/output isolation and two owners with identical definition contents. | Pass |
| Supported event dispatch and atomic rejection | Get/Drop/Use/Unuse/Delete dispatch, explicit opposing pairs, held guard, captured event clearing and terminal deletion. Event tests reject unknown/mixed bits, coercible mask types, malformed listeners, unknown references and invalid held state without changing pending/active state. Registration is validated completely before mutation. | Pass |
| Exact H comparison and suppression of current/tail | Definition tests vary each of the eight fields. Instance tests cover equal contents/different IDs, unequal same-type contents, global comparison across owners, same-call prefix comparison, H-off copies and preserved successful prefix. LF03 verifies current/tail suppression through dispatch. | Pass |
| FF/00 linkage and scoped, repeatable removal | First-00 starts its own group; skipped non-listeners cannot become parents. Same-owner separate groups, other owners, stale handles, repeated group/owner removal and repeated Delete are tested. No stat operation is called during removal, so no duplicate undo is possible. | Pass |
| Executable event traces | Ten source-linked LF01-LF10 fixtures cover non-listeners, repeat activation, equality suppression, concrete opposing Use/Unuse and Get/Drop pairs, linkage, terminal deletion, shared masks and combined event order. Fixtures are executed by the headless event test, not merely parsed. | Pass |
| API, provenance and exclusions documented; gameplay/saves preserved | CODE_GUIDE describes all three modules and contracts. EFFECT-001 is implemented; the event portion of EFFECT-002 is implemented while its timing/action portion remains partial. No production world, scene or save hook was added. | Pass |

## Resolution of the research gates

- **ER01, identity:** explicit owner/instance/group identities implement the
  documented copy/link behavior. First-00 and skipped-predecessor behavior are
  supported by original-code probes. Never-recycled session IDs and tombstones
  are reconstruction safety architecture, not ST slot-index claims.
- **ER02, opposing pairs:** candidate module 05 establishes Get/Drop and
  Use/Unuse. Canonical removal intent is implemented with explicit listener-mask
  bindings. We do not copy the ambiguous original template-byte-15 lookup.
- **ER03, order/clearing:** generic-owner branches run Get, Drop, Use, Unuse,
  Delete. Get sets held; unheld Drop is skipped. Pending bits are captured and
  cleared first, as in the candidate. No callback or scheduler can observe
  intermediate state in this synchronous module. Reentrancy/timer ties are not
  inferred and remain S30/S31 integration concerns.
- **ER04, repetition:** H-off creates fresh groups; H-on follows Kroah's exact
  current-effect comparison. The demonstrated stale-pointer defect after a
  skipped definition is explicitly not reproduced. Copy allocation does not
  assert linear stat stacking.
- **ER05, cleanup:** group removal invalidates records and never reverses an
  action. Physical Speed's separate Add/Sub effects demonstrate why general undo
  would be incorrect. Delete removes this owner's groups, never another's. The
  owner/group map is a deliberate reconstruction implementation of the canonical
  lifecycle, not a claim to have recovered every original byte-level caller.
- **ER12, typed targets:** S29 stores raw comparison data without executing it.
  There is no raw-address interpreter, so action/target execution is not a
  blocker for non-timed ownership. S30/S08 must supply validated typed actions
  before any stat mutation. The bounded Speed-byte evidence is available to them.

## Supported scope and deferred ownership

| Supported now | Deferred to named downstream owner |
| --- | --- |
| Generic effect-owner Get/Drop/Use/Cast/Unuse, terminal Delete | Inventory positions/floor lists, consumable stack behavior and item special-use hooks: S10/S13 content and S31 integration |
| Named event masks, explicit listener/group bindings | F/G/H entity bits and alignment triggers: S10/S13 source reconciliation; rejected now |
| Logical linked records and immutable definition snapshots | Native long-text memory slots, effect text payload/visibility and incubation: S30/content; no binary layout emulation |
| Explicit group/owner invalidation without arithmetic | Timers, counters, RNG, typed action execution and game-clock ordering: S30/S08/S03 |
| Session identities and tombstones | Persistent IDs, restoration, migration and exactly-once effects: S31/S02 |

Delete is terminal cleanup and does not activate Delete listeners in the
candidate dispatcher; such listener masks are rejected during registration.
This reconciles the distinction between a named entity event and an event that
actually activates definitions. We do not invent a Delete activation path from
the prose alone. Special-use and stackable owners cannot be silently represented
through hidden callbacks: the API has no such hooks and accepts only its exact
listener schema. Integration must deliberately add those capabilities later.

## Validation

- 29 definition checks, 41 instance checks and 233 event checks: **303 Godot
  checks**, including ten independently specified lifecycle fixtures.
- 23 Python provenance/contract checks; both catalog validators pass.
- 13 isolated original-code scenarios pass. The latest uses a synthetic empty
  non-stackable owner in the original entity table to verify held-state
  transitions, pending clearing and actual deletion/unlinking.

The original-code probes are evidence, not the reconstruction's unit tests or a
full Atari ST playthrough. The repository's pre-existing uncommitted movement
and weather changes are outside this review and are preserved.

Commands (PowerShell; Godot uses the ignored project-local APPDATA directory):

```powershell
$env:APPDATA = Join-Path (Get-Location) 'tools/appdata'
& './tools/godot/Godot_v4.5.1-stable_win64_console.exe' --headless --path . --script tests/test_effect_definitions.gd
& './tools/godot/Godot_v4.5.1-stable_win64_console.exe' --headless --path . --script tests/test_effect_instances.gd
& './tools/godot/Godot_v4.5.1-stable_win64_console.exe' --headless --path . --script tests/test_effect_events.gd
python -m unittest discover -s tests -p test_effect_contract.py
python -m unittest discover -s tests -p test_rule_catalog.py
python tools/validate_effect_contract.py
python tools/validate_rule_catalog.py
```
