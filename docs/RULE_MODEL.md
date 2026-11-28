# Rule provenance and effect contracts

S01 implementation, 2026-11-18. Start future City rule work here and with the
[source baseline](SOURCE_BASELINE.md). The [rule catalog](../data/reference/rules.json)
is development reference data, excluded from Godot imports by its `.gdignore`.
It is not a runtime database or an effects engine. The
[examples](../tests/fixtures/rule_examples.json) are hand-derived acceptance
examples, not recordings of prototype output.

## Record format (schema version 1)

Paths are repository-relative, with forward slashes. Rule IDs are stable uppercase
prefixes and three digits; do not renumber published records. Each record has:

| Field | Contract |
| --- | --- |
| `id`, `subsystem`, `edition_platform` | Stable identity, owning system and explicit edition. City evidence does not establish Dungeon behavior. |
| `evidence` | `documented`: supported by the selected archived source; `adaptation`: deliberate reconstruction with `rationale` and `adapts` links to documented rules; `unresolved`: insufficient or contradictory evidence, not a production default. |
| `sources` | Nonempty list of source objects: `kind`, `path`, `source_url`, `catalog_path`, `catalog_file`, `sha256`, `locator`. Archive references match the documentation catalog and actual bytes. Implementation evidence explicitly uses `not applicable` for catalog/hash fields because mutable code is not an archived original. |
| `inputs`, `outputs` | Named quantities with explicit `unit` strings, including real versus game time. |
| `behavior` | Formula or bounded event behavior. Each assertion must be covered by a source locator; use multiple sources or split a record when needed. |
| `precision_rounding`, `bounds` | Arithmetic order, numeric representation and limits. `unknown` requires a question; `not applicable` must state why. Do not import prototype clamps. |
| `trigger_cadence`, `update_order` | When and in what order the rule applies; distinguish a documented local sequence from an unknown global scheduler order. |
| `implementation` | Independent coverage: `not implemented`, `partial`, `implemented`; repository `locations` and explanatory `notes`. Coverage applies only to the record's bounded scope, not whole-system fidelity. |
| `fixture_ids` | Reciprocal references to examples. Unresolved records may have none. |
| `questions` | Stable question `id`, explicit `question`, and downstream story IDs in `blocks`. Those dependencies may block later implementation, not this bounded documentation story. |

“Documented” does not mean independently verified against the ST executable.
Integer division in MOVE-001 is supported by the source's formula and its stated
initial result (Speed 13 gives rate 6); the page does not separately define signed
division behavior. Negative values remain unresolved. Walking units are relative
in MOVE-001; assigning them a per-real-second scale belongs exclusively to MOVE-002.

Fixtures contain `id`, `rule_id`, `evidence`, `source_indices` (zero-based indices
into the rule's sources), `inputs`, `expected`, `derivation`, and `unknowns`
(question IDs from that rule). Top-level `documented` and `adaptations` arrays keep
historical and reconstruction examples separate. Symbolic effect cases specify
outcomes and preconditions; they do not prescribe runtime object layouts.

## Effect contract

The archived [technical notes](../assets/documentation/kroah-city-st-v2/technicalNotes.html)
describe entities holding zero or more effect templates and activation copying
templates into an active list. Our terminology distinguishes an **entity
definition**, its ordered **effect definitions**, the entity receiving an event,
and each **active effect instance**. These are design names, not a claim that the
original engine used immutable definitions or globally unique IDs. A future
runtime must retain enough origin information to distinguish a definition from
its active copies; allocation and persistence identifiers are follow-up design.

EFFECT-001 records the documented active-index linkage: initial FF becomes the
instance's active-list index; initial 00 takes the previous entity effect's active
index, usually linking a text effect to a non-text effect. This index is not a
stable definition ID, and reuse/capacity are unknown.

EFFECT-002 records event handling: set entity events are handled and then cleared.
Get, Drop, Use/Cast, Unuse and Delete are named; uncertain event bits retain their
uncertainty. The source describes removing active effects for the opposed event
and activating listening templates. That prose supports the local lifecycle,
but does not establish every opposed pair, simultaneous-bit priority or complete
scheduler ordering. Do not turn a guessed Use/Unuse pairing into a fixture fact.

The effect H flag disallows multiple instances by comparing the eight documented
fields, not by entity name or definition ID. On a match, the current and all
following definitions are not activated. This activation gate does not establish
general additive stacking, replacement, refresh, or modifier rollback semantics.
The fixture preserves the source spelling `Gab` for its comparison field.

Counters, initial timer, repeat interval and natural cure are separate quantities.
The source says timer zero decreases the counter and executes the effect, resets
the timer with the interval, and checks natural cure on execution. Counter zero
means no removal by execution. It does not mean immunity to opposing-event or
other removal. Timer units and exact cure/execution/deactivation order remain
unknown; no runtime expiry policy is introduced here.

### Worked lifecycle

Consider a symbolic entity E with a listening definition A, and an active copy B
whose event is already known to oppose the received event. Opposition is a
precondition, not a newly asserted mapping.

1. An entity event is set and forwarded to E's definitions.
2. B is removed and A is eligible for activation under the described lifecycle.
3. If activation is permitted, A is copied into the active list; A remains its
   template. An initial FF active index receives the allocated list index.
4. Event handling finishes and the entity event is cleared.

These outcomes are the `EFFECT-COPY` and `EFFECT-EVENT` fixtures. They intentionally
do not specify a simultaneous second event, a timer tick, an undo of B's previous
stat changes, or a concrete opposing bit pair. In the separate
`EFFECT-DUPLICATE` case, flag H and an existing eight-field match suppress A and
all later definitions. This is sourced control flow, not a new stacking policy.

## Current coverage and handoff

| Rule | Coverage | Follow-up |
| --- | --- | --- |
| STAT-001 | Partial integer Speed fields; no full fractional/base/effective/display model | S08: representation, signed rounding, bounds, recomputation, delusion; S09/S10: modifier composition. |
| MOVE-001 | Nonnegative integer rate formula and cap implemented | S08: lower-domain behavior; S03: original distance/time calibration. |
| MOVE-002 | Adaptation implemented in both chapters | S03: measure tile timing separately for City and Dungeon; retain explicit adaptation until established. |
| TIME-001 | Ordinary conversion implemented | S03: pause policy, precision, calendar and service acceleration; S09: scheduler/metabolism ordering. |
| EFFECT-001 | Not implemented | S10/S08: definition/instance identity, linkage and capacity. |
| EFFECT-002 | Not implemented | S10: event meanings/opposition and linked removal; S03/S09: timer units and scheduling; S08: modifier removal/stacking semantics. |

Current `effective_speed()` clamps to zero; the primary-stat section does not
establish that clamp. `tile_travel_seconds()` uses a denominator safeguard at
zero speed, while actual travel is prevented. Neither implementation detail is
promoted to original behavior. No runtime or persisted fields change in S01.

## Adding and validating rules

Read the selected edition's archived HTML, especially tables. Archive any newly
used source unchanged and catalog its provenance before referencing it. Write
analysis separately. Add the narrow rule, precise source locators and uncertainties;
derive expected examples directly from the evidence. Record an adaptation
separately if implementation makes a choice beyond the source. Review formulas,
units, source claims and example arithmetic manually.

From the repository root, using Python 3.10 or later:

```text
python tools/validate_rule_catalog.py
python -m unittest discover -s tests -p test_rule_catalog.py -v
```

The validator checks shape, IDs, evidence classes, local paths, archive catalog
hashes, adaptation links and reciprocal fixture/source/question references. It
reads files only and does not run the game or implement gameplay formulas. Its
negative tests corrupt in-memory copies, never archived sources. It cannot prove
that prose or a formula faithfully interprets a locator; evidence review remains
required. S01 delivers the contract foundation, not completion of F01.

S28 follow-up: [runtime contract](EFFECT_RUNTIME_CONTRACT.md), [decision ledger](../data/reference/effect_contract.json) and [trace fixtures](../tests/fixtures/effect_traces.json). Existing question records link to their dispositions; unresolved findings remain unresolved.
