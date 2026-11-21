# S30 timed effects and acceptance review

Completed 2026-11-20. All six acceptance criteria are met for the approved
operation set. Gameplay activation, presentation and effect persistence remain
S31 work; there is no new player-facing spell control in S30.

## Runtime contract

`scripts/effect_timing.gd` combines S29 identity/event handling, S32 ordering and
S08 typed actions. Construct it with the live character dictionary and an integer
start timestamp. Register immutable definitions with validated execution profiles,
register generic owners with unique nonnegative source ranks, queue timestamped
events, then call `advance_game_microseconds` with nonnegative integer elapsed time.
Snapshots are copies, not a persistence format or editable handles.

A timer profile has exactly `kind: "timer"`, `initial_timer_raw`, `interval_raw`,
`counter_raw`, `incubating` and `action`. Timer/interval values are unsigned
0..65535; counters are 0..255. Positive timer units are 60,000,000 game microseconds.
Initial zero is dormant. Interval zero disarms after the current action. Counter
zero is unbounded; positive counters decrement after execution and remove at zero.
No finite counter is allowed to turn into unbounded state.

Actions use S08's six-field descriptor: `target: "speed_bonus"`, `operation:
"add"` or `"subtract"`, `operand_width: 1`, `block_count: 1`, `block_gap: 0`, and
byte `parameter`. Add/Sub saturate at 255/0. The raw comparison must match the
supported action (129/145), Speed-bonus offset 6318 and block/parameter encoding.
Effect types 1..3 can carry this restricted timer action; this is not general
poison/disease content support. Nonzero natural cure, other targets/operations,
widths, block layouts and malformed profiles are explicitly rejected.

A text profile has exactly `kind: "text"`, `text`, `long_text` and `visible`, with
comparison effect type zero. It has no timer/action. Long text reserves two
contiguous scheduling slots. Incubation clears at first expiry and reveals linked
text before executing the action. Root exhaustion removes its entire linked group;
child exhaustion removes only the child. Record removal never subtracts a bonus
implicitly. Text revealed and removed in one expiry need not appear for a frame.

## Ordering and robustness

Queue all events before advancing across their timestamps. Events at the current
time can be dispatched with elapsed zero, but cannot retroactively precede timers
already executed by an earlier call. At each timestamp, owners run in descending
source rank, each owner retains S29 event-bit order, then due timers run in ascending
scheduling-slot order. Slots use the lowest available position and are reusable;
instance IDs remain monotonic. Each event step supplies a lifecycle snapshot so
transient allocation/removal is accounted for. Removed due records are skipped.
Previously queued work for a subsequently deleted owner is discarded deterministically.

Every elapsed update is previewed on a private copy. A negative/noninteger input,
invalid stat state or deadline overflow leaves events, timers, IDs, character and
time unchanged. The clock's 9e15-microsecond ceiling applies. Reload overflow is
rejected even if the same expiry would exhaust a finite counter, because reload
precedes action/removal. All due work is processed; there is no dropped-poll rule
or execution cap. Cost grows with actual due executions and transaction state.
Logical scheduling slots are not limited to the original executable's crash-prone
capacity. These are explicit remake robustness choices.

## Clock integration boundary

`scripts/effect_clock_adapter.gd` binds one OriginalWorld and one runtime using the
same character dictionary and current world timestamp. Route elapsed input through
the adapter once. It previews S03 real/game conversion and the entire effect update,
commits effects, then calls the world's existing elapsed-time method once. The
world emits its clock signal and performs its existing needs update once. There is
no signal subscription or additional metabolism loop. Ordinary and accelerated
rates and fractional remainder remain owned by S03. Pause neither advances time nor
dispatches queued current-time work; explicit elapsed zero may dispatch it.

The adapter/runtime reject reentry during clock notifications. Advancing the world
outside the adapter or replacing the character dictionary requires explicit
rebinding. S31 must wire gameplay and save/load through this boundary; S30 does not
automatically attach unsaved effect state to the running controller. Consumers see
the interval's final effect state during the world signal. No effect callbacks or
intermediate rendering are supported.

## Provenance and handoff

The unchanged archived Kroah `technicalNotes.html` Effect sections support timer,
interval, counter, incubation, text and action behavior; `world.html` supplies time
correspondence. [S32 research](S32_ST_TIMING_RESEARCH.md) records original-code
ordering evidence and the user's explicit duration/reliable-elapsed-time decision.
[S03](S03_CLOCK.md) and [S08](S08_STATS.md) supply the implemented interfaces.
No new source download or claim of complete original-executable emulation is made.

The Physical Speed test applies an explicit S08 Add5 after successful activation,
then schedules Sub5 at +30 minutes with linked text. It verifies +5 through minute
29 and removal at minute 30. This proves the required operation path, not gameplay
or save integration. S31 owns the successful-activation grant, duplicate handling,
production wiring, +10-minute save/+20-minute remaining case and reload validation.

## Acceptance evidence

| Criterion | Verification |
| --- | --- |
| AC1 | Integer game-time input; adapter delegates conversion to S03 exactly once. |
| AC2 | Distinct initial/repeat timing, zero/finite counters, dormancy, incubation, typed action and linked cleanup tests. |
| AC3 | Nonzero cure and unsupported typed operations rejected before registration. |
| AC4 | Large/partitioned trace and state equality, including 3/5/7 executions, exact/zero boundaries, linked removal and event ties. |
| AC5 | Descending owner ranks, ascending reusable slots, removed-record skip, H suppression without timer refresh and transaction rollback tests. |
| AC6 | Ordinary/pause/accelerated adapter, one needs update, signal ordering, reentry and binding checks; code guide and provenance updated. |

Validation: 157 S30 checks; 303 S29 lifecycle checks; 107 S08 stat/scene checks;
65 S03 clock/scene checks; 23 Python provenance regression tests. Both source-hash
validators pass. The publishable code is also checked in an isolated project based
on committed S08 code so unrelated movement/weather edits are not dependencies.
