# The Way Back: A Foundation We Can Build On

Stakeholder sprint review for November 23–29, 2026. Accepted November 28. Planning and initial implementation began November 22. This is source material for a NotebookLM podcast, not a dialogue or recording transcript.

## The goal and the result

Our goal for this sprint was to establish a reliable foundation for continued gameplay development by completing two features: F02, Persistence and Deterministic Tests, and F03, Calendar and Time Span. In everyday terms, players should be able to leave the game and come back to the same journey, the game should keep time consistently, and we should have repeatable checks that catch mistakes as the project grows.

We met that goal. The player completed the playtest, closed the game, reopened it, and successfully recalled the saved journey. Movement felt more responsive. The last reported visual problem, an outdoor-looking glow at the end of Dungeon corridors, was corrected and accepted. The final feedback was that the result looked fantastic and made the torch lighting much more noticeable.

This is a foundation milestone. It gives us a more dependable base for adding the shops, guilds, services and other encounters that will make the world feel inhabited. It does not mean those future systems are already complete.

## What players gained

Saving now preserves more than a character's position and possessions. It retains precise game time, temporary effects and the state needed to continue supported random gameplay events consistently. Loading repeatedly should not stack a temporary bonus or resurrect an expired one. Older supported saves can migrate into the current format.

The save process also protects the previous successful save when a new write fails or is interrupted during replacement. Invalid saves are checked before they can alter the live journey. These protections matter because a damaged save should not quietly leave a player with a half-restored character or world.

The calendar and time systems have been reviewed together with persistence. Ordinary play, accelerated service time and pauses follow the agreed rules. Crossing a month or year boundary does not lose the remaining duration of an effect. The underlying clock is shared consistently so movement and other activity do not accidentally charge time twice.

We also brought the earlier movement and weather improvements into the final integration. Movement is driven by character Speed, and the player's report confirmed a much better sense of control when releasing a direction key. Speed is now visible in the stats display from the start, an explicitly approved interface improvement. Weather audio adjustments were preserved as part of bringing the branches together.

The Dungeon's distant opening is now dark instead of looking like a patch of daylight. That small visual correction has a larger effect on atmosphere: the underground space reads as underground, and the torch lighting has room to stand out.

## What the testing taught us

The final integrated build passed 22 headless test suites and a separate test using the actual graphics renderer. The counted suites contain 854 checks, with additional suites reporting pass or fail. Coverage includes saving, older-save migration, failed writes, temporary effects, calendar boundaries, movement, weather and travel between the City and Dungeon.

One especially useful lesson came from the Dungeon lighting defect. The game settings said the background was black, and the earlier checks passed. The image on screen still showed a bright opening because the City sky remained attached to the indoor environment. We reproduced the player's exact view and checked the rendered pixels at dawn, noon and night. That tests what the player actually sees, in addition to what the configuration says should happen.

Human playtesting supplied evidence the automated checks could not: the save survived a real restart, movement felt better, and the corrected lighting looked right. We kept those observations distinct from the automated results instead of treating a general approval as a separate recorded pass for every checklist item.

There are still boundaries to these guarantees. Saves assume one running game writes to a given save location. The recovery work is not a promise against physical disk failure or every power-loss scenario. Repeatable random continuation depends on the supported engine generator. Some scene tests still report resource-cleanup warnings at shutdown, although their gameplay assertions pass.

## Research continued while playtesting was pending

We also made substantial progress on S05, the City location and map research story. This was additional work beyond the sprint goal, and it remains open. The research has not yet changed the City's map or implemented the proposed location services.

The practical result is a much more concrete backlog. We created 75 location and research stories: 57 service locations, 11 scenario or entrance stories, and seven research stories. These are actual linked GitHub issues, so a stakeholder can follow individual locations rather than trying to interpret a list of unresolved questions inside one large story. Creating those issues represents planning progress, not 75 completed pieces of gameplay.

The comparison reached every City cell and all 16,384 directional faces. We classified 256 differences between the candidate ST map data and the current map. That does not make every face historically verified. Matching numbers alone cannot prove matching behavior, and some visual and interaction questions remain unresolved.

That distinction prevented a potentially expensive mistake. Some map changes that look like simple doorway corrections could open routes into unfinished Arena or Palace areas. We documented those dependencies before making the changes. The next implementation work can therefore account for the encounter or scenario behind an entrance, not just whether a player can walk through it.

Other findings will help avoid subtle inconsistencies later. For example, the two Da Place shop locations appear to share shop state. Treating them as completely independent shops could produce the wrong inventory or visit behavior. Findings like this give future stories a clearer starting point.

## A clearer decision about historical fidelity

We formalized the source policy for shared mechanics. Kroah's documentation of Atari ST The City version 2.0 is the City rules baseline. Verified 8-bit Dungeon evidence remains the baseline for Dungeon-specific content. For mechanics shared by both chapters, we use the ST City rules unless a documented Dungeon-specific requirement justifies an exception.

This is an approved reconstruction decision, not a claim that an unreleased ST Dungeon behaved a particular way. We did not locate a verified ST Dungeon executable or a comparable public rules breakdown. Conflicts and gaps stay visible in the documentation, and approved interface or presentation improvements remain identified as adaptations.

That policy gives us a consistent way to make decisions without pretending that every historical question has already been answered.

## What comes next

The completed persistence and time foundations remove important obstacles to richer gameplay. The next planning focus is to turn the S05 research into bounded implementation work, resolve the remaining entrance and scenario dependencies, and select location stories with clear acceptance criteria.

We should continue to distinguish a location that exists on the map from one whose full functionality is implemented. We should also keep using short player-facing checks alongside the automated tests, especially when changes affect movement, atmosphere or interactions. This sprint demonstrated why both forms of evidence matter.

The outcome is a game that is more dependable to resume, more consistent about time, and more convincing to explore, together with a backlog that makes the remaining work easier to understand and follow.

## Supporting records

- Sprint goal: docs/SPRINT_2026-11-23.md
- Feature acceptance: docs/F02_F03_ACCEPTANCE.md
- Final integration evidence: docs/SPRINT_CLOSEOUT_2026-11-28.md
- Save behavior and limitations: docs/S02_ACCEPTANCE_REVIEW.md
- Dungeon visual correction: docs/DUNGEON_DISTANCE_RETEST.md
- Research handoff: docs/S05_REVIEW_HANDOFF.md
- Location backlog: docs/LOCATION_STORIES.md
- Source decisions: docs/SOURCE_BASELINE.md
