# Alternate Reality: The Way Back

A first-person Godot 4.5.1 prototype joining The City and The Dungeon with one character, inventory and world clock.

The default milestone follows original geography: **The Tavern → northern City entrance → Dungeon level one → The Tavern**. The City route is cross-checked against the original 8-bit handbook map. All four Dungeon level-one quadrants use checksum-verified Atari data, including 50 original transition triggers. Other City districts remain provisional. Artwork and music are original placeholders.

## Play

Double-click Play.cmd, or open project.godot in Godot 4.5.1 and press F5.

- **W/S:** forward/back. **A/D:** turn. Arrow keys also work; **Q/R:** strafe.
- **In The Tavern: 1** opens food/drink orders, **2** shows the excursion briefing, **3** leaves, **4** sits for five minutes. Movement keys do not move you around the establishment.
- **E / Enter outside:** examine/open the boundary ahead or use the entrance. Secret doors require examination too.
- **G:** route guide. **Tab:** map and route overlay.
- **V in the Dungeon:** cycle guide destinations northwest → southwest → southeast → City entrance. The optional tour uses original passages and transitions; it adds no shortcuts. See [level-one playtest](docs/DUNGEON_LEVEL_ONE.md).
- **B:** open food/drink orders in The Tavern. Choose an item, then **Y/N** to order/cancel. **5/Escape** returns from the menu; **T** waits for the next hourly menu.
- **Space:** wait five minutes. **M:** mute. **C:** chapter registry.
- **F5/F9:** save/load. This map uses user://original_route.json, separate from old prototype saves.

Start in The Tavern's interaction screen. Press 2 for the First Excursion briefing, then 3 to leave through the mapped north exit. Follow the guide. At the City entrance, face east and press E. At the Dungeon arrival cell, walk west into the corridor, save/load if desired, then return to the arrival point and press E to return to the City. Return to The Tavern to finish. The return route differs because boundaries can be one-way. See [the playtest checklist](docs/FIRST_EXCURSION.md).

Movement costs one minute, crossing five, meals fifteen, and drinks/provision purchases one. These timings remain prototype rules. Turning does not advance time. The original 16-second SID-style cue has playback-timed lyrics; it is not a transcription or modernization of the original music.

The Tavern now offers individual food, free water and provisions, with copper prices and change in gold/silver/copper. Food relieves hunger instead of restoring health. Menus change on the shared clock; sitting consumes carried provisions when needed. Needs are currently nonlethal. Old version 3 saves preserve their gold and migrate with neutral needs and no new provisions. See [tavern evidence and test cases](docs/TAVERN.md) for the distinction between documented services, provisional prices and simplified mechanics.

## Implementation and evidence

The current [visual study](docs/ART_DIRECTION.md) adds a painted tavern backdrop, a larger world view and higher-resolution Dungeon materials and lighting. It changes presentation only; existing saves and controls still work.

- data/maps/: directional boundaries, route and provenance hashes.
- data/tavern.json: menu items, prices, effects and provenance.
- scripts/original_world.gd: shared state, directional doors, transitions and versioned saves.
- scripts/original_view.gd: streamed first-person geometry from those same boundaries.
- scripts/main.gd: controls, map and guide; scripts/tavern_music.gd: synthesized cue.
- [Source log](docs/SOURCES.md): shipped, planned and invented distinctions.
- [Reconstruction notes](docs/RECONSTRUCTION.md): evidence, reproduction and remaining fidelity work.

The invented brass-token slice remains in scenes/prototype.tscn as a regression fixture. Future chapter IDs are reserved without gameplay.

## Verify

Run the portable Godot console executable with --headless --path . --script followed by each of:

- tests/test_original_route.gd
- tests/test_dungeon_level_one.gd
- tests/test_tavern.gd
- tests/test_world.gd
- tests/test_scene.gd

In a restricted sandbox, set APPDATA to the workspace's tools/appdata directory first. The original-route test drives the full scene through secret and asymmetric doors, save/load, both crossings and the return, checking shared character identity, inventory, clock and audio restart. Run it without --headless and add -- --capture for runtime screenshots in docs/original-*.png.

Combat, most original events, encounters, full survival, other shops and exact door mechanics are not implemented. Locked/bolted/enchanted passages remain blocked; floors below Dungeon level one are not enabled. Geography and original services come before new adventures and audio rearrangement.
