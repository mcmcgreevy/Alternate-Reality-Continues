# Code guide

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
| 8–12 | Unsupported barred/locked mechanisms; remain blocked. |
| 13–15 | Impassable faces under current rules. |

City code 29 is an exterior tavern door in the imported data. It is examinable only when it leads into the implemented Tail of the Dog footprint; other establishments remain unimplemented. Service cells are route destinations, not street shortcuts. See `ST_LOCATION_CORRECTION.md` for verified coordinates.

Door state keys include chapter, cell coordinates **and facing**. Opening one face must not automatically open its opposite: the source contains asymmetric passages.

`data/maps/dungeon_links.json` describes automatic arrival transitions. `find_route()` searches through their resulting positions but preserves each entry cell for guide arrows. `revision` changes when doors, automatic transitions, chapter crossings or loaded state invalidate geometry. The renderer also rebuilds when the player leaves its cached neighborhood.

## Three clocks

- **Simulation minutes:** `world.minutes` is absolute time since day one. Successful steps, services and waiting advance it. Turning and render frames do not. Needs count crossed intervals, while weather derives its hourly selection from this clock and a saved seed.
- **Frame seconds:** `_process(delta)` animates rain/torches and schedules held keys. A delayed frame can produce at most one repeated action, never a burst of catch-up steps.
- **Audio seconds:** the synchronized audio playhead drives lyric cues and song progress. Moving the simulation clock does not seek the song.

Hold movement routes through the same action handler as a tap. A release, fresh key, focus loss, blocked step or transition cancels it. The map allows movement; tavern and modal menus do not. Interactions and purchases are never repeated by the hold timer.

## State and persistence

`user://original_route.json` is the current journey save. Version 3 migrates to the version 4 fields with neutral needs and no provisions. Version 4 saves without weather retain compatibility through a fixed fallback seed. `load_game()` validates a temporary dictionary before assigning live state; keep that ordering when adding fields.

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
