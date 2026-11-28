# Dungeon distance rendering follow-up

2026-11-28. User reported successful save/load after restart and improved movement. Their screenshot shows visible SPD and a bright corridor gap at WEST / 63N 50E, corresponding to internal Dungeon cell (49,1), facing 3.

## Cause and correction

Reproduced with Godot 4.5.1 Compatibility/OpenGL on the actual rendering backend. Environment background was already black, yet the assigned City sky still appeared through the end of the finite geometry. The previous environment-property tests passed while the rendered view remained wrong.

Keep the City Sky resource for reuse, detach it from the environment indoors, and reassign it outdoors. Background/fog darkness remains in place. This changes presentation only; save data, movement and map geometry are untouched.

## Verification

- Real GPU-rendered corridor captures at minutes 360, 720, 1380: central 16x16 gap pixels remain below 0.02 in every RGB channel. A nearby geometry sample remains visible, guarding against a blank-frame false pass.
- City sky resource is restored on outdoor return.
- Existing environment/clock/ceiling/save-restore regression passes. Its exit retains a resource-cleanup warning; no assertion failed.
- New regression: `tests/test_dungeon_distance_render.gd`, run without `--headless`. Optional `-- --capture` writes ignored reference screenshots. A headless invocation fails explicitly rather than claiming rendered verification.

[Verified noon capture](playtests/dungeon-distance-fixed.png).

## User confirmation

Close the old game instance, relaunch the sprint checkout with Play-Sprint.cmd, load the existing save and look down the reported corridor. The distant opening should be black. Return to the City to confirm outdoor sky. No need to rerun the successful save/load or movement tests. Manual confirmation of this final fix remains pending; no merge or release is claimed.
