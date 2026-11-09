# Original-map reconstruction

Updated 2026-11-09. Original-map exploration is now the default milestone. Atari data is the Dungeon baseline; C64 remains the audio target. Two-way chapter travel is an intentional unified-remake feature.

## Evidence and scope

The [8-bit City handbook](https://www.mocagh.org/datasoft/arcity-hintbook8bit-book.pdf), printed page 7 (PDF page 5), identifies The Tavern at 63N,21E. Its map on PDF page 6 was visually cross-checked against the generated outward and return routes, including secret and directional boundaries. This is the 8-bit handbook, not the separate 16-bit edition.

City geometry comes from the author's public [ARX 0.82 release](https://www.crpgdev.com/downloads/), data/map/cityCells.txt. ARX is a later remake. The 73-step outward and 109-step return routes have been checked against the primary map; the remaining 64×64 City is provisional. ARX calls the starting cell Lost Oasis; we use the handbook's The Tavern. No ARX executable was run or implementation code ported.

Dungeon sources are pinned to [revision 823aaf1bc3b797070cbb0f79223a06b02491e792](https://github.com/jduerstock/ardungeon/tree/823aaf1bc3b797070cbb0f79223a06b02491e792). All seven 5,120-byte payloads assemble to their upstream SHA1 checksums. Only 21-s052.asm, the northeast 32×32 area of level one, is currently playable. Seven storage segments do not mean seven floors. Header comments alone are unreliable for quadrant assignment.

In 11-s517.asm, sub_3531 addresses four-byte records at $B000. The first two bytes contain N/E/S/W nibbles; the following bytes retain description and event references. Movement dispatch byte_3B24/byte_3B34 and direction selectors establish boundary categories. Codes 0,1,2,7 are traversable; 3,4 ordinary doors; 5,6 secret doors; 8–10 require unimplemented locked/bolted/enchanted mechanics; 11–15 block movement. E opens approachable ordinary/secret doors deterministically; original discovery and chance mechanics are deferred.

In 11-s311.asm, loc_787D maps City saved x49,y3 to Dungeon segment 1, local x17,y3, facing west. Segment offsets in 11-s517.asm at $628B/$6292 place that arrival at global x49,y3. City coordinates display N=64−y, E=x+1; Dungeon N=63−y, E=x. The City entrance building is x50,y3 (61N,51E); interaction occurs on its western approach cell.

ARX matches 1,023 of 1,024 northeast Dungeon boundary records. Its one change replaces the arrival's east wall code 13 with door code 3. We preserve the original wall and provide return travel through an entrance interaction.

## Model and verification

Each cell has independent N/E/S/W boundaries; opposite faces are not forced symmetric. Opened-door state is separate from immutable maps. Movement and rendering share those boundaries. Absent Dungeon segments block travel. Original description/event IDs are retained but not executed.

The full-scene test covers the outward trip, exploration west of arrival, save/load, return, secret and one-way boundaries, coordinates, character identity, inventory, clock and audio lifecycle. OpenGL runtime captures cover the tavern, map, City entrance, Dungeon arrival and completed return. The old adventure remains a separate regression fixture.

## Reproduce

1. Obtain the pinned disassembly under tools/reference/ardungeon-823aaf1bc3b797070cbb0f79223a06b02491e792/.
2. Extract data/map/cityCells.txt and data/map/dungeon1Cells.txt from [AR_X_0.82.zip](https://www.crpgdev.com/game_downloads/AR_X_0.82.zip) under tools/reference/arx/.
3. Run python tools/import_dungeon_maps.py tools/reference/ardungeon-823aaf1bc3b797070cbb0f79223a06b02491e792 to validate all seven payloads.
4. Run python tools/build_original_route.py to regenerate JSON and provenance hashes. It asserts the precise ARX Dungeon discrepancy.

The northeast source, checksum and upstream license are preserved in third_party/ardungeon/. The importer rejects unsupported directives and checksum mismatches. Downloads and review scans remain in ignored tools/reference/; gameplay only needs generated JSON. docs/map_source_audit.json preserves the earlier source inventory.

## Remaining fidelity work

Verify other City districts against primary data or target-platform play; enable and test Dungeon quadrant seams and floor links; then expand original establishments, descriptions and events. The first [tavern service pass](TAVERN.md) now implements food, free water and provisions, with provisional prices and need mechanics recorded separately from primary evidence. Exact door checks and full wall appearances still require behavioral comparison. Graphics modernization and original-music arrangements remain separate future work.
