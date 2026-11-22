# S05 — City geography and establishment audit
Parent: F05 (#12). Refined 2026-11-22. Ready for evidence gathering; implementation is on hold until the user's playtest. Existing issue #38 remains the story; checklist items below are not hidden sub-issues.

Research started 2026-11-22: [first-pass inventory and findings](../S05_MAP_AUDIT_FINDINGS.md). Source legend/current faces inventoried; full ST occurrence and directional comparison remains in progress.

Follow-up: [numbered-location comparison](../S05_LOCATION_COMPARISON.md) now accounts for all visible markers and current location components. Unnumbered runtime identities, access/entrance semantics and the directed-face comparison remain open. No gameplay changes authorized.

Location delivery is now represented by [actual stories S33–S107](../LOCATION_STORIES.md), grouped under their service/scenario feature owners. S05 retains identity/dispatch and directional-map research; it does not own implementing all City services.

## Outcome
Identify City establishments and traverse source-supported directional passages, with unknown geometry explicitly visible in the development evidence.

## Sources and existing coverage
Use archived Kroah ST City v2.0 world.html map legend and Map.png; docs/ST_LOCATION_CORRECTION.md already verifies marker 16 Tail of the Dog (39,33)/(39,34), marker 14 Lost Oasis (20,1), and northern marker 49 (50,3). Preserve the repeated southeast marker 49 as a distinct occurrence. Internal coordinates are zero-based northwest origin, X east and Y south. ARX geometry is comparison evidence, not ST authority. Dungeon endpoints remain independently sourced 8-bit data.

## Evidence tasks (allowed during coding pause)
- Inventory every legend entry and every occurrence, including repeated markers; record source locator, map coordinates, footprint, candidate entrance faces and confidence. Counts come from the source, not assumed IDs.
- Compare all 4096 City cells / 16384 directed faces with available ST evidence; retain separate classifications: verified match, discrepancy, not resolved by image, outside supported interpretation.
- Never infer a reciprocal door from the opposite face or claim visual pixels prove runtime passage flags. Record unreadable edges and seek same-edition runtime/data evidence before proposing corrections.
- Produce a discrepancy ledger with current value, source-supported value, evidence, player impact and proposed migration. Separate identity fixes, geometry fixes and deliberate remake entrances.
- Keep Tail of the Dog/Grimthorn, music and northern cross-edition travel adaptations explicit.

## Implementation acceptance (not authorized during pause)
- Each changed identity/edge has evidence and regression anchors; retain directed boundaries and raw source provenance.
- Previously saved positions and opened doors have a documented policy if corrected geometry makes them invalid; do not silently teleport or strand the player.
- Verify the existing tavern exit, both established tavern cells, northern City/Dungeon round trip and no accidental extra southeast crossing.
- Audit coverage is complete only when every cell/face is classified. Unknowns are not fidelity passes; unresolved material behavior blocks claiming the affected passage historically verified.
- A discrepancy requiring substantial new mechanics becomes a separately visible issue before expanding this story.

## Readiness gate
Evidence gathering has no code dependency. Any correction must wait for test results and use the isolated development baseline. Full implementation readiness requires the discrepancy inventory, supported correction scope and save policy; broad city-wide fidelity is not currently Ready.

## Current-build access inventory — 2026-11-22

[Access and dispatch report](../S05_LOCATION_ACCESS.md) now records all 81 current components and 710 perimeter faces, with independent entry/exit codes. Static movement connectivity and service dispatch are separated from historical ST accessibility. Full ST directional comparison and runtime identity reconciliation remain open; no code changed.
