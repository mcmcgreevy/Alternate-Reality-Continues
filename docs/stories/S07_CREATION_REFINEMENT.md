# S07 — Character creation
Parent: F07 (#14). Refined 2026-11-22. Source extraction ready; full implementation not Ready until the initialization gaps below are resolved. No new code authorized during user playtest pause.

## Player outcome
Create a source-grounded new character without replacing or rerolling an existing saved journey.

## Confirmed source contract
Archived Kroah characterCreation.html, Creation section:
- Six visible primary stats (Stamina, Charisma, Strength, Intelligence, Wisdom, Skill) and Hit Points each use 3 + three draws in inclusive 0..7, producing 3..24.
- Random copper wealth uses 63 + three draws in inclusive 0..63, producing 63..252.
- These are discrete sums, not uniform draws over the final ranges or a Gaussian approximation.
- Hidden starting Speed 13, alignment 128, unnoticeability 32, treasure finding 0; level 0 and experience 0.
- Three food packets, three water flasks, one gold coin in addition to rolled coppers; no weapon, armor or clothing.
- Sowings 29, Year 0, 06:00 via the existing clock. Do not implement a second calendar.
The source describes eight scrolling portal values; the seven upper values include HP, not hidden Speed.

## Research tasks before implementation
- Build an initialization matrix for every required production field: source-defined, derived with evidence, existing remake choice, or unresolved.
- Resolve initial maximum HP, missing secondary fields (including needs/rates and required experience), starting location/facing and modifier defaults from same-edition evidence. The Creation page alone does not settle all of these.
- Document portal roll/update/selection semantics and whether generation has shared/correlated draws. Deterministic software draw order is an adaptation unless historical order is verified.
- Preserve the approved tavern/Grimthorn experience, but do not infer that it authorizes an undocumented historical spawn. Present any real conflict with the portal/start flow explicitly before implementation.
- Define name input, cancel/new-game/load behavior, and when a new character replaces in-memory state. Propose no automatic overwrite of an existing save; saving remains an explicit action.
- Keep character creation randomness separate from continuing Dungeon gameplay. Define reproducible input sequences for tests without claiming to reproduce original random hardware timing.

## Acceptance examples for the settled contract
- Injected all-zero draws yield each upper value 3 and copper 63; maximum draws yield 24 and 252.
- Stat draw triple [0,3,7] yields 13; copper triple [0,31,63] yields 157. Verify exact sum behavior, not flaky sampled-distribution assertions.
- The HP roll initializes HP; it must not substitute for Speed or overwrite another primary stat. Maximum HP follows the separately verified initialization rule.
- Starting possessions and hidden values match the confirmed source; wealth normalization preserves total value through existing currency units.
- Confirming creates one complete valid journey; cancel leaves the current journey unchanged. Loading never rolls creation or adds starting supplies again.
- Newly created stats and supplies survive current-version save/load, with hidden Speed still hidden absent a supported reveal.
- Existing saves remain loadable and retain their existing stats/wealth rather than being 'corrected' into new-character defaults.
- Naming/portal behavior is usable by keyboard and preserves the approved presentation; defer opening-credit reconstruction to F26.

Dependencies: existing S08 state model, S03 clock, F01 effects and S02 persistence. No full item system is required merely to represent the existing food/water counts; do not pull equipment or metabolism simulation into creation. Coding waits for the user's test and closure of the specific initialization gaps.
