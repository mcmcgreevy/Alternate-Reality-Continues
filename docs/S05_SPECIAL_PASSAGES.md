# S05 — Special approaches and scenario handlers

2026-11-22. Static analysis and canonical image review; no gameplay edits or original-game execution. Extends [complete difference triage](S05_SHOP_STATE_AND_TRIAGE.md).

## Seven special-code faces reviewed

The [seven-row ledger](s05/special-passage-review.csv) records both approached and opposite candidate faces, destination category/marker and visual disposition. The [contact sheet](s05/special-face-review.png) is derived from unchanged Kroah Map.png, using 48-pixel-square crops enlarged fourfold. Red boxes mark approach cells, not destinations. Visible doorway artwork does not establish original directional collision rules.

| Approach | Candidate destination | Category consequence |
| --- | --- | --- |
| (16,1) south → (16,2) | marker51 / type0 | Unnumbered Arena approach; ordinary City category, not Arena scenario cell. |
| (5,7) east → (6,7) | marker51 / type0 | Same distinction; its eastward exit is one of the earlier candidate14/current3 asymmetries. |
| (5,8) east → (6,8) | marker51 / type0 | Ordinary City category. |
| (25,8) west → (24,8) | marker46 / type6 | Actual Arena scenario category, despite current raw67 Arena Entrance identity. |
| (16,13) north → (16,12) | marker51 / type0 | Ordinary City approach; east/west faces are the earlier candidate14/current3 asymmetries. |
| (59,16) south → (59,17) | marker47 / type6 | Palace scenario category; candidate approach6, opposite13. |
| (52,22) east → (53,22) | marker48 / type0 | Unnumbered Palace gate occurrence uses ordinary City category. Do not assume the same dispatch as numbered gate marker48 elsewhere. |

Six crops show a door-like feature at the approached boundary. The (25,8) west crop shows a wall-like boundary at the Arena side: the candidate approach is4 but opposite face is13. Record visual/directional ambiguity rather than declaring the canonical image wrong. All seven remain held for full dispatch/directional verification, not added to the simple correction batch.

## Candidate special-location switch

Module13 `$008c..$00a4` reads the marker byte from the current view cell, subtracts43, doubles it and selects a relative handler from the table at `$00a8`. Out-of-range values select its final/default entry. The table consists of eleven words; these are data, not instructions.

| Marker(s) routed through this handler | Entry offset | Observed action |
| --- | --- | --- |
| 43,44,45 | `$00be` | Uses embedded quarantine/leave message, then common previous-position restore. |
| 46,51 | `$00f0` | Selects request word `$0301`, then common scenario request path. |
| 47,48 | `$00f6` | Selects request word `$0501`, then common scenario request path. |
| 49 | `$00fc` | Selects request word `$0201`, then common scenario request path. |
| 50 | `$00e4` | Uses embedded Palace closure message, then previous-position restore. |
| 52 | `$00ea` | Uses embedded bankruptcy closure message, then previous-position restore. |
| Other/default | `$0102` | Selects request word `$0401`, then common scenario request path. |

These are observed request words, not independently verified complete chapter identifiers or implemented chapters. The resident dispatch binding to this overlay still needs independent tracing; the switch is conditional evidence of what happens if this handler is invoked.

The common request path at `$0106..$0116` stores the request and checks character slot `$184a`: unsigned slot values >=9 select the embedded message that a temporary character cannot enter another scenario. The message returns through `$00c2..$00e0`, which restores X/Y, Z and partial X/Y from previous-position fields before dispatch `$8098`. Other paths call request/load dispatches `$0038` and `$004a` and examine their results. At `$0164..$0172`, one failure branch also returns to previous-position restoration. Successful full media loading has not been traced or tested.

This demonstrates why candidate passability alone is insufficient: crossing into a scenario cell may lead to a request, refusal or position restoration, rather than free exploration of all labeled interior cells. It does not authorize adding unreleased chapters or reproducing historical failures.

## Interpretation for existing location stories

S77 Arena must distinguish marker51/type0 approaches from marker46/type6 cells and preserve the directional questions. The mixed current raw67 cell (24,8) is now independently explained as a candidate scenario cell, consistent with Kroah's printed 46 there.

S78 Palace owns investigation of the approach6/opposite13 boundary at (59,16) south and its scenario behavior. Do not symmetrize it or equate a traversable candidate face with unrestricted Palace exploration.

S79 Palace Gates must distinguish (53,22)'s marker48/type0 from category6 gate occurrences. Marker alone is insufficient for binding a chapter interaction. The candidate switch contains a marker48 branch, but that does not prove this type0 cell calls it.

Likewise the marker44/45 branches do not establish working gates at the two type0 cells investigated by S106/S107. A dormant or otherwise unreachable handler entry is not a player-facing feature.

## Coverage and limits

All seven additional faces now have a recorded visual/category review. The original 16 ordinary-code faces retain their separate dispositions; total non-service threshold differences remains 23. This does not complete the 135 blocked/blocked or 19 below-threshold differences, full canonical equal-face verification, or original runtime tests.

No source downloaded or altered. Evidence uses unchanged archived Map.png, existing candidate map rows, and checksum-verified module13 from the S29 extraction. Original request routines were inspected sequentially from known entry points; the table values and embedded message bytes corroborate branch roles. No executable helper, map correction or save migration was added.
