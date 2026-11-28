# Incremental movement and Speed

Implemented 2026-11-17. References are the unchanged local Atari ST City v2.0 extracts in `assets/documentation/kroah-city-st-v2/characterStats.txt` (Walking Speed) and `world.txt` (Time). Their original URLs and hashes are in the documentation catalog.

Verified rules: initial base Speed 13; effective Speed determines walking rate with integer formula `((Speed + 5) / 6) * 2`, capped at 36; continuous time at 15 times real time. The current integer Speed field supports bonuses and penalties; full character stat progression, fractional base stats, equipment and weather penalties remain future work.

Calibration: six walking units per tile is a reconstruction choice, not a measured ST engine constant. At effective Speed 7/13/25, walking rates are 4/6/10 and tile durations are 1.5/1.0/0.6 real seconds. Those cost 0.375/0.25/0.15 game minutes respectively. The same policy currently applies to the Dungeon. Turning is still in quarter turns.

Controls: tap for one animated tile; hold for successive tiles; H switches hold/classic input without changing Speed. Releasing completes the active tile. Turn, interact and save once centered. Tab shows a live map with a fractional player marker. C pauses simulation with the chapter overview; losing app focus pauses too. Menus otherwise remain live, so an order may expire when its stock hour changes.

Validation: `tests/test_hold_movement.gd` covers fractional position/camera, release, hold, frame stalls, map, pause/focus, Speed tiers and penalties, zero/capped Speed, continuous clock, fractional save/load, classic mode, walls and automatic transitions. `tests/test_original_route.gd` drives complete animated taps through the City/Dungeon round trip. Existing directional-door, service, weather and persistence regressions remain relevant.

For scripted tests set `world.character.speed`, `speed_bonus`, and `speed_penalty`; do not adjust the input repeat timer to simulate character Speed. Weather effects remain cosmetic until exposure/equipment rules are implemented.
