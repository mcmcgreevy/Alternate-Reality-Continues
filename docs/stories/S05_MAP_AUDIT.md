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

## Candidate ST map comparison — 2026-11-22

[Executable/data evidence](../S05_ST_MAP_DATA.md) identifies a four-byte-per-cell map block matching all 463 canonical numbered cells. All 16384 directed faces now have a separate candidate-data comparison: 16128 raw equal, 256 raw different. Canonical image verification and full passage semantics remain open; no gameplay corrections made.

## Priority passage review — 2026-11-22

[Review of all 16 priority faces](../S05_PRIORITY_PASSAGES.md) identifies three visually corroborated missing doorways and one wall pair as proposed correction scope. Arena directionality, one unresolved face and four outer edges are classified separately. Hypothetical graph/save impact is documented; no implementation or playtest occurred.

## Service-identity research — 2026-11-22

[Service identity and encoding evidence](../S05_SERVICE_IDENTITIES.md) reconciles all 79 service-code faces with candidate ordinary doors and exact destination categories. Marker-to-service indices are traced in candidate routines, including shared computed Da Place! index and reversed healer record offsets. Full dispatch/state behavior and 177 non-service raw differences remain under review.

## Shared state and complete difference triage — 2026-11-22

[Follow-up research](../S05_SHOP_STATE_AND_TRIAGE.md) identifies the exact shared Da Place! friendship, frequency, visit-day, refresh-hour and stock addresses. All 256 raw differences are assigned initial categories; seven special-code passage candidates extend the earlier 16 ordinary-code cases. Classification is not fidelity completion.

## Special approaches — 2026-11-22

[Seven-face review and scenario handlers](../S05_SPECIAL_PASSAGES.md) distinguishes five ordinary-City approach cells from two scenario destinations. Candidate request/refusal/position-restore paths are documented; all seven faces remain held for full dispatch/directional verification. No correction added or implemented.

## Category dispatch bindings — 2026-11-22

[Resident dispatch trace](../S05_CATEGORY_DISPATCH.md) verifies all ten category-to-module bindings and connects category6 update to the scenario marker switch. This resolves the prior binding gap in candidate static evidence. Type0 gate/approach cells use City dispatch; City-specific event paths and full runtime behavior remain open.
