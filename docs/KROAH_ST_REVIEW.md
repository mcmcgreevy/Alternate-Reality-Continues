# Atari ST reverse-engineering review

**Decision accepted, 2026-11-16:** the user adopted Kroah's Atari ST City v2.0 research as our City source of truth. See [the baseline policy and reconciliation list](SOURCE_BASELINE.md). The recommendation below is now resolved.

Reviewed 2026-11-16. Source: [Kroah's Alternate Reality pages](http://bringerp.free.fr/RE/Ar/news.php5). The author identifies the target as **The City, Atari ST v2.0** and explicitly distinguishes it from 8-bit City. This is detailed reverse-engineering research, not a shipped manual or independent verification of the executable by this project.

Twenty linked documentation pages are archived in [the local collection](../assets/documentation/kroah-city-st-v2/README.md). Closely reviewed: introduction, world/weather/temperature, character stats, metabolism, clothing, tavern services, and the technical entity/effect description. The remaining archived sections are available for later subsystem reviews; archiving does not mean every algorithm has been validated.

## Consequences for our current scaffold

| Area | Finding and implication |
| --- | --- |
| Weather | The [world page](http://bringerp.free.fr/RE/Ar/world.php5#Weather) describes sixteen types, monthly weights and season-dependent durations. Replace the provisional equal-probability hourly picker if adopting ST rules. |
| Rain/storm | Rain intensity and lightning frequency are distinct. Our automatic thunder in every Rainy condition should eventually distinguish ordinary rainfall from storms. |
| Temperature | The [temperature section](http://bringerp.free.fr/RE/Ar/world.php5#Temperature) combines season, weather and time of day. Ambient temperature must be separate from precipitation. |
| Time | The site describes continuous accelerated game time; our action-based minutes are a deliberate prototype departure. Decide clock fidelity before implementing metabolism intervals. |
| Character warmth | [Metabolism](http://bringerp.free.fr/RE/Ar/characterMetabolism.php5#Warmth) derives warmth from clothing and surroundings, with a fixed indoor value. Our Cold/Rainy exposure flags are only placeholders. |
| Stats | [Primary stats](http://bringerp.free.fr/RE/Ar/characterStats.php5#Primary) distinguish base, effective, displayed, bonus and penalty values, including hidden Speed. Flat mutable stats would make temporary effects and restoration difficult to reproduce. |
| Items/effects | [Technical notes](http://bringerp.free.fr/RE/Ar/technicalNotes.php5) describe item-triggered effects and active effect instances. Treat worn equipment and temporary modifiers as distinct from underlying base stats. |
| Tavern rules | [Tavern tables](http://bringerp.free.fr/RE/Ar/establishmentsTaverns.php5#FoodsDrinks) give base prices, tavern multipliers, menu selection and friendship effects. Our prices and menu rotation are provisional, not an ST reconstruction. |

Specific warmth findings: cold increases Speed and Skill penalties by five; overheating increases thirst and fatigue rates. The building warmth value is 72°F. These findings refine the earlier manual-level description; formulas, fixed-point precision, thresholds and update ordering still need careful extraction and executable cross-checks before implementation.

One concrete edition conflict: our current free tavern water follows the 8-bit handbook, while this ST table lists a base water price. The ST Tail of the Dog price factor is 2.0. Do not silently substitute these values into the existing 8-bit-derived menu. The tavern's current geographic identity also needs edition-specific verification before moving it or changing its pricing model.

## Recommended next work, not implemented here

1. Completed: ST v2.0 via Kroah is the City rules baseline. Dungeon geometry retains its verified 8-bit provenance. A combined game remains a deliberate adaptation.
2. Extract small, attributed data tables and test fixtures one subsystem at a time. Keep uncertain interpretations and known original bugs separate from intended behavior.
3. Establish calendar/clock, weather type and ambient temperature; preserve F6 as a playtest override while expanding it to test temperature and storm intensity independently.
4. Build base/effective stat modifiers, equipment effects and character warmth, then integrate metabolism on the agreed clock.
5. Reconcile tavern economics and other establishment rules against the selected edition.

No gameplay, saved-state schema, weather algorithms or asset behavior changed during this research review. The existing weather documentation remains a record of the current implementation; this review supersedes its suggestion that detailed ST weather documentation is unavailable.
