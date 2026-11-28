# Alternate Reality: The Way Back

A first-person Godot 4.5.1 prototype joining The City and The Dungeon with one character, inventory and world clock.

**Source of truth for City rules:** Atari ST City v2.0 as documented by Kroah, adopted 2026-11-16. See [the source baseline and reconciliation list](docs/SOURCE_BASELINE.md). Existing prototype systems are not yet fully reconciled; verified 8-bit Dungeon data remains the Dungeon baseline.

The default milestone follows original geography: **Tail of the Dog Tavern → northern City entrance → Dungeon level one → Tail of the Dog Tavern**. The tavern and northern Dungeon entrance are located against Kroah's ST map markers 16 and 49; route edges retain the imported geometry. All four Dungeon level-one quadrants use checksum-verified Atari data, including 50 original transition triggers. Other City districts remain provisional. The tavern features Grimthorn Redbeard and the user-selected recording of Hail and Welcome.

## Play

**F6** cycles playtest weather: Auto → Hot → Warm → Cool → Cold → Rainy → Auto. Forced weather holds until changed or restarted; shelter still applies. The header marks forced conditions as `Test`.

Double-click Play.cmd, or open project.godot in Godot 4.5.1 and press F5.

- **W/S:** forward/back. **A/D:** turn. Arrow keys also work; **Q/R:** strafe. Tap for one animated tile, hold for continuous successive tiles. Speed controls traversal time; releasing finishes the current tile. **H** toggles classic single-stride input and saves your preference. Turns and interactions require a completed stride. The live map tracks fractional movement. **C** and loss of application focus pause simulation.
- **In Tail of the Dog Tavern: 1** opens food/drink orders, **2** shows the excursion briefing, **3** leaves, **4** sits for five minutes. Movement keys do not move you around the establishment.
- **E / Enter outside:** examine/open the boundary ahead or use the entrance. Secret doors require examination too.
- **G:** route guide. **Tab:** map and route overlay.
- **V in the Dungeon:** cycle guide destinations northwest → southwest → southeast → City entrance. The optional tour uses original passages and transitions; it adds no shortcuts. See [level-one playtest](docs/DUNGEON_LEVEL_ONE.md).
- **B:** open food/drink orders in Tail of the Dog Tavern. Choose an item, then **Y/N** to order/cancel. **5/Escape** returns from the menu; **T** waits for the next hourly menu.
- **Space:** wait five minutes. **M:** mute. **C:** chapter registry.
- **F5/F9:** save/load. This map uses user://original_route.json, separate from old prototype saves.

Start in Tail of the Dog Tavern's interaction screen. Press 2 for the First Excursion briefing, then 3 to leave through the mapped south exit. Follow the guide. At the City entrance, face east and press E. At the Dungeon arrival cell, walk west into the corridor, save/load if desired, then return to the arrival point and press E to return to the City. Return to Tail of the Dog Tavern to finish. The return route differs because boundaries can be one-way. See [the playtest checklist](docs/FIRST_EXCURSION.md).

Time advances continuously at one game minute per four real seconds. Movement uses the ST effective-Speed formula; the initial character takes one real second per tile with our tunable distance calibration. See [movement mechanics](docs/MOVEMENT.md). Crossing adds five game minutes, meals fifteen, and drinks/provision purchases one; these service timings remain prototype rules. Hail and Welcome plays while visiting the tavern. **L** switches the lead vocal on/off without restarting; **K** toggles provisional subtitles; **M** mutes. Preferences persist independently of journey saves. Caption timing covers all supplied lyrics in the revised recording and remains an automatic pass pending listening review; see [music integration](docs/TAVERN_MUSIC_INTEGRATION.md).

Tail of the Dog Tavern now offers individual food, free water and provisions, with copper prices and change in gold/silver/copper. Food relieves hunger instead of restoring health. Menus change on the shared clock; sitting consumes carried provisions when needed. Needs are currently nonlethal. Old version 3 saves preserve their gold and migrate with neutral needs and no new provisions. See [tavern evidence and test cases](docs/TAVERN.md) for the distinction between documented services, provisional prices and simplified mechanics.

## Implementation and evidence

See the [code guide](docs/CODE_GUIDE.md) for module responsibilities, coordinates, clocks, save formats, source-map conventions and test coverage.

The current [visual study](docs/ART_DIRECTION.md) adds a painted tavern backdrop, a larger world view and higher-resolution Dungeon materials and lighting. It changes presentation only; existing saves and controls still work.

Outside in the City, hot, warm, cool, cold and rainy weather follows a saved random schedule on the shared clock. Cool has light breeze audio; Cold has stronger wind. Rain brings an overcast sky, reduced sunlight, haze, animated rainfall and rain audio, with occasional lightning flashes and delayed thunder. M mutes weather audio as well as tavern music. The status line shows the condition and whether you are sheltered. Interiors and the Dungeon suppress rain. Space waits five minutes; loading restores the weather and its future schedule. Weather has no stat penalties yet; see [weather implementation and stat dependencies](docs/WEATHER.md).

- data/maps/: directional boundaries, route and provenance hashes.
- data/tavern.json: menu items, prices, effects and provenance.
- scripts/original_world.gd: shared state, directional doors, transitions and versioned saves.
- scripts/original_view.gd: streamed first-person geometry from those same boundaries.
- scripts/main.gd: controls, map and guide; scripts/tavern_music.gd: synchronized full/instrumental playback and caption controls.
- [Source log](docs/SOURCES.md): shipped, planned and invented distinctions.
- [Reconstruction notes](docs/RECONSTRUCTION.md): evidence, reproduction and remaining fidelity work.

The invented brass-token slice remains in scenes/prototype.tscn as a regression fixture. Future chapter IDs are reserved without gameplay.

## Verify

Run the portable Godot console executable with --headless --path . --script followed by each of:

- tests/test_hold_movement.gd
- tests/test_original_route.gd
- tests/test_dungeon_level_one.gd
- tests/test_city_environment.gd
- tests/test_weather.gd
- tests/test_weather_effects.gd
- tests/test_tavern_music.gd
- tests/test_tavern.gd
- tests/test_world.gd
- tests/test_scene.gd

In a restricted sandbox, set APPDATA to the workspace's tools/appdata directory first. The original-route test drives the full scene through secret and asymmetric doors, save/load, both crossings and the return, checking shared character identity, inventory, clock and audio restart. Run it without --headless and add -- --capture for runtime screenshots in docs/original-*.png.

Combat, most original events, encounters, full survival, other shops and exact door mechanics are not implemented. Locked/bolted/enchanted passages remain blocked; floors below Dungeon level one are not enabled. Geography and original services come before new adventures and audio rearrangement.

## Development planning

[Backlog](docs/BACKLOG.md) · [Roadmap](docs/ROADMAP.md) · [GitHub planning proposal](docs/GITHUB_PLANNING.md). Draft scope follows Kroah’s menu; delivery order follows system dependencies.

## Physical Speed playtest (F01 complete)

In a debug build, **F7** activates Physical Speed through the production effect runtime and reveals Speed. It grants +5 for 30 game minutes; repeated F7 does not stack or restart it. **F5/F9** preserve the exact remaining duration without another grant. At ordinary speed, 40 focused real seconds equals 10 game minutes. See [the reproducible playtest and save migration notes](docs/S31_ACCEPTANCE_REVIEW.md). Guild acquisition and combat casting remain later work.
