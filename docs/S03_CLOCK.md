# S03 â€” Calendar and shared elapsed time

Implemented and reviewed 2026-11-20. Canonical evidence is the unchanged archived
Kroah ST City v2.0 `world.html`, Calendar and Time Span; source SHA-256
`3c49f286cbceb272615fa7f8cbc3bec501da6bd7eedde17c2e14fe0b5a8e3214`.
See [S32 reconciliation](S32_ST_TIMING_RESEARCH.md) for executable evidence and
the approved decision to process all elapsed time instead of dropping updates.

## Rules and supported scope

New City journeys start at **Sowings 29, Year 0, 06:00**. Every month has 31 days,
every year twelve months; names follow the archived table. `calendar()` derives
year/month/day/hour/minute/second from the clock, including month/year rollover.
The ordinary rate is 15 game seconds per real second. Working/sleeping/learning
time uses 3600 game seconds per real second through the service adapter, 240
times ordinary speed. Paused time advances nothing and accumulates no backlog.

The current interface pauses on the chapter overview and application focus loss.
Map, tavern menus and other active screens remain live. These UI pause contexts,
the always-visible calendar, and carrying the City clock into the Dungeon are
remake choices, not claims about every original pause/menu screen. Music remains
independent. The source limits normal calendar access to inns/watch; the modern
HUD is an existing interface adaptation.

Full inn jobs/sleeping and guild-learning gameplay remain their own features.
S03 provides and verifies their callable accelerated clock adapter, without
inventing those services. Existing tavern/wait costs are already game minutes;
they are applied once and are never multiplied by either conversion rate.
Needs still use the provisional existing hunger/thirst rates owned by S09.

## API and precision

`scripts/game_clock.gd` owns a nonnegative integer timestamp in game microseconds,
measured since midnight at the start-date day, with 60,000,000 per minute.
The maximum is 9,000,000,000,000,000, below JSON's exact-integer limit. This finite
range and microsecond precision are reconstruction architecture. Negative,
nonfinite, unknown-mode and out-of-range input is rejected before mutation.

| API on OriginalWorld | Contract |
| --- | --- |
| `advance_game_microseconds(elapsed: int)` | Exactly partition-invariant elapsed input; returns `ok`, start/end timestamps and elapsed microseconds, or an error with unchanged timestamps. |
| `advance_real_seconds(seconds, mode="ordinary")` | Converts once; modes ordinary/accelerated/paused. Retains a fractional game-microsecond remainder across frames, pause, mode changes and saves. |
| `advance_service_seconds(seconds, paused=false)` | Same conversion path with accelerated/paused mode; future service callers must not also add an explicit time cost. |
| `advance_time(elapsed_minutes)` | Compatibility explicit-cost wrapper returning success; routes to the integer API. |
| `game_time_boundary()` | Current exact timestamp for scheduling an external event. |
| `game_time_advanced(start, end)` | One synchronous notification for each successful nonzero elapsed interval. S30 consumes this interval without reconversion; observers cannot reenter time advancement. |
| `calendar()`, `clock_text()` | Read-only calendar and compact HUD label. |

Floating real seconds are quantized to microseconds with remainder retention;
the integer game-time input is the deterministic partition contract. `minutes`
and `minute_fraction` are compatibility views of this one timestamp, not separate
clocks. Their setters support legacy tools/fixtures; gameplay must use advancement
APIs so consumers are notified. Direct timestamp assignment/load is not elapsed
time and intentionally emits no replayed interval.

World advancement emits the timestamp pair before counting crossed hunger/thirst
boundaries once, retaining effect-before-metabolism consumer order. Invalid input and zero elapsed emit no interval. Keyboard movement
gets elapsed time from `_process`; it cannot also charge a discrete movement
cost. Existing model-only movement compatibility remains separate from the
unfinished Speed/travel calibration work.

S30 must queue timestamped owner events **before** advancing across their boundary,
then order due work inside each received interval: earlier deadlines first,
owner events before timers at equal timestamps. The clock does not dispatch
effects or invent an implicit event queue. `game_time_boundary()` supplies the
current event timestamp; S30 owns splitting/ordering a large interval.

## Save compatibility

Original-route saves use version 5 with a versioned `clock` snapshot containing
the integer timestamp and fractional conversion remainder. Existing `minutes`
and `minute_fraction` names are retained as matching compatibility values.
Version 5 loads validate both representations before committing any live state.
Malformed, inconsistent or overflowing clocks reject the entire load.

Version 3/4 saves retain their existing elapsed minutes and optional fractional
minute; absent fractions/remainders default to zero. They are not reset to 06:00.
Their old day-one time is mapped to the canonical start-date day as an explicit
migration choice, preserving hourly weather/menu schedules and elapsed duration.
The legacy prototype's separate version 1/2 format and 18:00 start remain intact.

## Acceptance and verification

- [x] Canonical start, all twelve month boundaries, midnight and year rollover.
- [x] Ordinary, pause and accelerated rates; fractional carry and exact integer
  partitions; invalid/overflow input rejects atomically.
- [x] Shared consumer interval and timestamp API; no duplicate needs charge or
  reentrant time advancement; stale hourly service quotes reject.
- [x] Version 3/4 migration, version 5 precise round trip and malformed-save
  rejection before live mutation.
- [x] Controller idle/movement/map/menu/focus/overview checks; rendered calendar
  inspected and all month labels fit the actual HUD font/width.
- [x] S03-CLOCK handoff documented and S30 readiness updated.

`tests/test_game_clock.gd`: **44 checks**. `tests/test_clock_scene.gd`: **21 checks**.
World, tavern, original route, Dungeon links, hold movement, weather, City
environment and legacy scene regressions pass in the working tree. The isolated
publishable clock changes also pass clock/scene, world, tavern, original route,
Dungeon links, hold movement and City environment checks. Some existing scene
tests report resource cleanup warnings at exit; no gameplay assertion failed.

Reproduce with the portable Godot console, `--headless --path . --script
tests/test_game_clock.gd` (or `test_clock_scene.gd`). For the visual check run
`test_clock_scene.gd -- --capture` without headless; it writes an ignored
`tools/reference/s03-calendar.png`. In restricted environments set APPDATA to
the project's ignored `tools/appdata` before running tests.

S03 and S03-CLOCK are complete. S30 remains Backlog pending S08-SPEED; this change
does not implement effects, complete S08 or close F01.
