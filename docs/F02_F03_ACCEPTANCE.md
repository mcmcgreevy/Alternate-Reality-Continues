# F02/F03 — Feature acceptance review

## Final acceptance — November 28, 2026

The user completed playtesting, confirmed save/load across a full restart and responsive movement, then explicitly accepted the final Dungeon darkness fix: "Looks fantastic. The light effects from the torches are much more noticeable now as well." The user authorized committing and merging all completed work. F02/F03 acceptance criteria are satisfied; the sprint goal is met. Earlier pending-playtest statements below are historical checkpoints, superseded by this acceptance. S05 research is included but its implementation remains open. Final integration verification is recorded in [the sprint closeout](SPRINT_CLOSEOUT_2026-11-28.md).

Reviewed 2026-11-22 against S02 implementation commit 3533003 and the additional calendar-boundary integration test in this change. **Implementation and automated criteria satisfied. User reported successful playtests on 2026-11-28; merge remains pending.** Neither feature is closed by this review.

## F02 — Persistence and deterministic tests

| Criterion | Evidence | Result |
| --- | --- | --- |
| Version saves and migrate supported journeys | S02 v8 schema; v3–7 migration/round trips; separate prototype regression | Pass |
| Reject invalid saves without partial mutation | Full-state comparisons for malformed envelope, clock, effects and random state | Pass |
| Repeat failures through controlled seeds/time | Dedicated random stream, lossless continuation state, integer clock inputs; restored/uninterrupted source-transition sequences | Pass |
| Protect previous successful save | Write/preserve/publish/rollback fault injection and interrupted transaction recovery | Pass |

See [S02 detailed acceptance](S02_ACCEPTANCE_REVIEW.md), including the single-writer and power-loss limitations. Cosmetic randomness is excluded. No unsupported original random algorithm is claimed.

## F03 — Calendar and Time Span

| Criterion | Evidence | Result |
| --- | --- | --- |
| ST start and calendar rollover | test_game_clock: Sowings 29 Year 0 06:00, every month, year boundary | Pass |
| Ordinary/accelerated/paused time | Clock model and scene suites; 15x / 3600x / zero elapsed, retained remainder and no pause backlog | Pass |
| Continuous clock without double charge | Movement scene and world consumer checks; explicit service costs charged once | Pass |
| Persist exact time and timed consumers | Current v8 clock/effect suites; S31 keyboard save/load integration | Pass |
| Combined year rollover, pause, save/load and accelerated expiry | test_sprint_clock_persistence: 14 checks | Pass |

The additional integration scenario saves an active effect thirty seconds before year end, reloads, pauses, crosses into Rebirth 1 Year 1, then expires the effect through accelerated service time. It compares uninterrupted and restored results and verifies a final save/load cannot resurrect the bonus.

S03 remains Done. No new calendar implementation or service-content story is needed. Actual inn sleep/jobs and guild learning remain with their own features; this acceptance covers their time adapter only. S08/S30/S31 dependencies are complete, superseding historical pending-status text in S03.

## Verification and handoff

Reuse the 840 counted checks and passing integration suites recorded for S02; no production code changed in this acceptance review. The new 14-check cross-feature scenario passes, bringing the recorded total to **854 counted checks**, plus the pass/fail suites. The existing Dungeon exit cleanup warning remains documented; no gameplay assertion failed.

The user's earlier F01 playtest is still Not run. It targets the original working folder, which has additional movement/weather changes. It is distinct from the isolated sprint build. Use [the sprint handoff](SPRINT_PLAYTEST.md) when ready to test the new branch. Do not merge or claim user acceptance without results. Reconcile any reported defect to its exact build first.

## User playtest results — 2026-11-28

User completed testing and explicitly confirmed save/load across closing and relaunching, along with responsive movement and prompt stopping on key release. The supplied screenshot confirms visible SPD. The only remaining reported issue is Dungeon distance rendering, handled in [the visual follow-up](DUNGEON_DISTANCE_RETEST.md). No persistence/calendar failure was reported; do not imply a separately recorded result for every original checklist row. No merge or feature closure performed by this record.
