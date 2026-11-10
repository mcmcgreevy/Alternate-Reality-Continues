# Dungeon level one

Implemented 2026-11-10: four 32×32 source quadrants form a 64×64 floor, with original directional edges and 50 source-defined transition cells. This is geography exploration, not a complete simulation of the floor's encounters and events.

## Playtest

1. Reach the Dungeon from The Tavern as before. Existing original-route saves still load; no save reset is needed.
2. Press V to guide toward the northwest. Follow the instructions, opening doors with E. Crossings can change coordinates abruptly: several original connections use transition cells, not adjacent grid movement.
3. At the stop, press V for southwest, then southeast, then the City entrance. Tab shows the full floor, quadrant divisions and transition dots. G hides/shows the guide.
4. Save and load in a new quadrant. Check position, facing, opened doors, coins and provisions. Loading defaults the optional guide back to the City entrance.
5. Return to the City with E at the original arrival and finish at The Tavern.

The optional tour stops are NW (00,00), SW (01,32), SE (36,32), and entrance (49,03), expressed as internal x/y coordinates. They are test waypoints, not invented establishments. Existing world clock costs apply; transitions add no separate travel fee or minute cost beyond the step. Needs remain nonlethal.

## Source evidence

All sources use ardungeon revision 823aaf1bc3b797070cbb0f79223a06b02491e792. The map sources are 21-s011 / 21-s052 / 21-s093 / 21-s134 for NW / NE / SW / SE. Each assembles to its upstream SHA1. Every cell retains its original description and special byte plus its segment index.

In 11-s517.asm, the level grouping at unk_3225 is 1,1,1,1,2,3,4. The coordinate tables at $628B/$6292 establish quadrant offsets; source header comments alone are not reliable. The special-byte dispatcher at loc_31B9 uses the high bit to select a trigger, bits 5–6 to select a handler and the low five bits as its index. Handler class 3 reaches loc_35C1. Its byte_3BA7 table holds 32 destinations: local x, local y, segment, facing. All 50 class-3 cells in level one target level one. Facing $FF preserves orientation, $80 randomizes it, and 0–3 sets it. The implementation applies one transition per entered cell, matching the original event latch; it does not recurse at a self-targeting cell.

The raw grid has many solid quadrant borders. No walls were removed to connect it. Original boundary transitions include (31,0)→(33,0), (0,31)→(0,33), (35,31)→(35,33), and (31,63)→(33,63); paired triggers provide their returns. Other transition cells include internal teleports and facing changes.

ARX's later level-one geometry agrees on 4,094 of 4,096 cell edge records. The two discrepancies are added return doors at (49,3) east and (59,61) south. We retain both original solid walls. Only the previously implemented north City entrance provides the remake's return interaction; a second City connection is not silently added.

## Verification and limits

The integration test checks all 256 directed faces at the two quadrant seams, fixed original crossing anchors, outer-border blocking, fixed/random facing, saves in each new quadrant and a real-input tour through all four quadrants back to the City. The pathfinder models transition destinations while retaining the physical step to tell the player which way to move. The renderer streams geometry from the same full-floor data. Graphical captures were checked for all three new quadrants and the full map.

No new passages or quest content are invented. Locked/bolted/enchanted door checks, other event classes, encounters, hazards, descriptive text, lower floors and the southeast City connection remain unimplemented. Therefore original geometric data does not imply that all routes, hazards or areas behave exactly as the shipped game. The optional V tour and visible transition markers are modern playtest aids.
