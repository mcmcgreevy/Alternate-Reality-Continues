# Latest build — manual playtest script

Prepared 2026-11-20 for **e9b2c94**, the completed F01/S31 build, on
`feature/atmosphere-art-pass`. Allow **20–30 minutes** for the core pass.
The optional full Dungeon tour takes longer.

This is a script to run and record, not a report that these manual checks have
already passed. Automated acceptance evidence is in [S31](S31_ACCEPTANCE_REVIEW.md).

## Before you start

- Record date, build/commit, and whether you are using the local working folder
  or a clean checkout. The local folder also contains uncommitted movement/weather
  changes; identify that version when reporting a problem.
- Launch **Play.cmd**, or run the main scene from the Godot editor. Use a debug
  build for **F7**, the Physical Speed test control. If F7 is unavailable in a
  release build, mark the effect tests **Blocked**, rather than **Failed**.
- Start fresh; do not press F9 until instructed. The initial location is Tail of
  the Dog Tavern, with the clock starting at **06:00, Sowings 29, Year 0**.
- **F5 replaces the journey save.** If you want to keep an existing save, copy
  `original_route.json` from the game's user-data folder before testing. In the
  Godot editor, use **Project → Open User Data Folder** to locate it.
- Keep this checklist on another device or print it when possible. Switching
  focus away from the game pauses its simulation.

Record each section as **Pass / Fail / Blocked / Not run**. Note the first step
that differs from its expected result; keep testing independent sections if possible.

## 1. Launch, tavern and presentation

| Step | Action | Expected result |
| --- | --- | --- |
| 1.1 | Launch fresh and inspect the screen. | Tavern scene, Grimthorn, character, inventory, clock and numbered menu are visible. No overlapping labels or missing scenery. |
| 1.2 | Press 2, then 2 again. | Excursion briefing opens and closes. |
| 1.3 | Try W, A, S and D while in the tavern. | You remain in the establishment menu. Time continues normally while focused; movement keys do not add a separate travel charge. |
| 1.4 | Toggle L, K and M individually, then restore your preferred settings. | L changes lead vocals without restarting the song; K changes subtitles; M mutes/unmutes. Note audible jumps or poorly timed lyrics. |
| 1.5 | Watch the clock for about eight focused real seconds. | About two game minutes pass. The clock must not run twice as fast while menus are open. |

Result: ______  Notes: _______________________________________________

## 2. Physical Speed, repeat activation and save/load

Remain in the tavern and avoid purchases or five-minute waits during this section.
Start a stopwatch when activating the effect. Record the displayed activation
minute as **A**. The display omits seconds, so manual boundary observations have
up to one displayed minute of uncertainty; exact microsecond boundaries are
covered by automated tests.

| Step | Action | Expected result |
| --- | --- | --- |
| 2.1 | Press F7 once. | Journal confirms Physical Speed for 30 game minutes; the character panel reveals **SPD 18**. |
| 2.2 | After about 40 focused real seconds (10 game minutes), press F7 again. | SPD remains 18. Journal says the effect is already active and remaining time is unchanged. No stacking or restart. |
| 2.3 | Immediately press F5; record the saved clock minute and SPD. | “Journey saved.” This saves roughly 20 game minutes of effect duration. |
| 2.4 | Let about 20 more focused real seconds pass, then press F9. | Clock returns to the saved time, SPD remains 18, and possessions are restored. It must not become 23. |
| 2.5 | Press F9 again. | Same saved state returns. Repeated loading does not add another bonus. |

Activation minute A: ______  Saved minute: ______  Restored SPD: ______

Result: ______  Notes: _______________________________________________

## 3. Pause, expiry and reactivation

Continue from section 2's restored save. Do not press F7 again until step 3.6.

| Step | Action | Expected result |
| --- | --- | --- |
| 3.1 | Press C to open the chapter overview; wait 15 real seconds. | The game clock stops. Physical Speed does not expire while paused. |
| 3.2 | Press Escape. Note the clock, switch focus to another application for 15 seconds, then return. | No backlog of elapsed time is applied on return. A small change while switching focus is normal. |
| 3.3 | Keep the game focused and allow ordinary time to pass. | SPD stays 18 until approximately **A + 30 game minutes**, accounting for the saved/restored clock. It returns to **13** about 80 focused real seconds after the roughly minute-10 restore, excluding pauses. |
| 3.4 | Check that expiry occurred on the original schedule. | Repeated F7 at minute 10 did not extend the effect to A + 40. Reload did not restart a fresh 30 minutes. |
| 3.5 | Press F5 after expiry, then F9. | SPD stays 13. The expired effect does not return. This replaces the active-effect save from section 2. |
| 3.6 | Press F7 once more. | SPD becomes 18 again; a new 30-minute effect can begin. |

Do not expect visibly faster walking for this example: base Speed 13 and boosted
Speed 18 both produce walking rate **6** under the documented formula.

Observed expiry minute: ______  Result: ______  Notes: __________________

## 4. Tavern transactions

| Step | Action | Expected result |
| --- | --- | --- |
| 4.1 | Press 1 or B to open orders. Record the currently displayed items and prices. | A readable menu appears. Selection depends on the current game hour. |
| 4.2 | Select an item, then press N. | No purchase, spending or service-time charge. Ordinary time continues. |
| 4.3 | Select an affordable meal and press Y. | Coins decrease by the displayed price, hunger decreases, health does not increase, and the meal adds 15 game minutes. An active effect may legitimately expire during that time. |
| 4.4 | If free water is offered, order it. | No coins spent; thirst decreases. The service adds one game minute. Otherwise mark this step Not run. |
| 4.5 | Press T in the order menu. | Time advances to the next hourly menu. Stock refreshes; active effects advance with that same clock. |
| 4.6 | Press 5 or Escape to return. | The normal tavern choices return. |

Use displayed prices, not a fixed Chili price or a predicted end time from an
older checklist. Tavern economics and service timing remain provisional.

Result: ______  Notes: _______________________________________________

## 5. Street controls, map and weather

| Step | Action | Expected result |
| --- | --- | --- |
| 5.1 | Press 3 in the tavern. | You leave through the **south** exit. Tavern music stops. |
| 5.2 | Try W/S, A/D and Q/R in a safe passage. | Forward/back, turning and strafing work; walls prevent movement. |
| 5.3 | Hold a movement key, release it, then toggle H and try again. | Hold mode repeats movement; classic mode requires fresh presses. Restore your preferred setting. |
| 5.4 | Press Tab; move a little, then close the map. Toggle G. | Map position and facing agree with the world; G hides/shows the route guide. The map remains live, not paused. |
| 5.5 | Cycle F6 through the weather choices outdoors. Stop on Rainy. | The header identifies the test condition; rain is visible/audible outdoors. M mutes it. Lightning/thunder is intermittent, not required on demand. |
| 5.6 | Cycle F6 back to Auto. | The test override clears. Weather has no stat penalties in this build. |

**Local movement variant only:** if testing the uncommitted animated-stride work,
also confirm that release finishes the current tile, the live map follows the
stride, and turns/interactions/saving wait for the stride to finish. Do not report
those behaviors as promised by clean commit e9b2c94.

Result: ______  Notes: _______________________________________________

## 6. City–Dungeon effect and save round trip

Navigate before activating the effect so route-finding time does not consume it.

| Step | Action | Expected result |
| --- | --- | --- |
| 6.1 | Follow the guide to the northern Dungeon entrance. Use E to examine/open obstructing boundaries; consult Tab when needed. | Guide and passable route agree. Secret and one-way passages may require examination or a different return route. |
| 6.2 | At the entrance, wait for any current Physical Speed effect to expire. Face east and press F7. Record clock, health, coins and inventory. | Fresh SPD 18; possessions unchanged. |
| 6.3 | Press E. | You enter the Dungeon facing west. The crossing adds five game minutes. The effect and possessions carry over; rain is suppressed. |
| 6.4 | Step west once, finish moving, then press F5. Record position, clock and SPD. Move or wait briefly, then press F9. | Dungeon position, clock, possessions and active SPD 18 restore together, provided the effect was still active when saved. |
| 6.5 | Face east, step back to the arrival cell and press E. | You return to the City; another five game minutes pass. Effect duration is not reset by crossing. |
| 6.6 | Keep the game focused until the effect expires. | SPD returns to 13 based on elapsed game time, including both crossings. |
| 6.7 | Follow the return guide to Tail of the Dog Tavern. | Tavern menu and music return, and the excursion objective completes. The return route need not match the outward route. |

If navigation takes long enough for the effect to expire before saving, that is
not itself a failure. Repeat the effect check with a fresh F7 activation and
record the timing. Do not expect a fixed clock time at the end of the trip.

Result: ______  Notes: _______________________________________________

## Optional extended pass

- In the Dungeon, use V to cycle northwest, southwest, southeast and City-entrance
  guide destinations. Follow each route and test save/load in a distant quadrant.
  Only level one is enabled; do not expect access to lower floors.
- If you have a genuine older save, test a **copy**. It should load without a new
  invented spell. Previously saved character values should remain; do not edit
  the save's version number to manufacture a migration test.
- Restart the application and check audio/movement preferences. Weather override
  should return to Auto. Journey state is restored explicitly with F9.

## Record a problem

Copy one report per issue:

```text
Build/commit and clean checkout or local working folder:
Date:
Section/step:
Result: Fail / Blocked
Starting location, facing and game clock:
Keys/actions, in order:
Expected:
Observed:
Reproduces: always / sometimes / once
Screenshot/video and save copy, if useful:
```

Final results: 1 ___  2 ___  3 ___  4 ___  5 ___  6 ___  Optional ___

Do not mark missing combat, encounters, guild spell acquisition, most other shops,
full survival consequences or lower Dungeon floors as regressions. Those remain
outside this build. Confusing controls, text, sound and navigation are still useful
feedback even when they are not correctness failures.
