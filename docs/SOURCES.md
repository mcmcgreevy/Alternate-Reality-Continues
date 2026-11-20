# Short source log

**Current source policy:** [Atari ST City v2.0 via Kroah is the canonical City rules baseline](SOURCE_BASELINE.md), accepted 2026-11-16. Earlier entries below preserve implementation provenance; they do not supersede this decision.

## Archived documentation

- 2026-11-18: [F01 runtime plan](F01_RULE_EFFECT_PLAN.md) uses the existing unchanged
  `establishmentsGuilds.html`, Spells / Physical Speed row (+5 Speed bonus for
  30 game minutes), together with Stats and Technical Notes, for a bounded future
  integration scenario. Runtime ordering and removal details remain S28 research;
  the table alone does not establish those semantics.


- 2026-11-18: [S01 rule model and effect contract](RULE_MODEL.md) links the
  [six seed records](../data/reference/rules.json) to unchanged Kroah Stats,
  World and Technical Notes HTML and catalog hashes. [Examples](../tests/fixtures/rule_examples.json)
  distinguish documented rules from the tile-distance adaptation; unresolved
  bounds, event ordering and timer units are tracked for downstream stories.

- 2026-11-16: [Kroah map image](../assets/documentation/kroah-city-st-v2/Map.png) and its existing archived legend verify Tail of the Dog at marker 16, Lost Oasis at marker 14, and the northern Dungeon entrance at marker 49. [Location correction and coordinate evidence](ST_LOCATION_CORRECTION.md) supersede the earlier starting-tavern identification below.

- 2026-11-16: [Kroah's Atari ST City v2.0 reverse engineering](http://bringerp.free.fr/RE/Ar/news.php5), [20-page local archive](../assets/documentation/kroah-city-st-v2/README.md). Detailed research on world/weather, character systems, equipment, encounters and establishments. Edition-specific research, not yet independently verified against the ST executable by this project. See [review and reconstruction implications](KROAH_ST_REVIEW.md); do not silently merge ST rules with 8-bit sources.

Reference documents are now preserved in [the assets documentation library](../assets/documentation/README.md), with provenance and hashes in its catalog. Future documents used for reconstruction should be archived there as well.

- 2026-11-15: [Official City Survival Handbook — ST/Mac/PC edition](../assets/documentation/arcity-survival-handbook-st-mac-pc.pdf), PDF page 4, **Weather and Clothing**. Supports temperature/rain exposure, clothing protection and indoor shelter. Edition-specific qualitative evidence; exact algorithms and 8-bit equivalence remain unverified. See library notes for the weather summary.

## Earlier source log

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

The City sky, stars, clouds, fixed sunrise/sunset and clock-based lighting are remake presentation choices. Roof classification is provisional and follows the secondary ARX location descriptions; it changes no original wall codes. Dungeon cells remain covered. See the City sky follow-up in ART_DIRECTION.md for classifications and limits.

First Excursion uses a tavern interaction screen. Its first meal/briefing/leave scaffold has now gained a limited source-informed food/drink service; exact menu wording, hourly sets and need/timing formulas remain remake choices. The full-healing two-gold meal has been removed. Leaving traverses the existing north boundary; entering restores the screen. Music and timed lyrics continue during menu use. The excursion adds no historical quest, reward or map geometry.

Dungeon JSON derives from original map data. Its source headers credit Jason Duerstock (2008) and the original program to Intellicreations (1987); the repository specifies GPL-2.0. All four level-one map sources/checksums, the runtime reference for transition decoding and upstream license are preserved in third_party/ardungeon. Transition behavior is implemented from the original table and dispatcher evidence. This attribution does not assert blanket rights to original game assets. No ARX implementation code was ported. The V tour and transition dots are invented playtest aids.

The 2026-11-15 [weather pass](WEATHER.md) presents the handbook's five conditions, rain and shelter. Hourly equal-probability selection, seeded scheduling, haze and rain rendering are remake choices, not recovered original algorithms. Character penalties and clothing protection remain pending.

- 2026-11-17: Planning taxonomy follows the navigation in the existing Kroah `news.html` archive. [Backlog](BACKLOG.md), [roadmap](ROADMAP.md), and [GitHub planning proposal](GITHUB_PLANNING.md) distinguish source categories from project adaptations. GitHub planning documentation URLs are cataloged; direct archival downloads failed (DNS), so no local copies are claimed.

- 2026-11-17: GitHub About Projects, Adding sub-issues and REST sub-issues API documentation now archived unchanged in `assets/documentation/github-planning/`; catalog includes hashes and original URLs. This supersedes the earlier failed-download limitation.

2026-11-19 — [S28 effect-runtime research](EFFECT_RUNTIME_CONTRACT.md): reviewed unchanged Technical Notes, Stats, World and Guilds HTML. Thirteen source-linked dispositions and thirteen classified traces document what is known and what still blocks S29–S31. Physical Speed is +5 bonus for 30 game minutes; timer units, scheduler order and rollback are not established by that spell row.

2026-11-19 — S29 definition/duplicate-gate foundation uses archived `technicalNotes.html`, Effect / +02 Allow multiple & Required events. Opaque raw eight-field equality is implemented; event/cleanup gaps from S28 remain unresolved.

2026-11-19 — [S29 original-ST executable research](S29_ST_EFFECT_RESEARCH.md): archived Kroah forum/current notes, AtariMania v2.0 listing and unchanged candidate disk. Reproducible extraction verifies all sectors in 32 encoded records against the loader checksum. Static analysis identifies opposing pairs, event branch order, linkage allocation and removal without arithmetic rollback. Candidate/prose discrepancies remain explicit; no gameplay rule was silently replaced.

2026-11-19 - [Isolated original-code follow-up](S29_ST_EFFECT_RESEARCH.md#isolated-execution-follow-up) uses the existing archived ST candidate; no new historical source downloaded. Ten M68000 scenarios narrow the S29 gaps and reproduce a duplicate-pointer discrepancy. Physical Speed uses distinct Add/Sub records, and removal itself performs no stat rollback.

2026-11-19 - S29 ownership follow-up: candidate module 12 Dagger/Leather Helmet records have empty effect lists (12 original-code scenarios total). New instance storage follows documented copy/link/H semantics with explicit reconstruction owner/group IDs; it does not resolve raw template byte-15 lookup. See S29_ST_EFFECT_RESEARCH.md.

2026-11-19 - Bounded S29 Use/Unuse dispatch follows Kroah’s opposing-removal/activation intent and the candidate dispatcher’s Use-before-Unuse branch order. Explicit listener/group bindings are reconstruction architecture, not a claim that the ambiguous original byte-15 mechanism was recovered. Get/Drop/Delete remain unsupported; no new source download.

S29 completion: [acceptance review](S29_ACCEPTANCE_REVIEW.md) reconciles generic Get/Drop/Use/Unuse/Delete with explicit owner/group bindings and records all adaptations. Thirteen original-code probes include held-state and actual owner deletion; no new external source was needed. Remaining timed/action/content questions are assigned downstream.

2026-11-20 — [S32 timing research](S32_ST_TIMING_RESEARCH.md) reuses the unchanged, cataloged Kroah pages and candidate ST disk. Eighteen original-code cases establish clock/effect cadence, phase and ordering. The user explicitly chose Kroah’s 30-minute Physical Speed duration and reliable elapsed-time processing over the candidate’s 29-minute active window and lost updates. No new historical source was downloaded; derived analysis is kept separate.
