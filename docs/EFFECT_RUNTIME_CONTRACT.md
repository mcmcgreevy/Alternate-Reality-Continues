# Bounded effect runtime contract — S28

Latest handoff: [S03-CLOCK is implemented and verified](S03_CLOCK.md); S30 now
waits only for S08-SPEED among the prerequisites identified by S32.

## Current S32 timing handoff — 2026-11-20

[S32 research and bounded contract](S32_ST_TIMING_RESEARCH.md) supersede the
historical timing unknowns below. Eighteen unchanged-code probes establish
ordinary/accelerated cadence, pause, first-update phase, event-before-timer and
slot order, zero timer/interval, counter and incubation behavior. The user chose
the documented 30-minute Physical Speed duration and processing all elapsed time
over the candidate's 29-minute window and missed-update loss. The report specifies
activation-relative integer-game-microsecond deadlines, supported typed Add/Sub,
ordering, text state and atomic rejection of unsupported operations/natural cure.
S03-CLOCK and S08-SPEED implementation/verification still gate S30; S29 is Done.
Do not use the original S28 readiness table below as current status.

Research completed 2026-11-19 against the unchanged Kroah Atari ST City v2.0
archive. This is a design/research deliverable, not runtime code or authorization
to invent historical behavior. S28 can close with explicit unresolved findings;
**Initial archive-only review:** S29-S31 were not Ready at that stage.
**Current disposition:** S29 is complete for the non-timed generic-owner slice;
see [acceptance review](S29_ACCEPTANCE_REVIEW.md). S30/S31 remain dependency-gated.

The machine-readable [decision ledger](../data/reference/effect_contract.json)
contains original URLs, catalog hashes, precise locators, findings, dispositions
and downstream blockers. The [13 traces](../tests/fixtures/effect_traces.json)
separate documented conditional outcomes, synthetic conditional inputs,
unresolved outcomes and proposed adaptations. S01 question records link to the
ledger. All reference artifacts remain development-only.

The [original-code follow-up](S29_ST_EFFECT_RESEARCH.md#isolated-execution-follow-up) now supplies narrower answers for ER01-ER05/ER12 and Physical Speed. The machine-readable ledger includes that follow-up; the archive-only tables below preserve the initial review context.

## Evidence reviewed

| Key | Unchanged source and locator | Supports |
| --- | --- | --- |
| TECH | [Technical Notes](../assets/documentation/kroah-city-st-v2/technicalNotes.html), Entity +02 Events; Effect introduction and +00–+15 field descriptions | Templates/copies, event names, linkage, duplicate check, timer/counter descriptions and action encodings. |
| STATS | [Stats](../assets/documentation/kroah-city-st-v2/characterStats.html), Primary Sub-Stat table; Secondary Walking Speed | Base/effective/displayed distinction and integer rate calculation. |
| TIME | [World](../assets/documentation/kroah-city-st-v2/world.html), Time Span table and final paragraph | Ordinary conversion, game-time duration convention, paused/accelerated time. |
| SPELL | [Guilds](../assets/documentation/kroah-city-st-v2/establishmentsGuilds.html), Spells / List, Physical Speed row under Duration and Description | +5 Speed bonus for 30 game minutes. |

Raw HTML tables were checked for column associations. A search of the archived
text collection for timer, interval, counter, incubation, multiple and opposed
found no general timer-unit or ordering definition beyond TECH. Content-level
durations do not establish the binary timer tick scale. No new external sources
were needed; no executable verification or broad disassembly was performed.

## Original archive-only question dispositions

Each ID below has a source locator and affected story in the ledger. “Partial”
means some facts are documented; the remaining question is still a blocker.

| S01 question | Decisions | Finding and unresolved portion |
| --- | --- | --- |
| IDENTITY-Q1 | ER01 | Copy identity and FF/00 linkage documented. Capacity, slot reuse, first-00 and skipped predecessor unresolved. |
| EVENT-Q1 | ER02 | Get/Drop/Use-Cast/Unuse/Delete named; F/G/H entity bits and exact opposition pairs unresolved. Do not confuse entity H with effect H. |
| EVENT-Q2 | ER03, ER06–ER09 | Initial timer differs from repeat interval; finite execution counter and zero sentinel documented; first expiry ends incubation. Tick units, zero timer/interval, simultaneous order, action-on-incubation-end and cure scale/order unresolved. |
| EVENT-Q3 | ER04, ER05, ER12, ER13 | Eight-field duplicate gate and linked-index mechanism documented. Repeated-cast stacking, general rollback, link cleanup traversal and Physical Speed's raw definition unresolved. |
| TIME-Q1 | ER10 | Ordinary 15× clock and stopped paused time documented. Exact pause contexts, precision and effect/metabolism scheduler order unresolved. |
| TIME-Q2 | ER11 | Services continue metabolism and state one game hour per real second. “240 times faster” is consistent if relative to the ordinary 15× clock; that comparison base is an interpretation, not a measured fact. S03 must reconcile it. |

ER05 does not mean removal always inverses an action. A permanent base-stat
change, a reversible bonus and a binary mask update need different reasoning.
Likewise, a finite counter's execution count does not establish a complete
ordering of cure, action, text visibility, reset and deactivation on its last tick.
Counter zero prevents removal *by execution*, not removal by other causes.

## Proposed architecture and typed quantities

The names and interfaces here are reconstruction design proposals. They express
the seams required by the already planned stories; they do not silently resolve
behavioral gaps. No production model or persisted field is changed by S28.

| Quantity | Type/domain and units | Responsibility |
| --- | --- | --- |
| `definition_id`, `definition_revision` | Stable nonempty identifier and version; no physical units | F01 definition registry; immutable during an activation. |
| `owner_instance_id`, `effect_instance_id` | Distinct runtime identities, not original byte indices | S29; S31 serializes resolvable identity without replaying activation. |
| `linked_effect_instance_id` | Optional resolved instance reference; never an arbitrary memory address | S29; preserve source linkage intent; unresolved edge cases rejected until settled. |
| `required_event`, `incoming_event` | Named supported A–E event; original bits retained as provenance | S29. A name alone does not establish its opponent or priority. |
| `initial_timer_raw`, `interval_raw` | Original word-sized quantities; signedness and time unit unknown | Keep raw evidence separate from game-time scheduling. |
| `remaining_game_time`, `elapsed_game_time` | Finite nonnegative durations; proposed explicit game-seconds API, preserving fractions | S03 owns representation/precision and conversion; S30 consumes it once. No raw tick conversion yet. |
| `remaining_executions` | Original byte counter; zero means unbounded by execution | S30; represent sentinel separately from exhausted finite count. |
| `incubating`, `text_visible` | Boolean state; linked text semantics from TECH | S30; no assumed first-expiry action ordering. |
| `natural_cure_raw` | Source byte; probability interpretation unknown | Reject cure-bearing definitions in the bounded slice; do not assume byte 0 means no cure. |
| `action_target` | Whitelisted typed character field, initially Speed bonus contribution | S08 owns stat arithmetic; F01 does not write native addresses. |
| `parameter`, `operand_width`, `block_count`, `block_gap` | Preserve original values/widths in provenance; accepted runtime ranges require an approved decoder | S28 ER12 / S30; no inferred wraparound, signed arithmetic or arbitrary block writes. |
| `duration_game_minutes` | Physical Speed: 30; bonus magnitude: +5 stat points | Documented content values, distinct from raw timer units. |

Proposed API boundary: `activate(owner, definition, event)` emits instance
changes; `advance(elapsed_game_time)` handles due work; `remove(instance, cause)`
uses the settled removal policy; `snapshot/restore` retains state without
activation replay. These are conceptual signatures, not required implementation
names. Reject nonfinite/negative elapsed time, unknown identifiers and unsupported
definitions before mutation. Atomic rejection is the explicit remake robustness
requirement in S29, not an assertion about the original engine.

S03 calls the runtime once per elapsed game-time interval. Rendering, weather
audio and wall clocks never tick effects independently. S08 supplies typed
contribution operations; S02 supplies versioning and atomic load; S31 owns the
effect payload. Suggested contribution identity is the effect instance, allowing
removal of exactly that contribution rather than overwriting an entire bonus.
This is a proposal until composition/removal semantics are settled with S08.
No proposal here approves generic additive stacking or refresh-on-recast.

The current `original_world.gd` has flat Speed/bonus/penalty fields and a float
`minute_fraction`; it is implementation evidence only. Its minute accumulator
does not reveal original effect tick units. S03 and S08 can develop interfaces
against fixtures without waiting for all of F01, avoiding circular feature gates.

## Duplicate equality mapping

TECH requires all eight fields to match. Instance/owner/definition identity is
not a substitute; neither counter nor current timer is in the listed tuple.

| Original field | Proposed typed comparison key |
| --- | --- |
| Type | Original effect-type code |
| Interval | Original interval value (before any lossy conversion) |
| ProbToRemove | Original natural-cure parameter |
| Action | Original action encoding, including operand width |
| Offset | Original target address-space discriminator and offset, mapped to a validated typed target |
| NbBlocks | Original number of blocks |
| Gab | Original gap between blocks (`Gap` elsewhere in TECH) |
| Param | Original parameter representation |

When H is set and a match is found, current and all following definitions do not
activate. ET02 tests different IDs with equal content; ET03 changes only Param
and asserts only that this comparison does not block, not guaranteed activation.
The source says active-effects list; do not introduce an owner-only search filter
without evidence. Raw-to-typed mapping must preserve distinctions rather than
accidentally collapsing two different native encodings.

## Operation-support matrix

“Required” is an implementation obligation, not proof it is currently resolved.
The loader must reject unsupported definitions explicitly. Deferred operations
do not become no-ops and do not silently inherit another edition's behavior.

| Operation | Disposition / owner | Gate |
| --- | --- | --- |
| Template copy, stable owner/instance identity | Required S29 | ER01 edge-case policy and representation. |
| A–E dispatch, opposing removal, event clearing | Required S29 | ER02 opposition map; ER03 priority/reentrancy. |
| H duplicate gate, suppression of later definitions | Required S29 | Eight-field mapping; repeat-cast consequences ER04. |
| FF/00 links and linked text | Required S29/S30 | ER01 predecessor cases; ER05 cleanup; ER08 visibility ties. |
| Initial/repeat timer, finite/zero counter | Required S30 | ER06 units/zero domains; ER07 final-tick order. |
| Incubation | Unresolved S30 | ER08; reject until settled, as S30 AC currently requires it. |
| Typed grant/revoke of Physical Speed contribution | Required S30/S31 with S08 | ER05/ER13 removal and boundary policy. Not generic inverse arithmetic. |
| Generic Set | Deferred S10/S13/S21 content | TECH describes block initialization, but width/target validity must be extracted per content. |
| Generic Add/Sub | Deferred S09/S10/S13/S21 content beyond the Speed slice | ER12 numeric semantics; permanent changes are not owned temporary modifiers. |
| Xor/And/Or | Deferred S10/S13/S21 | Sized operands, valid targets, no automatic inverse on removal. |
| Rts function indices 2/3 | Deferred S13/S21 research | Preserve encoding; do not translate into arbitrary runtime no-op success. |
| Natural cure | Deferred S09/S13/S21; reject in bounded runtime | ER09. S30 explicitly permits tested rejection of cure-bearing definitions. |
| Unknown types/bits, entity-relative memory, +15 linked slot | Unresolved S10/S13/S21 | Source itself questions meaning/usage; reject. |
| Save payload and exactly-once contribution restoration | Required S31 with S02 | Stable IDs, revision handling, precision and contribution contract. |

## Trace interpretation and Physical Speed

ET01–ET05 exercise activation, equality, opposing removal and linked text using
stated preconditions. ET06 uses synthetic initial timer 3 and interval 2: due
times 3, 5, 7 in **abstract units**, with no cure/incubation/external events.
ET07 counts two executions before eventual deactivation; it intentionally does
not order every final-tick operation. ET08 states incubation/text outcomes without
inventing action-on-first-expiry. ET09 and ET12 deliberately contain unknown
outputs; they are research fixtures, not executable pass/fail gameplay oracles.

ET10 derives Physical Speed's observable values from SPELL, STATS and TIME.
With base 13, no other modifiers and no delusion: bonus 5 gives effective/displayed
18; after the effect ends, effective returns to 13. Walking rate is 6 in both
cases: integer division gives `(18 + 5) div 6 = 3` and `(13 + 5) div 6 = 3`.
The documented duration is 30 game minutes. The row does not expose the raw
template or prove a particular immediate-grant/deadline/revoke algorithm.

ET11 is the proposed S31 persistence contract: saving 10 game minutes into the
30-minute duration leaves 20, with one contribution and no activation replay.
Arithmetic is derived; the save architecture is an adaptation. ET13 tests the
planned atomic rejection policy. Proposed-adaptation fixtures are not evidence
that a behavior policy has been approved. No physical timing, repeat-cast or
same-timestamp conclusion is smuggled into the simple duration example.

## Readiness gates and next decisions

| Story | Blockers remaining after S28 | Work that is safe independently |
| --- | --- | --- |
| S29 | ER01, ER02, ER03, ER04, ER05, ER12: edge identities, opposition, concurrent/repeated events, cleanup and typed mapping | Design immutable definitions/IDs, validate supported inputs and implement isolated documented duplicate comparison. This does not complete current S29 AC. |
| S30 | S29 plus ER03, ER06–ER08, ER10–ER13; S03 elapsed-time interface and S08 target contract | Trace harness with abstract units, explicit unsupported-operation errors. No production timer conversion. |
| S31 | S29/S30 plus ER05, ER10/ER11, ER13; S02 version/atomic load and S08 owned contributions | Specify payload references and reload invariants. No assertion of completed saved-effect gameplay. |

Resolution paths are (a) targeted same-edition evidence/executable study with
archived provenance, or (b) a separately reviewed, explicitly accepted adaptation
covering the affected behavior. A third option is to refine story scope to a
smaller supported subset and update F01 acceptance explicitly; do not silently
weaken acceptance. This research has not selected any of those behavioral
policies. F01 remains open. S28's requirement is an honest disposition, not a
fabricated fully executable contract.

## Validation

```text
python tools/validate_rule_catalog.py
python tools/validate_effect_contract.py
python -m unittest discover -s tests -p test_effect_contract.py -v
python -m unittest discover -s tests -p test_rule_catalog.py -v
```

Structural checks verify archive hashes, source/decision/question links, coverage
and fixture classifications. They do not evaluate production formulas or prove
that the original executable implements these notes. Numerical derivations and
scope boundaries were reviewed against the cited HTML. No game execution,
runtime modification or save migration is part of this story.

## Original executable follow-up — 2026-11-19

The [S29 executable research](S29_ST_EFFECT_RESEARCH.md) adds evidence beyond this original archive-only decision ledger: opposing Get/Drop and Use/Unuse pairs, branch order, first-00 linkage, capacity and slot invalidation. It also identifies clear-before-processing and Delete behavior requiring reconciliation. ER01–ER05 and the conditional fixtures have not yet been promoted to a complete runtime contract. Do not interpret their original unknowns as an absence of this new evidence.

## Bounded Use/Unuse implementation contract

S29 now implements generic effect-owner Use/Cast and Unuse dispatch using the documented opposition semantics and candidate branch order. Explicit owner/group/listener-mask bindings replace the unresolved raw template-byte-15 mechanism as reconstruction architecture. Processing is synchronous with no callbacks: capture/clear then Use, then Unuse; remove opposing groups before activation. No timer/event ties or reentrancy policy is inferred. Get/Drop/Delete, special-use hooks and other bits fail validation. Stat execution and undo are absent. The ledger's broader historical gaps remain open. See CODE_GUIDE for API details and tests/test_effect_events.gd for executable bounded cases.

## Final S29 disposition

S29 now supports generic-owner Get/Drop/Use/Unuse and terminal Delete. The earlier Use/Unuse-only subsection records the intermediate increment, not the final support boundary. Unknown entity bits and Delete listeners are rejected. The explicit owner/group map resolves the bounded lifecycle through reconstruction architecture; no original-byte-layout fidelity is claimed. Callback-free processing uses the candidate order and held guard. Removal performs no arithmetic. See S29_ACCEPTANCE_REVIEW.md for the complete criterion audit and downstream owners for remaining historical/action/timing questions.
