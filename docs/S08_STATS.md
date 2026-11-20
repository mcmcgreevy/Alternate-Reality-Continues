# S08 — Primary and secondary stat model

Completed 2026-11-20 for the shared stat representation and action interface.
This is not completion of combat, metabolism, character creation or spell content.

## Evidence and boundaries

Canonical source: unchanged Kroah ST City v2.0 `characterStats.html`, Primary /
Sub-Stat and Secondary tables. SHA-256:
`607c3c371e9b13aaac840a7a57165af316f6d4f7808686a8da3fd69f875ed6f5`.
The byte-Speed Add/Sub behavior comes from the pinned candidate probes documented
in [S29](S29_ST_EFFECT_RESEARCH.md) and [S32](S32_ST_TIMING_RESEARCH.md). No new
historical source was downloaded or modified.

All seven primary names have separate base, bonus, penalty, effective, displayed
and visibility views. Effective is `int(base) + bonus - penalty`; reading a view
does not truncate stored base or roll randomness. Without a presentation override,
displayed equals effective. Speed defaults to the documented 13 and is hidden
until `speed_revealed` is set by the future Blue Wizards reward producer.
Other absent creation rolls remain explicitly uninitialized rather than receiving
invented starting values. S07 owns those rolls; existing Strength/Stamina values
remain prototype character inputs.

The source describes base as real and effective as integer, but this page does
not specify a complete original fixed-point storage layout. We preserve the
provided fractional value using Godot's double representation and full-precision
JSON. This is implementation architecture, not a claim of original binary-layout
emulation. General stat inputs have a defensive 0..1,000,000 domain; integral
bonus/penalty fields do not accept fractions. Speed bonus alone has the verified
0..255 byte domain. These general defensive limits are not historical stat caps.
Negative effective results are retained by the documented formula; movement
floors its derived walking rate at zero and caps it at the documented 36.

The secondary registry covers the source's general, metabolism and temporary
stat names, plus named magical protection/efficiency maps. Source damage label
Evil remains uncertain as marked in the archive; there is no invented numeric
damage-code mapping. Missing secondary state is uninitialized, not zeroed into
existence. HP/maximum HP retain integer storage; other supplied numeric secondary
values retain their fractions. Hunger/thirst use the existing `needs` store in
OriginalWorld, not a second authoritative value in `character`.

## APIs

`scripts/character_stats.gd` provides pure snapshots and explicitly requested
mutations of the supplied character dictionary. OriginalWorld exposes:

| API | Responsibility |
| --- | --- |
| `stat_snapshot(name)` | Base/effective/displayed/modifiers/visibility, or explicit unknown/uninitialized/invalid error. |
| `set_stat_base(name, value)` | Preserve a supplied fractional base; reject invalid input before writing. |
| `set_stat_modifiers(name, bonus, penalty)` | Set both aggregate channels together after validation; no automatic stacking or undo policy. |
| `set_stat_display(overrides)` | Replace a detached presentation map; empty map restores actual readings. Unknown names/invalid values reject the whole update. |
| `secondary_stat_snapshot(name)`, `set_secondary_stat(name, value)` | Named secondary access; world needs are routed to their existing owner. Walking speed is derived, not separately stored. |
| `apply_stat_actions(actions)` | Atomic, ordered batch of the bounded Speed actions below. |
| `displayed_hit_points()`, `primary_stats_text()` | HUD uses displayed readings; hidden Speed appears only after reveal. |

Presentation producers supply displayed values. The delusion section describes
random updates, but S08 does not invent its unresolved cadence/overflow details
or mutate stats from a read. Potion/spell producers in S10/S21, with timed support
extensions beyond S30's current slice, own those rules. The tests inject synthetic
display readings and do not claim a playable delusion effect. Metabolism and
combat/reward formulas remain with S09/S13 and the relevant downstream stories;
this story supplies the shared state/interface they consume.

## S08-SPEED contract for S30

Each command has exactly six fields:

```gdscript
{
    "target": "speed_bonus",
    "operation": "add", # or "subtract"
    "operand_width": 1,
    "block_count": 1,
    "block_gap": 0,
    "parameter": 5
}
```

Layout/parameter fields must be integers; parameter is 0..255. No raw addresses,
other targets/operations, wider writes, blocks, gaps, owner identifiers or extra
fields are accepted. The current Speed bonus must be a valid byte value. Validate
the entire batch before computing/committing the result; invalid trailing commands
cannot leave the preceding Add applied. An empty batch changes nothing.

Execute in caller-supplied order, without callbacks: Add saturates at 255; Sub
saturates at zero. Return `ok`, `before`, `after`, and the intermediate bonus
`trace`, or an error without mutation. Starting at 253, Add5/Sub5 yields 250;
Sub5/Add5 yields 253. Operations are deliberately not reordered or combined.

Each world supplies its own character dictionary. Item/spell owners within that
world intentionally affect the same character bonus. S29 owns H suppression and
owner/group removal; S30 owns scheduling and action dispatch. Removing a group
does not undo arithmetic. Repeated explicit Add commands apply repeatedly; this
API must not guess whether their activation should have been suppressed.
Physical Speed's Add5/Sub5 fixture verifies actions, not a running 30-minute spell.
S31 owns the normalized content schedule and timed save integration.

## Persistence and compatibility

Original-route saves use version 6, retaining existing flat base and modifier
field names. Optional `stat_display`, `speed_revealed` and secondary/protection
values travel with `character`. Full-precision serialization prevents a base just
below an integer from rounding up and changing effective stats on reload.

Versions 3/4/5 still load. Missing display state means actual readings; missing
Speed means base 13, bonus/penalty zero and hidden. No existing valid base fraction
is truncated. A detached candidate is validated before replacing the character or
clock. Invalid modifier ranges, fractional integer fields, malformed presentation
or protection maps reject the entire load; unsupported values are not clamped.
This does not persist an effect scheduler or replay activation.

## Acceptance review

- [x] Seven primary views separate fractional base, integer effective, displayed,
  aggregate modifiers and hidden Speed; actual stat consumers/HUD use the views.
- [x] Named secondary state and derived walking speed have explicit APIs and
  preserve the existing HP/needs ownership boundaries.
- [x] Typed Speed arithmetic matches the verified saturation/order fixtures;
  invalid batches are atomic and unrelated fields/characters are unchanged.
- [x] Effect removal performs no invented rollback; repeat arithmetic and
  activation suppression remain explicitly separate responsibilities.
- [x] Version 6 round trip, legacy migration and invalid-save rejection preserve
  fractions, modifiers, presentation, visibility and protection state.
- [x] Runtime/code/source notes and S30's readiness checklist are updated.

Validation: **99 stat checks and eight scene checks** pass, including fractional
save values immediately below an integer boundary. All **303 S29 lifecycle
checks** pass. Clock, tavern, movement, route and Dungeon-link regressions pass.
An isolated copy of the publishable changes also passes the 107 focused checks,
clock, tavern, route and held-movement regressions without the unfinished movement
work. The rendered stat panel was inspected with synthetic display/reveal inputs;
the source and actual gameplay values remained separate. Some existing scene
tests retain resource cleanup warnings at shutdown.

Run `tests/test_character_stats.gd` and `tests/test_stats_scene.gd` with the portable
Godot console and `--headless --path . --script`. The scene test's optional
`-- --capture` (without headless) writes `tools/reference/s08-stats.png`.

S08-SPEED is complete. S30's S29/S32/S03/S08 prerequisites are now met; S30 is
**Ready**, not started. F01 remains open for timed runtime and save integration.
