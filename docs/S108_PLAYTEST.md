# S108 focused playtest

Build: `codex/s108-city-map-corrections`, November 28, 2026. Status: not yet run by the player. Allow about 10–15 minutes.

## Start safely

Close any running copy of the game. Run **Play-S108.cmd** from this development checkout. It stores saves in `tools/appdata-s108-playtest`, separately from normal play, the previous sprint and automated tests.

Choose **1–8** to replace only the isolated S108 test save with that checkpoint, then press **F9** in the game to load it. Each checkpoint is an old-format save containing deliberately stale door entries. Choose **0** to resume your existing S108 test save without replacing it. Close the current game before selecting another checkpoint. These test saves are disposable; do not copy them over a regular journey.

## Check the corrected boundaries

| Choice | Displayed City coordinates | Facing | Expected boundary |
| --- | --- | --- | --- |
| 1 | 34N 11E | South | First doorway |
| 2 | 33N 11E | North | First doorway, opposite side |
| 3 | 33N 12E | East | Second doorway |
| 4 | 33N 13E | West | Second doorway, opposite side |
| 5 | 32N 11E | East | Third doorway |
| 6 | 32N 12E | West | Third doorway, opposite side |
| 7 | 30N 27E | South | Restored wall |
| 8 | 29N 27E | North | Restored wall, opposite side |

For **1–6**: after F9, verify a closed door is visible and W cannot cross it. Press E, then W; the doorway should open and allow travel. Turn around; that approached face starts closed independently, so open it with E before returning. Record any invisible wall, incorrect door appearance or unexpected movement.

For **7–8**: verify a solid wall. W must not cross it, and E must not turn it into an opening. The intentionally stale save keys must not bypass it.

## Save and return checks

1. At any opened doorway, stop moving and press F5. Close the game, rerun the launcher with **0**, and press F9. Your position, facing and opened-door state should return. Loading repeatedly must not close a legitimate newly opened door.
2. From a newly accessible area, follow the return guide to Tail of the Dog. Confirm you can leave the area and reach the tavern without getting stranded. Tab can help inspect the route; the guide may require opening a door with E.
3. Take the existing northern Dungeon excursion and return. Confirm the Dungeon remains dark in the distance, SPD remains visible and the City return still works. The automated suite covers every newly accessible cell, both tavern cells, the south exit and the unchanged southeast behavior; no need to walk to the southeast corner solely for this test.

Report the build/branch, checkpoint numbers passed, save/restart and return-route results, plus any failure's coordinates, facing and screenshot. S108 remains in Playtest until these results are accepted. No full rerun of the prior sprint checklist is required.
