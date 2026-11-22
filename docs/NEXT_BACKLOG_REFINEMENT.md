# Next backlog refinement — 2026-11-22

User direction: **no new code until the user has tested**. This pass changes planning documents and GitHub descriptions only. Testable game files and the original working folder remain unchanged. No feature is closed and no story is moved into implementation.

## Recommended next batch

| Priority | Item | Ready for | Gate before coding/closure |
| --- | --- | --- | --- |
| 1 | F08 / completed S08 | Feature acceptance/scope reconciliation | Confirm the shared stat-model criteria against existing evidence; do not reopen creation/metabolism/combat producers as missing stat-model implementation |
| 2 | F05 / S05 #38 | Map/identity evidence inventory | Enumerate discrepancies, distinguish visual-map evidence from runtime passage flags, bound corrections and settle save-position policy |
| 3 | F07 / S07 #40 | Creation initialization research | Resolve initial-state and portal-flow gaps; preserve approved presentation without inventing historical defaults |
| 4 | F06 / S06 #39 | Control/calibration refinement | User movement feedback, exact tested build, measured or explicitly accepted tile calibration, reconcile uncommitted movement with sprint saves |

S05 evidence gathering is the best next activity during the coding pause: it has no dependency on new gameplay code and supports every future establishment feature. S07 is the strongest candidate for the next new player-facing foundation once its initialization questions and the test gate are settled. This is a recommendation, not a commitment to start it immediately.

## Findings

- F02/F03 automated acceptance is complete; their manual acceptance and merge remain pending. Sprint goal is unchanged.
- S08 #41 is closed, while F08 #15 remains open. Historical S30-ready text is stale; S30/S31/F01 subsequently completed. Feature completion should be assessed against the bounded stat-model contract, not all future stat-producing content.
- S05's former broad city-wide promise was not implementation-ready. It now distinguishes exhaustive audit classification from verified fidelity and requires evidence for directional faces and migrations.
- S06 cannot be treated as an untouched new story: the original working folder already has uncommitted incremental movement. Its six-units-per-tile calibration remains a reconstruction choice. No changes were made to those files.
- S07's creation formulas and basic supplies are documented, but initial maximum HP, all required secondary fields, portal timing and spawn/flow reconciliation are not established by that page alone. These are named research gates, not permission to invent values.
- Existing story IDs are retained. Each story now has explicit tasks and acceptance examples; none of these tasks is a separate sub-issue. If research uncovers a distinct substantial implementation, create and link a visible story before expanding scope.

## Deferred batch

Do not promote F04 weather, F09 metabolism or F10 items to Ready yet. Their existing placeholders span several interdependent systems. After this foundation batch, refine a bounded survival loop with explicit field ownership, elapsed-time ordering, clothing exposure and service dependencies. No estimate from the earlier SWAG overrides readiness gates.

## Evidence

Existing unchanged archives: Kroah characterCreation.html (Creation), characterStats.html (Primary/Secondary/Walking Speed), world.html (Calendar/Time Span/map legend) and Map.png. Existing project reviews: SOURCE_BASELINE.md, ST_LOCATION_CORRECTION.md, S08_STATS.md and F02_F03_ACCEPTANCE.md. Read-only comparison: original working folder docs/MOVEMENT.md. No new source download or gameplay change.
