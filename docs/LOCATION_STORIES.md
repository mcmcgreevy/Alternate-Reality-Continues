# City location story index

Created 2026-11-22 from the S05 numbered-location comparison. No new gameplay code. All entries are Backlog, not implementation-ready.

75 actual GitHub issues: **57 service locations, 11 scenario/entrance locations and 7 research items**. IDs S33–S107. Each occurrence is grouped by its full footprint, not one story per cell.

Parent links and project status are verified separately below; issue bodies contain source, footprint, dependencies and acceptance criteria.

## Delivery boundaries

- Existing S15–S21 remain shared-system stories. Location stories configure and validate that behavior at a specific establishment.
- Source-specific prices, stock, opening hours, relationships, bonuses and other details must be extracted before Ready; the issue is not evidence that research is complete.
- Two Da Place! stories retain distinct coordinates; neither is silently renamed Trade Winds. No implementation story is created for absent Trade Winds.
- Five inaccessible duplicate locations are research items under F05, not active healer/guild implementations. Two additional research items cover the unnumbered ARX-named gates.
- Northern/southeast Dungeon entrances belong to F23. The southeast story does not authorize a new crossing; its destination and adaptation require evidence/decision.
- Scenario stories cover documented access/messages, not construction of unreleased Arena, Palace or Wilderness chapters.
- Existing scenario/approach questions stay attached to their location owners: unlabeled Palace gate (53,22) to Palace Gates; Arena-entry cells to Arena; northern Dungeon approach (49,3) to the northern entrance. Their runtime meaning remains unresolved.
- Runtime identity/dispatch and directional-edge research remain in S05. No general geometry correction is authorized until a discrepancy is demonstrated.
- Milestones indicate the owning feature's initial delivery phase, not a promise that every service can finish there. Cross-phase jobs/equipment/spells remain explicit dependencies.

## Stories

| Story | Parent feature | Kind | GitHub |
| --- | --- | --- | --- |
| [S33] Implement Green Boar Inn | F15 | story | [#67](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/67) |
| [S34] Implement Lazy Griffin Inn | F15 | story | [#68](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/68) |
| [S35] Implement Sleeping Dragon Inn | F15 | story | [#69](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/69) |
| [S36] Implement Traveller's Inn | F15 | story | [#70](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/70) |
| [S37] Implement Midnight Inn | F15 | story | [#71](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/71) |
| [S38] Implement Warrior's Retreat | F15 | story | [#72](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/72) |
| [S39] Implement Royal Resort Inn | F15 | story | [#73](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/73) |
| [S40] Implement Flaming Dragon Tavern | F16 | story | [#74](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/74) |
| [S41] Implement Misty Mountain Tavern | F16 | story | [#75](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/75) |
| [S42] Implement Screaming Siren Bar | F16 | story | [#76](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/76) |
| [S43] Implement Happy Hunter Rest Stop | F16 | story | [#77](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/77) |
| [S44] Implement Dancing Nymph Tavern | F16 | story | [#78](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/78) |
| [S45] Implement Club | F16 | story | [#79](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/79) |
| [S46] Implement Black Devil Tavern | F16 | story | [#80](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/80) |
| [S47] Implement Lost Oasis | F16 | story | [#81](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/81) |
| [S48] Implement Last Stop | F16 | story | [#82](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/82) |
| [S49] Implement Tail of the Dog Tavern | F16 | story | [#83](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/83) |
| [S50] Implement Club Babylon | F16 | story | [#84](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/84) |
| [S51] Implement Lost Tears Tavern | F16 | story | [#85](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/85) |
| [S52] Implement Mom's Bar | F16 | story | [#86](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/86) |
| [S53] Implement Lusty Lloyds Tavern | F16 | story | [#87](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/87) |
| [S54] Implement First City Bank | F17 | story | [#88](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/88) |
| [S55] Implement Granite Bank | F17 | story | [#89](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/89) |
| [S56] Implement Gram's Gold Exchange | F17 | story | [#90](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/90) |
| [S57] Implement Smiley's Shop | F18 | story | [#91](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/91) |
| [S58] Implement Honest Trader | F18 | story | [#92](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/92) |
| [S59] Implement Adventurer's Outfitters | F18 | story | [#93](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/93) |
| [S60] Implement Warrior's Supplies | F18 | story | [#94](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/94) |
| [S61] Implement General Store | F18 | story | [#95](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/95) |
| [S62] Implement Exclusive Outfitters | F18 | story | [#96](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/96) |
| [S63] Implement Rocky's Emporium | F18 | story | [#97](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/97) |
| [S64] Implement Best Bargain Store | F18 | story | [#98](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/98) |
| [S65] Implement Special Imports Store | F18 | story | [#99](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/99) |
| [S66] Implement Betelgeuse Sales | F18 | story | [#100](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/100) |
| [S67] Implement Merchant's Grotto | F18 | story | [#101](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/101) |
| [S68] Implement Sunset Market | F18 | story | [#102](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/102) |
| [S69] Implement Pauline's Emporium | F18 | story | [#103](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/103) |
| [S70] Implement Da Place! ï¿½ southwest | F18 | story | [#104](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/104) |
| [S71] Implement Da Place! ï¿½ northeast | F18 | story | [#105](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/105) |
| [S72] Implement Sharp Weaponsmiths | F19 | story | [#106](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/106) |
| [S73] Implement Occum's Weaponsmiths | F19 | story | [#107](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/107) |
| [S74] Implement Best Armorers | F19 | story | [#108](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/108) |
| [S75] Implement Knight's Armorers | F19 | story | [#109](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/109) |
| [S76] Implement House of Ill Repute (QUARANTINED!) ï¿½ 41,26 | F05 | story | [#110](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/110) |
| [S77] Implement Arena ï¿½ 6,4 | F05 | story | [#111](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/111) |
| [S78] Implement Palace ï¿½ 52,17 | F05 | story | [#112](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/112) |
| [S79] Implement Palace Gates ï¿½ 61,21 | F05 | story | [#113](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/113) |
| [S80] Implement Dungeon Entrance ï¿½ 50,3 | F23 | story | [#114](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/114) |
| [S81] Implement Dungeon Entrance ï¿½ 59,62 | F23 | story | [#115](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/115) |
| [S82] Implement Maximum Casino ï¿½ 39,27 | F05 | story | [#116](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/116) |
| [S83] Implement Jack's Fitness Academy ï¿½ 54,59 | F05 | story | [#117](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/117) |
| [S84] Resolve One Way Soothers ï¿½ inaccessible duplicate 25,13 | F05 | research | [#118](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/118) |
| [S85] Implement One Way Soothers | F20 | story | [#119](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/119) |
| [S86] Implement Alpha Omega Healers | F20 | story | [#120](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/120) |
| [S87] Resolve Alpha Omega Healers ï¿½ inaccessible duplicate 26,16 | F05 | research | [#121](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/121) |
| [S88] Implement Thieves' Guild | F21 | story | [#122](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/122) |
| [S89] Implement Blue Wizards' Guild | F21 | story | [#123](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/123) |
| [S90] Implement Light Wizards' Guild | F21 | story | [#124](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/124) |
| [S91] Resolve Light Wizards' Guild ï¿½ inaccessible duplicate 21,16 | F05 | research | [#125](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/125) |
| [S92] Implement Green Wizards' Academy | F21 | story | [#126](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/126) |
| [S93] Resolve Green Wizards' Academy ï¿½ inaccessible duplicate 23,20 | F05 | research | [#127](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/127) |
| [S94] Implement Red Wizards' University | F21 | story | [#128](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/128) |
| [S95] Implement Dark Wizards' Guild | F21 | story | [#129](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/129) |
| [S96] Implement Star Wizards' Guild | F21 | story | [#130](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/130) |
| [S97] Implement Wizards' of Chaos | F21 | story | [#131](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/131) |
| [S98] Implement Wizards of Law | F21 | story | [#132](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/132) |
| [S99] Implement Guild of Order | F21 | story | [#133](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/133) |
| [S100] Implement Physicians' Guild | F21 | story | [#134](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/134) |
| [S101] Resolve Physicians' Guild ï¿½ inaccessible duplicate 32,7 | F05 | research | [#135](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/135) |
| [S102] Implement Assassins' Guild | F21 | story | [#136](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/136) |
| [S103] Implement Southern Gate ï¿½ 35,63 | F05 | story | [#137](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/137) |
| [S104] Implement Northern Gate ï¿½ 35,0 | F05 | story | [#138](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/138) |
| [S105] Implement Western Gate ï¿½ 0,36 | F05 | story | [#139](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/139) |
| [S106] Resolve unnumbered Acrinimiril's Gate location | F05 | research | [#140](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/140) |
| [S107] Resolve unnumbered Floating Gate location | F05 | research | [#141](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/141) |

## Tracking

GitHub is the workflow authority. LOCATION_STORY_PLAN.json preserves the initial issue specifications; LOCATION_STORY_INDEX.json maps portable IDs to GitHub IDs and project items. Do not run the old fixed-size baseline publisher to recreate these issues.

The original S05 inventory has 73 ST label components: 57 regular service occurrences, 11 scenario occurrences and five inaccessible duplicates. Adding the two unlabeled special-location research items gives 75. This is a coverage backlog, not a sprint commitment.
