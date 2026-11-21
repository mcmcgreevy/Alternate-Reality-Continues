# Development backlog

Published to GitHub on 2026-11-17: [live roadmap and epic index](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/61). Live issues are the workflow-status authority; this file preserves the planning baseline. See [issue ID mapping](GITHUB_BACKLOG_INDEX.json) and the [live GitHub Project](https://github.com/users/mcmcgreevy/projects/1).

Draft for review — 2026-11-17. Planning only; no new gameplay is authorized by a backlog entry. This is a scoped first pass, not a claim that every source algorithm has been analyzed.

Hierarchy: **epic → feature → user story**. Stable IDs are portable to GitHub. Menu taxonomy is taken from the archived `news.html` navigation; linked pages are already in the documentation library. News, Links and Forum are reference/navigation pages, not gameplay epics. World travel is cross-listed with Character Stats.

Each feature below has initial outcome stories with acceptance criteria. Large features must be split into smaller implementation stories during refinement; later-phase stories are intentionally not sprint-ready. No estimates or calendar deadlines are implied.

Status means current implementation coverage: **Partial** = some working behavior, **Prototype** = playable substitute requiring ST reconciliation, **Scaffold** = supporting code only, **Not built** = no current implementation. None means verified fidelity complete. Milestones are defined in [ROADMAP.md](ROADMAP.md).

## E01 — Rules infrastructure

Menu: Technical Notes.

### F01 — Rule/effect model

Parent: E01 · Milestone: M1 · Coverage: Scaffold · Source: [technicalNotes](../assets/documentation/kroah-city-st-v2/technicalNotes.html).

Feature outcome, acceptance and ownership: [F01 completion plan](F01_RULE_EFFECT_PLAN.md). S01 is complete; shared runtime and integrated persistence remain.

**S01:** Establish rule provenance and effect contracts. Completed; [specification](stories/S01_RULE_PROVENANCE.md).

Acceptance: Six-rule catalog, effect contract, source-derived fixtures and validator delivered. No runtime effects engine.

**S28:** Resolve the bounded effect-runtime contract. Research completed 2026-11-19; [findings and implementation blockers](EFFECT_RUNTIME_CONTRACT.md).

Acceptance: Source-linked decisions, trace fixtures and operation support matrix; unresolved findings explicitly gate implementation. [Specification](stories/S28_EFFECT_SEMANTICS.md).

**S29:** Instantiate effects and handle entity events. Completed.

Acceptance: Definition/instance/owner separation, supported event lifecycle, linked removal and duplicate suppression with deterministic tests. [Specification](stories/S29_EFFECT_EVENTS.md).

**S30:** Execute timed effects through the game clock. Completed; [acceptance evidence](S30_ACCEPTANCE_REVIEW.md).

Acceptance: Agreed timer/action semantics, single game-time input, deterministic execution and explicit unsupported-definition handling. [Specification](stories/S30_EFFECT_TIMING.md).

**S31:** Preserve a timed stat effect across save and load.

Acceptance: Physical Speed +5 for 30 game minutes through production runtime; save at minute 10 resumes with 20 remaining without duplicate contribution; migration and integrated regressions pass. [Specification](stories/S31_EFFECT_SAVE_INTEGRATION.md).

**S32:** Resolve original effect timing and scheduler order. Completed; [evidence and approved timing contract](S32_ST_TIMING_RESEARCH.md). S03-CLOCK/S08-SPEED and S30 are complete.

Acceptance: Verify raw timer units, first-update phase, incubation and simultaneous-work order with reproducible original-code evidence; settle the bounded support contract and hand off clock/stat requirements. [Specification](stories/S32_EFFECT_TIMING_RESEARCH.md). S30 also requires S03-CLOCK and S08-SPEED below.

### F02 — Persistence and deterministic tests

Parent: E01 · Milestone: M1 · Coverage: Partial · Source: [technicalNotes](../assets/documentation/kroah-city-st-v2/technicalNotes.html).

**S02:** As a returning player, I can resume the same character and world state after an update.

Acceptance: Version saves; migrate current saves; reject invalid data atomically; deterministic seeds and time controls reproduce failures.

## E02 — World

Menu: Xebec’s Demise.

### F03 — Calendar and Time Span

Parent: E02 · Milestone: M1 · Coverage: Partial · Source: [world](../assets/documentation/kroah-city-st-v2/world.html).

**S03:** As a player, I experience the documented calendar and passage of time while exploring and using services. Completed; [implementation and acceptance](S03_CLOCK.md).

Acceptance: Verify start date, calendar rollover, pause rules and accelerated service time; preserve continuous clock without double charging.

S30 prerequisite complete: [S03-CLOCK — elapsed-time interface and fixtures](stories/S03_CLOCK_INTERFACE.md).

### F04 — Weather and Temperature

Parent: E02 · Milestone: M2 · Coverage: Prototype · Source: [world](../assets/documentation/kroah-city-st-v2/world.html).

**S04:** As a traveler, I encounter seasonal weather and temperature that determine my exposure.

Acceptance: Extract documented types, weights, durations and temperature calculation; distinguish precipitation from storms; deterministic tests cover seasonal boundaries.

### F05 — Map and establishments

Parent: E02 · Milestone: M1 · Coverage: Partial · Source: [world](../assets/documentation/kroah-city-st-v2/world.html).

**S05:** As a traveler, I can navigate to correctly identified establishments through the original passages.

Acceptance: Audit remaining City cells and establishment identities against ST evidence; test directional boundaries and entrances; record unresolved geometry.

### F06 — Speed and incremental travel

Parent: E02 · Milestone: M1 · Coverage: Partial · Source: [characterStats](../assets/documentation/kroah-city-st-v2/characterStats.html).

**S06:** As a player, my effective Speed determines how quickly I travel and how much time the journey takes.

Acceptance: Retain fractional camera/map movement; test modifiers and frame rates; document or measure tile-distance calibration and settle tap/release behavior in playtesting.

## E03 — Character systems

Menu: Character.

### F07 — Creation

Parent: E03 · Milestone: M1 · Coverage: Not built · Source: [characterCreation](../assets/documentation/kroah-city-st-v2/characterCreation.html).

**S07:** As a new player, I create a character using the original generation rules.

Acceptance: Extract creation rules and initial state; test valid ranges and deterministic fixtures; initialize all dependent character fields.

### F08 — Stats: Primary and Secondary

Parent: E03 · Milestone: M1 · Coverage: Prototype · Source: [characterStats](../assets/documentation/kroah-city-st-v2/characterStats.html).

**S08:** As a player, my abilities reflect base values, temporary effects and earned changes. Completed; [implementation and acceptance](S08_STATS.md). Completed; [implementation and acceptance](S08_STATS.md).

S30 prerequisite: [S08-SPEED — typed Speed-bonus actions and fixtures](stories/S08_STAT_ACTION_INTERFACE.md). This narrow deliverable does not require completion of every stat system.

Acceptance: Separate base/effective/displayed values, modifiers and hidden stats; preserve documented precision; prevent modifier stacking and removal errors.

### F09 — Metabolism

Parent: E03 · Milestone: M2 · Coverage: Prototype · Source: [characterMetabolism](../assets/documentation/kroah-city-st-v2/characterMetabolism.html).

**S09:** As a player, I must manage hunger, thirst, fatigue, digestion, inebriation, warmth and encumbrance.

Acceptance: Extract each named subsystem and update order; test thresholds, elapsed intervals and recovery; food, shelter and equipment alter the correct quantities.

### F10 — Items

Parent: E03 · Milestone: M2 · Coverage: Prototype · Source: [characterItems](../assets/documentation/kroah-city-st-v2/characterItems.html).

**S10:** As a player, I can carry, equip and use items with their documented benefits and drawbacks.

Acceptance: Cover weapons, armor, clothes, potions, other items and curses; define equipment slots, weight, charges and effects from evidence; save item instances safely.

## E04 — Encounters and progression

Menu: Encounters.

### F11 — Denizens

Parent: E04 · Milestone: M3 · Coverage: Not built · Source: [encountersDenizens](../assets/documentation/kroah-city-st-v2/encountersDenizens.html).

**S11:** As a traveler, I meet inhabitants with the documented identities and traits.

Acceptance: Extract denizen definitions with provenance; validate identifiers and all referenced traits; avoid invented missing data.

### F12 — Opponent: Frequency, Creation, Melody

Parent: E04 · Milestone: M3 · Coverage: Not built · Source: [encountersOpponent](../assets/documentation/kroah-city-st-v2/encountersOpponent.html).

**S12:** As a traveler, I encounter opponents appropriate to the documented conditions.

Acceptance: Test generation and encounter frequency with seeded fixtures; implement melody selection or mark missing audio as an explicit asset gap.

### F13 — Combat

Parent: E04 · Milestone: M3 · Coverage: Not built · Source: [encountersCombat](../assets/documentation/kroah-city-st-v2/encountersCombat.html).

**S13:** As a player, I can resolve encounters through combat, negotiation or escape.

Acceptance: Track awareness, sequence, engagement, alignment penalties, casting, attack/lunge, damage, trick, charm, offer, leave and opponent actions as separate stories before implementation; verify order and boundary outcomes.

### F14 — Rewards

Parent: E04 · Milestone: M3 · Coverage: Not built · Source: [encountersRewards](../assets/documentation/kroah-city-st-v2/encountersRewards.html).

**S14:** As a survivor, I receive the correct experience, level advancement, treasure and recorded statistics.

Acceptance: Award outcomes exactly once; test level thresholds and treasure generation; persist progression; reconcile death and defeat rules with source evidence.

## E05 — City services

Menu: Establishments.

### F15 — Inns

Parent: E05 · Milestone: M2 · Coverage: Not built · Source: [establishmentsInns](../assets/documentation/kroah-city-st-v2/establishmentsInns.html).

**S15:** As a tired traveler, I can pay for lodging and recover through sleep.

Acceptance: Implement sleeping terms, time and recovery; connect inn jobs to F22; reject unavailable or unaffordable services without partial charges.

### F16 — Taverns

Parent: E05 · Milestone: M2 · Coverage: Prototype · Source: [establishmentsTaverns](../assets/documentation/kroah-city-st-v2/establishmentsTaverns.html).

**S16:** As a patron, I receive the documented welcome, service and relationship effects at each tavern.

Acceptance: Reconcile acceptance, friendship, welcome, foods/drinks, buying rounds and jobs; resolve ST water pricing explicitly; preserve Grimthorn, Tail of the Dog and approved music.

### F17 — Banks

Parent: E05 · Milestone: M4 · Coverage: Not built · Source: [establishmentsBanks](../assets/documentation/kroah-city-st-v2/establishmentsBanks.html).

**S17:** As a customer, I can use banking and appraisal services during valid opening hours.

Acceptance: Cover opening hours, accounts, appraisal and jobs; extract transaction rules; test rounding, insufficient funds and save restoration.

### F18 — Shops

Parent: E05 · Milestone: M2 · Coverage: Not built · Source: [establishmentsShops](../assets/documentation/kroah-city-st-v2/establishmentsShops.html).

**S18:** As a customer, I can obtain clothing and supplies through the documented shop interactions.

Acceptance: Cover acceptance, friendship, welcome, wares and bargaining; connect inventory and currency atomically; test stock and price rules.

### F19 — Smithies

Parent: E05 · Milestone: M3 · Coverage: Not built · Source: [establishmentsSmithies](../assets/documentation/kroah-city-st-v2/establishmentsSmithies.html).

**S19:** As an adventurer, I can obtain equipment through smithy trading.

Acceptance: Cover acceptance, friendship, welcome, wares and bargaining from smithy-specific tables; test weapon/armor transactions and equipment effects.

### F20 — Healers

Parent: E05 · Milestone: M3 · Coverage: Not built · Source: [establishmentsHealers](../assets/documentation/kroah-city-st-v2/establishmentsHealers.html).

**S20:** As an injured player, I can seek documented treatment when a healer is available.

Acceptance: Implement opening hours and supported services; test eligibility, prices, timing and effects; do not invent cures for unspecified conditions.

### F21 — Guilds

Parent: E05 · Milestone: M4 · Coverage: Not built · Source: [establishmentsGuilds](../assets/documentation/kroah-city-st-v2/establishmentsGuilds.html).

**S21:** As a player, I can gain guild benefits, learn spells and seek curse removal.

Acceptance: Cover bonuses, acceptance, spells and removing curses; share spell resolution with combat; test persistent and temporary effects separately.

### F22 — Jobs Summary

Parent: E05 · Milestone: M4 · Coverage: Not built · Source: [establishmentsJobsSummary](../assets/documentation/kroah-city-st-v2/establishmentsJobsSummary.html).

**S22:** As a player, I can earn income by taking eligible jobs.

Acceptance: Reconcile jobs offered by inns, taverns and banks with the summary; test requirements, elapsed time, metabolism and payment exactly once.

## E06 — Dungeon integration

Menu: Project adaptation — not a Kroah menu section.

### F23 — Edition boundaries and Dungeon journey

Parent: E06 · Milestone: M5 · Coverage: Partial · Source: [world](../assets/documentation/kroah-city-st-v2/world.html).

**S23:** As a player, I can travel between the City and Dungeon without losing character state.

Acceptance: Retain verified 8-bit Dungeon geometry; document every shared ST rule adaptation; audit transition, save and progression behavior before expanding Dungeon content.

## E07 — Presentation and release quality

Menu: Project adaptation — not a Kroah menu section.

### F24 — Audio, visuals and accessibility

Parent: E07 · Milestone: M5 · Coverage: Partial · Source: [world](../assets/documentation/kroah-city-st-v2/world.html).

**S24:** As a player, I can understand and control the game presentation.

Acceptance: Preserve music/vocal/subtitle options and quieter weather mix; review caption timing and text readability; playtest incremental movement and input comfort.

### F25 — Fidelity audit and release

Parent: E07 · Milestone: M5 · Coverage: Not built · Source: [technicalNotes](../assets/documentation/kroah-city-st-v2/technicalNotes.html).

**S25:** As a player, I can complete a stable City playthrough with documented deviations.

Acceptance: Resolve or explicitly accept each fidelity gap; exercise creation, survival, trading, combat, progression and save migration; publish known limitations and reproducible release checks.

### F26 — Opening credits

Parent: E07 · Milestone: M5 (research/storyboard can begin earlier) · Coverage: Not built · Source: user-requested scope; original opening sequence and attribution evidence still to be researched and archived.

**S26:** As a player, I see opening credits that establish the game's identity and acknowledge its creators.

Acceptance: Research the original Atari ST opening presentation and archive available reference material; distinguish faithful elements from remake choices. Prepare a storyboard covering credit text, order, timing, transitions, artwork and music. Verify names and roles for original creators, remake contributors and used assets against evidence; flag missing attribution rather than inventing it. Review the storyboard before producing the sequence.

**S27:** As a player, I can watch, skip and replay the opening credits without disrupting my game.

Acceptance: Implement the reviewed sequence at startup with readable text and audio preferences respected; provide discoverable keyboard skip and a replay entry from the title/menu flow. Completion and skipping reach the same intended menu state, stop credit audio cleanly and do not advance world time or alter saved character state. Test first launch, subsequent launch, replay and muted playback. Define any automatic-repeat preference during refinement.

Dependencies: F24 presentation/audio controls; title/menu entry and return flow (included in this feature's scope). Full character and combat implementation are not prerequisites for research or a sequence prototype. F25 release acceptance includes the finished opening credits.

## Definition of ready and done

**Ready:** small observable outcome; exact archived section and edition identified; rules/units/order extracted; dependencies satisfied; unresolved questions stated; acceptance examples agreed. A research story can close with evidence and an explicit unresolved result, not invented mechanics.

**Done:** acceptance checks pass; integrated gameplay has been exercised; saves remain compatible or migrate; CODE_GUIDE and source/deviation notes reflect the implementation; user-facing behavior is playtested when relevant. A whole epic closes only when its required child stories meet these criteria.

## First stories to refine

- S28 research is complete. S29 is complete; resolve the remaining S30/S31 evidence and interface gates before marking implementation Ready.
- S08: base/effective/displayed stats and modifier lifecycle, including Speed.
- S03: calendar and remaining clock/service reconciliation.
- S10: inventory instances and clothing equipment, then S04/S09 exposure and metabolism.

Track defects separately and link them to the affected feature; urgent regressions may interrupt the roadmap. Existing accepted presentation is retained while rules are reconciled.
