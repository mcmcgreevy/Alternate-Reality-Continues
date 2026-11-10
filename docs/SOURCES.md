# Short source log

Updated 2026-11-10. See [reconstruction notes](RECONSTRUCTION.md) for decoding evidence and reproduction.

| Status | Evidence | Use here |
| --- | --- | --- |
| Shipped / City geography | Original [8-bit survival handbook](https://www.mocagh.org/datasoft/arcity-hintbook8bit-book.pdf), printed page 7 and PDF page 6 map. | The Tavern at 63N,21E and both milestone routes cross-checked against the map. |
| Secondary reconstruction / City data | Author's [ARX 0.82 release](https://www.crpgdev.com/downloads/), cityCells.txt. | Machine-readable directional geometry. Other districts remain provisional. ARX's starting-tavern name is replaced with the primary handbook's name. No ARX code ported. |
| Shipped / Atari Dungeon data | [Pinned ardungeon revision](https://github.com/jduerstock/ardungeon/tree/823aaf1bc3b797070cbb0f79223a06b02491e792), first four map payloads, 11-s517.asm and 11-s311.asm. | All level-one quadrants and 50 original class-3 transitions enabled. Map payload checksums verified; remaining event classes and lower floors deferred. See [level-one evidence](DUNGEON_LEVEL_ONE.md). |
| Shipped / rules reference | Same disassembly, globals.inc and movement dispatch. | Shared time/character fields and directional boundary categories inform the model. Exact survival, economy and door chances remain unimplemented. |
| Shipped / C64 audio reference | [City](https://www.lemon64.com/game/alternate-reality-the-city), [Dungeon](https://www.lemon64.com/game/alternate-reality-the-dungeon), and [lyric description](https://www.c64-wiki.com/wiki/Alternate_Reality_-_The_City). | Gary Gilbertson's C64 music remains the reference target. Original recordings have not been transcribed or arranged; no original music files included. |
| Planned, not shipped | [C64-Wiki](https://www.c64-wiki.com/wiki/Alternate_Reality_-_The_City) reports Arena, Palace, Wilderness, Revelation and Destiny. Direct manual corroboration remains pending. | Reserved chapter IDs only; no historical maps or mechanics invented for them. |
| Shipped / tavern services | 8-bit handbook printed page 7: free water here, food/provisions, Pemmican adds a Packet, sitting consumes provisions. C64 guidebook: hourly menus. | Limited food/drink/provision service implemented; see [tavern evidence](TAVERN.md). |
| Secondary / provisional tavern values | Hagenstrom FAQ's Tavern price column, cross-checked with later ARX data. FAQ warns some entries are calculated. | Copper prices for six paid items; exact original runtime verification pending. Relief values follow ARX provisionally. |
| Remake inventions | Unified state, two-way entrance interaction, round-trip objective, route guide, save format, fixed starting character, deterministic door examination, menu rotation, need rates and action timing. | Integration choices, not claims about shipped rules. |
| Original placeholder presentation | Generated textures, first-person 3D staging, bartender, signage, original pulse/triangle cue and four lyric lines. | Not original artwork, SID emulation or an arrangement of an original composition. |

The former invented Lantern & the Gate maps and brass-token quest remain only in the separate prototype scene.

The 2026-11-10 atmosphere pass adds an original AI-generated tavern painting, procedural material/normal maps, modern torch lighting and a revised interface. These are remake art choices, not recovered game artwork or planned developer features. See [art provenance and scope](ART_DIRECTION.md).

First Excursion uses a tavern interaction screen. Its first meal/briefing/leave scaffold has now gained a limited source-informed food/drink service; exact menu wording, hourly sets and need/timing formulas remain remake choices. The full-healing two-gold meal has been removed. Leaving traverses the existing north boundary; entering restores the screen. Music and timed lyrics continue during menu use. The excursion adds no historical quest, reward or map geometry.

Dungeon JSON derives from original map data. Its source headers credit Jason Duerstock (2008) and the original program to Intellicreations (1987); the repository specifies GPL-2.0. All four level-one map sources/checksums, the runtime reference for transition decoding and upstream license are preserved in third_party/ardungeon. Transition behavior is implemented from the original table and dispatcher evidence. This attribution does not assert blanket rights to original game assets. No ARX implementation code was ported. The V tour and transition dots are invented playtest aids.
