# ST map location correction — 2026-11-16

Source: Kroah's [ST City map](http://bringerp.free.fr/RE/Ar/Images/Map.png), [archived unchanged](../assets/documentation/kroah-city-st-v2/Map.png), and the marker legend in [world.html](../assets/documentation/kroah-city-st-v2/world.html). The image is 1024 by 1024 pixels: each of the 64 by 64 cells is 16 pixels. Internal coordinates below are zero-based from the northwest corner, with Y increasing south.

| Marker | Establishment | Internal cell(s) | Current behavior |
| --- | --- | --- | --- |
| 14 | Lost Oasis | (20,1) | Former starting location; no longer identified as Tail of the Dog. Services are not implemented here. |
| 16 | Tail of the Dog Tavern | (39,33), (39,34) | Both cells belong to the tavern. New journeys start at southern service cell (39,34), displayed as 30N/40E under the existing coordinate convention. |
| 49, northern occurrence | Dungeon entrance | (50,3) | Existing interaction at adjacent (49,3), facing east, correctly approaches this entrance. City map D now marks the actual entrance cell. |

The map also repeats marker 49 in the southeast at (59,62); that is a separate entrance, not the northern excursion entrance. This correction does not enable an additional City/Dungeon crossing. The northern Dungeon arrival remains the independently verified 8-bit cell (49,3), facing west. The ST City map verifies the City endpoint, not that cross-edition Dungeon arrival.

The existing imported City data corroborates the tavern footprint with location code 32 in both cells, Lost Oasis with code 30, and the northern entrance with location code 65. The exterior west and south tavern faces use ARX code 29 (identified as a City tavern door in its renderer); interior faces use ordinary door code 3. Those raw values are preserved. The game now permits examination/opening of code 29 only into Tail of the Dog, retaining independent face state. This adapter is required by the current imported data format, not a claim that ST uses ARX's numeric encoding.

The tavern service screen exits south to (39,35). From the northern footprint cell it first traverses the interior cell, charging the normal step cost. The excursion route is regenerated from this exit: 75 outward steps from the service cell and 61 return steps. Guide pathfinding must not use the modal tavern as a shortcut through the building.

## Saves and verification

Existing saves retain their physical coordinates; the correction does not silently teleport characters. A save at the old (20,1) start now loads at Lost Oasis, with a location-specific explanation. Start a new journey to begin at the relocated Tail of the Dog, or follow the guide after returning from the Dungeon. Save format and character/inventory data are unchanged.

The route regression checks both marker-16 cells, south exit, west exterior-door entry, the marker-49 source cell, Lost Oasis exclusion, City/Dungeon transfer, return travel, music and transactions. Geography, door states and raw map arrays are not rewritten. The broader City's edge fidelity remains subject to ST reconciliation.
