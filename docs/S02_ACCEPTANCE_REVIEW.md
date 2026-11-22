# S02 — Persistence implementation and acceptance evidence

Implemented 2026-11-22 on `codex/f02-f03-sprint`. Automated acceptance passes; user playtest and feature-level acceptance/merge remain pending. This does not close F02 or F03.

## Production save version 8

Version 8 adds `gameplay_random` to version 7. Versions 3–7 remain readable. The separate prototype's v1/v2 format is unchanged.

| Fields | Validation and migration |
| --- | --- |
| version/map_set | Integer 3–8; exact original-route-1 map identity |
| chapter/position/facing | Known chapter string; two finite integral coordinates 0–63 with a real map cell; facing 0–3. Bounds checked before Vector2i conversion |
| character | Existing CharacterStats schema, finite bounded stats/currency, supported optional fields and unknown extensions retained; neutral stat_display normalized on load |
| inventory | Array of strings |
| flags/doors | Dictionaries of booleans; visited_dungeon and returned required. Existing door-key representation retained |
| needs/provisions | Required hunger/thirst and food/water; integral nonnegative values, needs at most 100, provisions at most 9e15 (exact JSON range). Extra fields are validated before conversion |
| weather_seed | Integral 1–2147483646; existing absent-field default 1701 retained |
| minutes/minute_fraction | Integral minutes 0–150000000; optional fraction defaults zero, finite in [0,1) |
| clock | Required from v5; versioned timestamp/remainder must match compatibility time fields. v3/v4 retain existing migration |
| effects | Required from v7; existing effect validation/identity/deadline rules. Reject effects attached to earlier versions |
| gameplay_random | Required in v8: exact format godot-4.5-pcg32-v1 and canonical signed-64-bit decimal strings for seed/state. Reject unknown format, overflow, non-string state or downgraded payload |

v3 retains its existing neutral needs/provisions and zero silver/copper migration. v3–7 initialize the missing gameplay random stream with seed 1701; old unsaved random outcomes cannot be recovered. New journeys receive a fresh seed. Seed and continuation state are stored as strings to avoid losing bits through JSON numeric conversion. Restore seed before state. Replay is supported with the Godot 4.5 generator, not promised across arbitrary engine upgrades.

OriginalWorld validates detached candidates and commits once. Rejected loads preserve live clock, character, effects, random state, world fields, revision and journal. Save validates serialized state before opening a temporary file. Cosmetic lightning/audio, preferences and session weather override remain outside saved gameplay state. Random-facing Dungeon transitions alone consume the new stream; fixed and preserve-facing transitions do not.

## Save transaction and recovery

`journey_save_store.gd` writes and flushes a sibling `.pending` file, checks errors and rereads bytes, then preserves the existing destination as `.previous` before publishing the new file. Godot's Windows rename implementation removes an existing target before moving, so direct replacement would risk losing the previous save.

- Write or preserve failure: destination remains unchanged; pending data is discarded where possible.
- Publish failure: restore previous destination. If rollback fails too, `.previous` remains loadable through the normal load path.
- Interruption after preserving destination: load uses `.previous` only when destination is absent. It never promotes `.pending`.
- Successful publish: destination wins; previous backup is removed where possible. A leftover backup after cleanup failure is harmless and is replaced on a later successful transaction.
- Next save recovers a missing destination from `.previous` before writing new data. A malformed existing destination is rejected, not silently replaced by an older backup.

Single-writer local-file contract. This is recoverable process-interruption protection, not a guarantee against physical disk failure, concurrent writers or power loss: engine flush does not provide a directory durability guarantee. Do not launch two copies against the same save directory.

## Verification

- New `test_persistence.gd`: **128 checks, zero failures**. Full round trip; real random transitions and replay despite global random draws; repeat reload; fixed/preserve links; malformed/missing/truncated inputs; v3–7 migration; invalid live state; partial-write, preserve, publish and rollback failures; unwritable temporary target; interruption recovery and cleanup.
- Existing model suites: journey effects 70, clock 44, stats 99, effect definitions 29, instances 41, events 233 and timing 157 checks all pass. Tavern and legacy world suites pass.
- Integrated suites: clock scene 21, stats scene 8, effect keyboard scene 10 checks pass. Original route, full Dungeon tour, hold movement, weather, City environment and legacy scene pass.
- **840 counted checks**, plus the pass/fail integration suites above. Full Dungeon tour retains its previously documented resource-in-use warning at process exit; no gameplay assertion failed.

All runs use the isolated worktree's `tools/appdata` rather than the player's save location. Legacy test fixtures now explicitly omit the v8 payload when representing earlier save versions. No gameplay formulas or original source assets changed.

## Manual follow-up

The previous F01 user playtest is still Not run. Continue using its original folder. For a later S02 build, use an isolated save directory: save and reload an active Physical Speed effect, repeat loading, traverse a Dungeon transition, restart and load again. Record exact build and outcome. Never edit the user's real save to test malformed files; automated fixtures cover that.

## Engine references

Consulted Godot 4.5 [RandomNumberGenerator documentation](https://docs.godotengine.org/en/4.5/classes/class_randomnumbergenerator.html), [DirAccess documentation](https://docs.godotengine.org/en/4.5/classes/class_diraccess.html) and [Windows rename implementation](https://raw.githubusercontent.com/godotengine/godot/4.5-stable/drivers/windows/dir_access_windows.cpp). These support engine behavior, not historical game rules. Archival request failed DNS; catalog records URLs without claiming local copies.
