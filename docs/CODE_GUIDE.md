# Code guide

Rule/effect work starts with [RULE_MODEL.md](RULE_MODEL.md), the development-only
[six-rule catalog](../data/reference/rules.json), and
[source-derived examples](../tests/fixtures/rule_examples.json).
[validate_rule_catalog.py](../tools/validate_rule_catalog.py) checks provenance
and references without running gameplay; `data/reference/.gdignore` keeps the
catalog out of game imports. This contract does not add a runtime effects engine.

Before changing City mechanics, consult [the canonical ST source baseline](SOURCE_BASELINE.md). Existing prototype behavior and tests describe current implementation; they do not override the selected historical reference. Reconcile affected tests deliberately when adopting documented ST behavior.

Start with `project.godot`, which opens `scenes/main.tscn` and attaches `scripts/main.gd`. The current game uses imported City/Dungeon geography. The older invented-map prototype remains a separate regression fixture; it is not the default scene.

## Responsibilities

| File | Owns |
| --- | --- |
| `scripts/main.gd` | Keyboard routing, held-key cadence, tavern menus, map/guide, HUD and foreground rain. |
| `scripts/original_world.gd` | Authoritative current-game state, directional passage rules, transitions, services, game clock, weather schedule, pathfinding and save/load. |
| `scripts/world.gd` | Shared character fields and cardinal step/turn helpers; also contains the legacy prototype's map and rules, overridden by OriginalWorld. |
| `scripts/original_view.gd` | Local 3D geometry, camera placement, ceilings, weather/daylight lighting and source-edge visualization. |
| `scripts/first_person.gd` | Shared camera, materials and geometry helpers; its default build method renders only the legacy prototype. |
| `scripts/atmosphere_materials.gd` | Deterministic generated surface textures and normals. |
| `scripts/city_sky.gdshader` | Day/night sky, stars, cloud detail and overcast shading. |
| `scripts/weather_effects.gd` | Outdoor ambience crossfades, cosmetic lightning and delayed thunder; independent real-time storm clock. |
| `scripts/tavern_music.gd` | Synchronized full/instrumental streams, playback-timed captions and independent audio preferences. |
| `scripts/prototype_main.gd`, `scripts/legacy_tavern_music.gd` | Legacy controller and synthetic music used by `scenes/prototype.tscn`. |

The controller asks the world to act, then the renderer reads the result. Views do not copy character state, decide passability through physics, or award items. Terrain meshes are decorative representations of the map rules.

## Coordinates and source data

Map indices use X increasing east and Y increasing south. Direction indices are **0 north, 1 east, 2 south, 3 west**, matching the order of every cell's `edges` array. The displayed handbook coordinates are converted separately by `coordinates()`; City and Dungeon labels use different offsets.

Source-map edge codes are retained rather than renumbered. Current support groups are:

| Codes | Current treatment |
| --- | --- |
| 0, 1, 2, 7 | Traversable boundary. |
| 3, 4 | Door requiring examination/opening before movement. |
| 5, 6 | Concealed boundary requiring examination. |
| 8â€“12 | Unsupported barred/locked mechanisms; remain blocked. |
| 13â€“15 | Impassable faces under current rules. |

City code 29 is an exterior tavern door in the imported data. It is examinable only when it leads into the implemented Tail of the Dog footprint; other establishments remain unimplemented. Service cells are route destinations, not street shortcuts. See `ST_LOCATION_CORRECTION.md` for verified coordinates.

Door state keys include chapter, cell coordinates **and facing**. Opening one face must not automatically open its opposite: the source contains asymmetric passages.

`data/maps/dungeon_links.json` describes automatic arrival transitions. `find_route()` searches through their resulting positions but preserves each entry cell for guide arrows. `revision` changes when doors, automatic transitions, chapter crossings or loaded state invalidate geometry. The renderer also rebuilds when the player leaves its cached neighborhood.

## Three clocks

- **Simulation time:** `game_clock.gd` owns integer game microseconds; `minutes` and `minute_fraction` are compatibility views. Ordinary frames, accelerated services and explicit costs share one advancement path. Overview/focus loss pause; map/tavern menus stay live. See S03 below.
- **Frame seconds:** `_process(delta)` advances simulation and travel, then updates camera, weather and HUD. Travel stops processing at one arrival per frame, discarding excess movement delta after a stall while the clock still accounts for elapsed time.
- **Audio seconds:** the synchronized audio playhead drives lyric cues and song progress independently; pausing simulation does not seek or pause the song.

### Speed and incremental travel

`effective_speed()` combines character `speed` (default 13), `speed_bonus` and `speed_penalty` (default zero). `walking_speed()` implements ST integer arithmetic: `min(36, ((effective_speed + 5) / 6) * 2)`. Speed remains hidden from the player as in the starting original character. Equipment and weather do not yet populate the modifiers.

The reference does not establish walking units per tile. `WALKING_UNITS_PER_TILE = 6` is an explicit reconstruction calibration: initial Speed crosses one tile in one real second. Lower Speed takes longer and therefore costs more game time for the same distance. This scale is tunable without changing the documented relative rates. The City formula is also applied to our Dungeon exploration as an adaptation, not a verified Dungeon rule.

`begin_travel()` validates the source face before starting. `travel_position()` exposes the fractional position to both the 3D camera and map marker. The authoritative integer `position` changes only at the destination center, when arrival links and tavern entry resolve once. Opposite boundary faces remain independent. A tap completes one stride; release prevents further strides. Turns and interactions require a settled cell and are not queued mid-stride. Holding starts the next stride immediately after arrival; turning retains its separate repeat delay. Zero walking Speed blocks travel. Direct model `move()` calls use the same calculated duration; animated arrival commits without charging that time twice.

See [MOVEMENT.md](MOVEMENT.md) for calibration and testing.

## State and persistence

S02 production saves now use version 8, retaining v3–7 readers. `OriginalWorld.save_snapshot()` describes persisted state; `_validated_save()` builds detached candidates used by both save and load. `journey_random.gd` owns the dedicated Dungeon gameplay stream and lossless seed/state encoding. `journey_save_store.gd` owns checked temporary writes, previous-save preservation and interrupted replacement recovery. See [S02 acceptance and schema](S02_ACCEPTANCE_REVIEW.md) for exact boundaries and failure behavior. These are remake persistence choices, not recovered original save layout.

`user://original_route.json` is the current journey save, now version 8 with precise clock, stat, effect and gameplay-random state. Versions 3–7 preserve elapsed time on migration; see S03 below. Version 3 migrates to the version 4 fields with neutral needs and no provisions. Version 4 saves without weather retain compatibility through a fixed fallback seed. `load_game()` validates a temporary dictionary before assigning live state; keep that ordering when adding fields.

Saves are accepted only at tile centers; mid-stride requests return `ERR_BUSY`. Successful loads reset transient travel state after validation; rejected loads leave it untouched.

Movement preferences live in `user://controls.cfg`, and audio preferences in `user://music_settings.cfg`. They are intentionally independent of journey saves. The legacy prototype uses `user://journey.json` with its own versions and coordinates.

JSON field names, resource paths and public state fields are interfaces used by scenes, tests and saved games. A naming cleanup should not casually rename those persisted keys. Short mathematical axis names such as X/Y remain appropriate; use explicit names for positions, boundary codes, monetary amounts and timestamps whose meaning otherwise needs guessing.

## Services, audio and deferred systems

Tavern purchases revalidate the quoted menu hour before charging, so an old confirmation cannot buy an unavailable item. Currency calculations use copper, then split the remaining balance into gold/silver/copper. Service duration advances needs before the purchased relief is applied. These numerical rules are provisional; see `TAVERN.md`.

Music runs full and no-lead mixes on a single playback clock, with one muted. The isolated lead vocal must not be added to the already complete mix. Cue intervals include their start and exclude their end. Blank intervals intentionally show no captions; timing remains subject to listening review.

Weather is presentation-only. `weather_exposure()` exposes inputs for later character/equipment work without mutating stats. Required cold/fatigue/speed, heat/thirst and clothing protection dependencies are documented in `WEATHER.md`. When adding effects, integrate over elapsed simulation time, not rendering frames.

F6 cycles a session-only weather override through the five conditions and back to Auto. All consumers use `weather_at()`, keeping visuals and exposure inputs consistent. The override survives journey loads within the session but is not serialized; it never changes the saved seed or advances time.

## Build and research tools

| Tool | Purpose and output |
| --- | --- |
| `tools/publish_github_backlog.py` | Publishes the reviewed local backlog as repository issues, milestones and native sub-issue links. Reuses stable IDs on reruns; reads Git credentials only into memory and writes the public issue mapping to `docs/GITHUB_BACKLOG_INDEX.json`. Does not create a GitHub Project. |
| `tools/import_dungeon_maps.py` | Restricted data-only assembly reader; verifies upstream SHA-1 payloads before exporting map data. |
| `tools/build_original_route.py` | Combines verified Dungeon segments and local ARX City records into `data/maps/`, preserving original transition/edge evidence. Requires the ignored ARX reference checkout. |
| `tools/audit_map_sources.py` | Inventories source hashes and evidence anchors; it does not infer gameplay rules. |
| `tools/prepare_tavern_audio.py` | Copies selected WAV masters to ignored local storage, encodes game Oggs, checks alignment and writes the production manifest. Requires the configured Downloads files and soundfile environment. |
| `tools/generate_weather_audio.py` | Reproducible synthesized breeze/wind/rain loops and thunder variants, with asset checksums and decoded-level validation. |
| `tools/transcribe_tavern.py` | Historical unverified note/MIDI audition experiment; not the approved soundtrack pipeline. |

Do not rerun asset-generation scripts just to check formatting; they write outputs. Runtime assets belong under `assets/art` and `assets/audio`. Archived source documentation belongs in `assets/documentation` with provenance; `.gdignore` excludes that library from game imports. Downloaded tools, masters and analysis experiments under `tools/reference` are local working material, not runtime dependencies.

When verifying generator refactors, redirect `build_original_route.OUT` to a temporary directory and compare parsed JSON with `data/maps`. Raw assembly-file SHA-256 metadata is sensitive to Windows CRLF versus LF checkout conversion; distinguish that from a change in assembled payloads or generated cells/links. The readability-pass comparison found identical gameplay data and a raw-source hash difference explained by line endings; production map files were not regenerated.

## Verification

Use the portable Godot 4.5.1 console executable with `--headless --path . --script tests/<test>.gd`:

| Test | Main coverage |
| --- | --- |
| `test_original_route` | Actual scene, directional boundaries, full round trip, shared state and music. |
| `test_dungeon_level_one` | Quadrants, original passage links and saves. |
| `test_hold_movement` | Repeat timing, live map navigation, releases, focus and transition cancellation. |
| `test_tavern` | Transactions, menu changes, needs and save migration. |
| `test_tavern_music` | Matching assets, uninterrupted switching, looping, captions and preferences. |
| `test_city_environment` | Sky/daylight, roofs, clock and restoration. |
| `test_weather_effects` | Ambience selection, thunder delay, mute, shelter and condition-change cancellation. |
| `test_weather` | Conditions, exposure/shelter, persistence, old saves and weather rendering. |
| `test_world`, `test_scene` | Legacy state and scene regressions, including shared renderer helpers. |

For shader/rendering changes, run the relevant capture test without `--headless`; headless tests alone do not exercise the GPU shader. `test_weather.gd -- --capture` creates a rain screenshot. In restricted environments set `APPDATA` to the project's ignored `tools/appdata` before running Godot.

S28 adds the [bounded effect runtime contract](EFFECT_RUNTIME_CONTRACT.md), a source-linked decision ledger and classified event/timer traces. These are research inputs, not a runtime engine; S29â€“S31 readiness gates are explicit.


## S29 non-timed effect lifecycle

Three unwired RefCounted modules separate definitions, owners and active copies:

| Module | API and responsibility |
| --- | --- |
| `scripts/effect_definitions.gd` | `register_definition`, `definition_snapshot`, `check_duplicate_gate`: immutable registry and source eight-field H comparison. Raw values are opaque comparison evidence, not executable addresses. |
| `scripts/effect_instances.gd` | `activate_sequence(owner_id, entries)`, `remove_group`, `remove_owner`, `snapshot`: independent active copies, group linkage, global H suppression and explicit scoped record removal. |
| `scripts/effect_events.gd` | `register_entity(owner_id, listeners, initially_held=false)`, `queue_events`, `dispatch_pending`, `entity_snapshot`, `active_snapshot`: owner lifecycle and pending event dispatch. |

Definitions contain `definition_id`, `definition_revision`, `disallow_multiple` and the eight-field `comparison`. Instances own a deep copy plus `instance_id`, `owner_id` and `group_id`. All snapshots are deep copies. Sequence entries contain `definition_id` and boolean `link_to_previous` (FF=false, 00=true). The first linked record becomes a group root; later linked records join the latest activated group in this call. Calls never inherit a prior group. IDs are monotonically increasing per store and never recycled; they are not original slot numbers.

Listeners contain `definition_id`, `required_events` and `link_to_previous`. Get=1, Drop=2, Use/Cast=4, Unuse=8 are allowed listener bits, singly or combined. Delete=16 is a terminal event, not a listener bit. Unknown bits, zero masks, malformed fields, unknown definitions, duplicate owner IDs and non-boolean held state fail before mutation. Queued masks must be integers (no float/string/bool coercion). Pending masks coalesce repeated bits.

Dispatch captures/clears bits, then processes Get, Drop, Use, Unuse, Delete. Get sets held; Drop is skipped if unheld and otherwise clears held. Get/Drop and Use/Unuse oppose each other. For each ordinary event, remove the owner's groups containing a listener for the opposing bit, then select matching listeners in definition order and activate. Bindings retain listener masks, not just the event that activated them; a listener for both bits can oppose itself. The H gate sees every owner's active copies plus this call's successful prefix. A match preserves that prefix but suppresses the current and all following selected entries.

Delete removes all of this owner's records and leaves an inert tombstone with no pending bits. Repeating Delete succeeds without action; other events and reuse of a deleted owner ID fail. Owner identity, explicit listener/group bindings, tombstones, non-recycled IDs and atomic input rejection are reconstruction architecture. They avoid unresolved raw-byte lookup and stale-reference hazards without asserting byte-for-byte original behavior. Removal never executes arithmetic or reverses stat changes.

Registration and queue validation precede mutation. Dispatch runs synchronously without callbacks against immutable, prevalidated definitions; no failure-capable external operation occurs after pending bits clear. There is no reentrancy or timer/event tie policy here. Generic owners have no inventory/floor/stackable or special-use hooks. Binary long-text layout, original fixed slot capacity, timed state, action decoding, serialization and gameplay wiring are deferred to their owning stories. This is not a native memory interpreter.

### S29 verification and research

`tests/test_effect_definitions.gd` has 29 checks; `test_effect_instances.gd` has 41; `test_effect_events.gd` has 233, including ten cases from `tests/fixtures/effect_lifecycle_traces.json`. They cover ownership/isolation, linkage, all five events, pending state, first-00, global suppression, ordered opposition and atomic rejection. Run each through the portable headless Godot command above. The acceptance review is in `docs/S29_ACCEPTANCE_REVIEW.md`.

`tools/extract_s29_st_evidence.py` reads the pinned archived STX candidate, verifies the loader checksum and extracts decoded records under ignored `tools/reference/s29-verified/`. Optional Capstone 5.0.9 disassembly recognizes inline engine dispatch words. `tools/probe_s29_st_effects.py` uses Unicorn 2.1.4/M68000 to execute 13 isolated original-code scenarios with synthetic RAM. Captured evidence is `tests/fixtures/s29_st_probe_results.json`. These establish bounded observations, not a full-game playthrough or timer-unit mapping. See `docs/S29_ST_EFFECT_RESEARCH.md` for provenance and discrepancies.

## S32 timing research tools

`tools/extract_s32_st_timing.py` generates focused clock, scheduler and service listings from the checksum-verified S29 modules, checking five module hashes. `tools/probe_s32_st_timing.py` executes 18 unchanged-code scenarios with synthetic RAM using the existing Unicorn dependency. It observes bounded fragments rather than replacing engine/OS calls. Captured results are `tests/fixtures/s32_st_timing_results.json`; reproduce commands, domains, approved normalization and limits are in `docs/S32_ST_TIMING_RESEARCH.md`. These tools do not implement production timing. S03-CLOCK and S08-SPEED still gate S30.

## S03 shared clock and calendar

`game_clock.gd` owns integer game microseconds and the real-conversion remainder. `world.gd` exposes legacy `minutes`/`minute_fraction` views; OriginalWorld selects the ST 06:00 start, calendar labels and one advancement path for explicit costs, ordinary frames and accelerated services. `game_time_advanced(start, end)` supplies S30 with timestamp intervals before counting needs boundaries once; reentrant time advancement is rejected. The calendar uses twelve 31-day months, starting Sowings 29, Year 0. UI overview/focus loss pause; other active menus remain live. Version 5 saves preserve precision and validate before commit; versions 3/4 migrate existing elapsed time without resetting it. See `docs/S03_CLOCK.md` for APIs, bounds, source/adaptation distinctions and the 65 focused checks in `test_game_clock.gd` / `test_clock_scene.gd`.

## S08 shared stat views and actions

`character_stats.gd` separates fractional primary base, aggregate bonus/penalty, integer effective, displayed and visibility state. OriginalWorld exposes `stat_snapshot`, `set_stat_base`, `set_stat_modifiers`, `set_stat_display`, secondary access and `apply_stat_actions`. The latter accepts only ordered byte Speed-bonus Add/Sub; it validates an entire batch before mutation and never performs removal rollback. Existing `needs` owns hunger/thirst; missing creation/secondary values stay uninitialized. The HUD consumes displayed values and reveals Speed only when flagged. Version 6 uses full-precision JSON and validates detached character state; versions 3/4/5 migrate without truncating base fractions. Source/representation boundaries, deferred producers and the 107 focused checks are documented in `docs/S08_STATS.md`.

## S30 timed-effect runtime

`effect_timing.gd` adds validated execution profiles, timestamped owner events, activation-relative deadlines and reusable scheduling slots over S29. Elapsed updates are transactional; S08 performs the only stat actions. `effect_clock_adapter.gd` previews S03 conversion and runtime work, commits effects before the world clock notification, and uses the existing needs update once. Callers must use that adapter consistently and rebind after character replacement; S31 owns controller/save wiring. No timer is driven by rendering or audio. See [contract and acceptance](S30_ACCEPTANCE_REVIEW.md) and `tests/test_effect_timing.gd` for ordering, supported domains and rejection behavior.

## S31 production effects and version 7 saves

`journey_effects.gd` owns trusted, revisioned Physical Speed content, atomic grant/activation and validation of its bounded saved shapes. `OriginalWorld` owns the runtime and routes every elapsed-time entry point through `effect_clock_adapter.gd`; its internal `_advance_clock_only` avoids recursion and duplicate needs updates. Save versions 7 and 8 require effect payload version 1; versions 3â€“6 migrate to empty effect state. Loading reconstructs trusted records without replaying Add5 and commits only after all world/effect validation passes. F7 is a debug-only input using production activation; F5/F9 use the ordinary save handlers. See [S31 contract/tests](S31_ACCEPTANCE_REVIEW.md) and [F01 closure](F01_ACCEPTANCE_REVIEW.md). The earlier S30 handoff described the pre-integration boundary.

Playtest presentation (2026-11-27): `original_world.gd` always includes SPD in the HUD as an approved remake choice, independent of the persisted reveal flag. `original_view.gd` removes sky contribution and fog illumination underground so finite geometry ends in black, restoring outdoor settings on return to City.

Dungeon distance follow-up (2026-11-28): `original_view.gd` retains a reusable City Sky resource but assigns it only outdoors. Detaching it indoors prevents the Compatibility renderer from drawing that sky beyond finite geometry despite black background/fog settings. `tests/test_dungeon_distance_render.gd` must run without `--headless`; it checks actual corridor pixels and City sky restoration.
