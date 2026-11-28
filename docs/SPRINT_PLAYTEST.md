# F02/F03 sprint playtest handoff

## Final acceptance — November 28, 2026

The user completed playtesting, confirmed save/load across a full restart and responsive movement, then explicitly accepted the final Dungeon darkness fix: "Looks fantastic. The light effects from the torches are much more noticeable now as well." The user authorized committing and merging all completed work. F02/F03 acceptance criteria are satisfied; the sprint goal is met. Earlier pending-playtest statements below are historical checkpoints, superseded by this acceptance. S05 research is included but its implementation remains open. Final integration verification is recorded in [the sprint closeout](SPRINT_CLOSEOUT_2026-11-28.md).

Status: **User completed playtests and retest on 2026-11-28.** Save/load, including closing/relaunching and recalling the save, worked; movement was responsive and stopped promptly on key release. SPD is visible in the supplied screenshot. The only remaining reported issue was bright Dungeon distance at WEST / 63N 50E. The first background/fog fix was insufficient. The follow-up detaches the City sky indoors and passes actual GPU-rendered pixel checks at that location at dawn, noon and night. User confirmation of this last visual fix remains pending; do not repeat the full save/load playtest for it. See [rendering follow-up](DUNGEON_DISTANCE_RETEST.md).

## Launch the correct build

Open **Play-Sprint.cmd** from the sprint checkout (`builds/worktrees/f02-f03` inside the original project). It uses the existing Godot executable and a separate `tools/appdata-sprint-playtest` save location. Automated tests use a different directory, and the original game's saves remain untouched. Do not use this checkout's regular Play.cmd for this test.

Record branch `codex/f02-f03-sprint`, exact commit, date, and Pass/Fail/Blocked for each step. Start only one sprint game instance at a time. Future launches through Play-Sprint.cmd reuse this isolated manual-test save.


## Quick retest for 2026-11-28 (about 3–5 minutes)

Use the unmerged `codex/f02-f03-sprint` checkout and its **Play-Sprint.cmd**. The two fixes are included in commit `a9d7ada` and later commits. Research-only commits do not change the build behavior. Close any older game instance first; restarting is needed to load the updated scripts. No merge is required.

| Step | Action | Expected |
| --- | --- | --- |
| A | Launch and inspect stats before pressing F7 or F9 | SPD is already visible, normally 13 on a fresh launch. |
| B | If you have an existing sprint save, press F9 and inspect SPD | SPD remains visible. Its value follows the saved effect state: normally 13, or 18 while Physical Speed is active. Loading must not add another bonus. |
| C | Travel to the Dungeon using the existing guide/entrance route; face a long corridor and turn through several views | Gaps beyond rendered geometry are black, with no white/outdoor-looking glow. Nearby walls and torch-lit geometry remain readable. |
| D | Walk far enough to refresh the rendered neighborhood, then inspect the distance again | The black background persists; no bright gap appears as geometry refreshes. |
| E | Return to City streets | City sky and normal outdoor lighting return. Dungeon darkness must not persist outdoors. |
| F | Optionally press F7 and let the effect expire while focused | SPD changes to18, then returns to13 while remaining visible. No need to repeat the full save/pause checklist unless another problem appears. |

For each step record Pass / Fail / Blocked. If travel prevents checking the Dungeon, record Blocked rather than Pass. You do not need to overwrite your existing save for this short retest. Report chapter, coordinates, facing and a screenshot if a bright gap remains; those details let us reproduce the exact view.

Quick retest results: date/build ______; A ______ B ______ C ______ D ______ E ______ F ______; notes ______.

The automated stat checks and environment-setting checks pass, but they do not replace this visual retest. This checklist does not test S05 research findings: no S05 map corrections have been implemented.

## Original sprint regression checklist (about 10 minutes)

| Step | Action | Expected |
| --- | --- | --- |
| 1 | Start fresh and inspect the date | Sowings 29, Year 0, 06:00; readable HUD with SPD visible before F7 |
| 2 | Watch roughly eight focused real seconds | About two game minutes pass |
| 3 | Press F7, wait roughly forty focused seconds, then F5 | SPD 18; save succeeds with roughly twenty effect minutes remaining |
| 4 | Wait another twenty seconds, then F9 twice | Saved clock returns; SPD stays 18, not 23; loading does not stack bonus |
| 5 | Open chapter overview with C for ten real seconds, then Escape | Clock/effect do not catch up for paused time |
| 6 | Switch to another application for ten seconds, then return | Same pause behavior |
| 7 | Close the game; relaunch using Play-Sprint.cmd; press F9 | Saved time, possessions and active bonus return |
| 8 | Keep the game focused until the saved remaining duration elapses (roughly eighty real seconds for twenty minutes) | SPD returns to 13; F5 then F9 cannot restore the expired bonus |

Record expected versus actual behavior and the first differing step. Screenshot/journal text helps. If F7 is unavailable, mark effect steps Blocked rather than Failed. Calendar rollover, malformed saves, migration, exact random replay and file-write failures are covered automatically; no need to manipulate save files manually.

Results: date/build ______; steps 1–8 ______; notes ______.
