# F02/F03 sprint playtest handoff

Status: **Not run by the user**. Allow about 10 minutes. This supplements the earlier [full F01 playtest](LATEST_BUILD_PLAYTEST.md); it does not silently replace that pending test.

## Launch the correct build

Open **Play-Sprint.cmd** from the sprint checkout (`builds/worktrees/f02-f03` inside the original project). It uses the existing Godot executable and a separate `tools/appdata-sprint-playtest` save location. Automated tests use a different directory, and the original game's saves remain untouched. Do not use this checkout's regular Play.cmd for this test.

Record branch `codex/f02-f03-sprint`, exact commit, date, and Pass/Fail/Blocked for each step. Start only one sprint game instance at a time. Future launches through Play-Sprint.cmd reuse this isolated manual-test save.

| Step | Action | Expected |
| --- | --- | --- |
| 1 | Start fresh and inspect the date | Sowings 29, Year 0, 06:00; readable HUD |
| 2 | Watch roughly eight focused real seconds | About two game minutes pass |
| 3 | Press F7, wait roughly forty focused seconds, then F5 | SPD 18; save succeeds with roughly twenty effect minutes remaining |
| 4 | Wait another twenty seconds, then F9 twice | Saved clock returns; SPD stays 18, not 23; loading does not stack bonus |
| 5 | Open chapter overview with C for ten real seconds, then Escape | Clock/effect do not catch up for paused time |
| 6 | Switch to another application for ten seconds, then return | Same pause behavior |
| 7 | Close the game; relaunch using Play-Sprint.cmd; press F9 | Saved time, possessions and active bonus return |
| 8 | Keep the game focused until the saved remaining duration elapses (roughly eighty real seconds for twenty minutes) | SPD returns to 13; F5 then F9 cannot restore the expired bonus |

Record expected versus actual behavior and the first differing step. Screenshot/journal text helps. If F7 is unavailable, mark effect steps Blocked rather than Failed. Calendar rollover, malformed saves, migration, exact random replay and file-write failures are covered automatically; no need to manipulate save files manually.

Results: date/build ______; steps 1–8 ______; notes ______.
