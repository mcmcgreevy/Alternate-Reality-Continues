# S05 — Current location access and dispatch

2026-11-22. Static research against the isolated development branch; no gameplay changes or playtest performed. Coordinates are zero-based, northwest origin.

## Coverage and meaning

The [perimeter ledger](s05/current-location-perimeters.csv) enumerates 710 outward perimeter faces across all 81 current location components, including the three lower-code gate areas. Each row records the outside approach, incoming direction, independently stored entry and exit codes, and current movement support. The [component summary](s05/current-location-access.csv) aggregates these rows. A perimeter face is a candidate for examination, not a verified historical entrance.

A directed graph following `original_world.gd` movement eligibility reaches 3267 of 4096 City cells from the initial tavern cell (39,34), including some cells in 31 of 81 location components. Of the 81 components, 38 have no supported incoming perimeter face. The other 12 unreachable components have potentially supported entrances whose approaches are unreachable. These counts describe this build, not defects or ST accessibility.

The graph permits examination of codes 3/4/5/6 and the special code-29 entry into either Tail of the Dog cell, then movement through an opened face. Codes 0–7 are route-supported; other current codes are blocked. It never infers support from the opposite face. It ignores UI restrictions, time, service menus, chapter transitions and saved starting positions: this is potential movement connectivity, not an executed player route. All ST-access fields remain `not_verified`.

## Concrete findings

| Area | Current evidence | Interpretation / owner |
| --- | --- | --- |
| Tail of the Dog, raw 32 | Supported approaches from (39,35) north and (38,34) east into (39,34); both incoming codes 29, outgoing codes 3. Both tavern cells are reachable in the graph. | Current asymmetry is deliberate support, not a reciprocity error. The service exit uses the south door. Preserve both cells and the approved presentation; independently verify historical entrance faces. |
| Northern Dungeon, raw 65 | (49,3) east into (50,3), code 3 in both directions. | Chapter travel is triggered by interact at the approach (49,3), facing east in City, rather than by entering every raw-65 cell. Existing cross-edition adaptation remains explicit. |
| Southeast Dungeon, raw 65 | (59,63) north into (59,62), code 5 in both directions; reachable in graph. | Reachability does not activate chapter travel. No southeast chapter transition exists in the inspected dispatch. Its location story must not inherit northern travel automatically. |
| Acrinimiril's Gate, raw 60 | (32,27) west into (31,27), code 5 both ways. | Reachable current cell; no dedicated dispatch. The name remains ARX comparison evidence, and S106 must establish ST identity. |
| Floating Gate, raw 61 | (35,36) has incoming code 0 from all four neighbors. Its northward exit is code 3; other exits are 0. | No dedicated gate dispatch. S107 must establish ST identity; do not symmetrize its current north face without evidence. |
| Five inaccessible duplicate areas, raw 69/70/73/79/86 | None reachable from the tavern in the graph. Four have potentially supported incoming faces but unreachable approaches; raw 86 has none. | Broadly consistent with Kroah's explicit inaccessible remarks, but does not establish identical ST topology or rules. Keep all five research issues open. |

`in_tavern()` recognizes only the two explicit Tail of the Dog cells. Other reachable tavern/service cells do not gain menus from their raw location code. `interact()` handles the northern chapter link, supported boundary examination and the existing tavern fallback; there is no generic City establishment dispatcher. `is_inside()` supplies a shelter classification, not service identity or permission to enter. Lost Oasis has a location-specific hint, not a service implementation.

## Evidence and reproducibility

Inputs: unchanged `data/maps/city.json`; `scripts/original_world.gd` constants and methods `examinable_boundary`, `can_route`, `move`, `interact`, `in_tavern`, `leave_tavern`; the existing 81-row location comparison; archived Kroah `world.html` Map Remarks. Current map SHA-256 remains `2ff715f0272dc469ba1d86f670d049b5d2ac3e2907e2143c4b0db5ebda715914`.

Reconstructed four-neighbor equal-raw-code components with lexicographically ordered seeds, preserving existing component IDs. For each component cell, emitted a row for each neighbor outside that component, including off-map faces. Entry code is the outside cell's face aimed inward; exit code is the inside cell's face aimed outward. Traversed a directed breadth-first graph using the eligibility rule above. Checked all 81 component counts against the previous comparison, perimeter membership against the existing high-code component inventory, and uniqueness of all 710 face keys. Temporary analysis commands produced only CSV/documentation artifacts; no executable helper or regression test was added.

## Remaining work and correction gate

This completes the current-build perimeter/access inventory, not the historical directional comparison. The 16384-face ST ledger remains unverified. Next, examine same-edition map/dispatch data and compare source image boundaries with these candidate faces, explicitly retaining unresolved directionality. Do not promote pixel agreement into proof of original runtime flags.

No correction or save migration is proposed on this evidence alone. Any later correction must list exact affected faces, protect saved positions and direction-specific opened-door keys, and retain the existing tavern exit/northern round trip. S05 remains open; all service implementation remains paused for the user's playtest.
