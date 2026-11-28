# S31 — Preserve a timed stat effect across save and load

Parent: F01 (#8) · Epic: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

City source: Kroah Atari ST City v2.0. Start with `docs/SOURCE_BASELINE.md`,
`docs/RULE_MODEL.md` and `data/reference/rules.json`. Sources below are unchanged
HTML in `assets/documentation/kroah-city-st-v2/`, with hashes in the documentation
catalog. New research must follow the archive policy. No Dungeon fidelity claim.

## Completion — 2026-11-20

**Done.** All six criteria pass. [Acceptance, save format and playtest](../S31_ACCEPTANCE_REVIEW.md).
The readiness review confirmed S29/S30, S03, S08 and the existing atomic save/load interface.

## User story
As a player, my active timed stat effect resumes with the same remaining duration and consequences after loading a save.

## Scope and evidence
Integrate the shared runtime into the existing character/world save path with one evidence-backed effect: Physical Speed (+5 Speed bonus for 30 game minutes), from establishmentsGuilds.html Spells / Physical Speed; characterStats.html Primary and Walking Speed; technicalNotes.html Effect identity/lifecycle. A test-only activation hook may supply the spell to the real world instance; it must use the production runtime and does not add guild/casting gameplay ahead of F21/F13.

## Acceptance criteria
- [x] With base Speed 13, zero other modifiers and no delusion, apply the documented bonus: effective/displayed Speed 18, base unchanged; return to 13 after the resolved duration/removal. Walking rate is 6 both before and during this example. Apply and remove through the shared runtime and S08 contribution API, not a special-case timer.
- [x] At 10 game minutes into the 30-minute effect, save and load: 20 game minutes remain, the +5 contribution exists exactly once, and no activation action replays. Compare with uninterrupted play through expiry.
- [x] Preserve owner/definition/instance references, linkage, remaining timer precision, counter/incubation state and any required deterministic RNG continuation. Definitions are referenced/versioned as agreed, not serialized as arbitrary executable code.
- [x] A legacy save without effects loads with an empty effect set and unchanged prior character fields; a malformed/unknown effect reference rejects the load atomically under S02 policy. Test no partially replaced world state and no duplicated modifiers.
- [x] Exercise ordinary time, pause/resume, save/reload and City/Dungeon round trip using existing travel regressions. Persisting the same character effect across chapters is explicitly a remake integration policy, not a verified Dungeon spell rule.
- [x] Record a reproducible integrated playtest with the test hook, headless regression results, migration notes and updated CODE_GUIDE/rule coverage. No debug-only implementation path may substitute for production activation, ticking or serialization.

## Dependencies and exclusions
S29/S30 runtime, the S08 base/effective/displayed and owned-contribution slice, S03 clock slice and S02 save version/migration/atomic-load slice. S31 owns the effect payload and round-trip checks; S02 owns general persistence machinery. S10 later supplies item owners and item-use events; full inventory is not required. Full spell acquisition/casting, equipment, ailments, all content, and Dungeon rules fidelity remain outside F01.

## Validation and readiness
Run relevant save/load, stat, clock and original-route regressions plus uninterrupted-versus-reloaded effect tests. Before Ready: dependencies' interfaces and S28 Physical Speed semantics are settled; no unresolved blocker is waived. Status: Done; all dependencies verified and the bounded production path implemented. M1 foundation test hook avoids making this feature wait for M4 guild gameplay.

## Live tracking

- [F01 — issue #8](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/8)
- [S01 — issue #34](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/34)
- [S28 — issue #62](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/62)
- [S29 — issue #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63)
- [S30 — issue #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64)
- [S31 — issue #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65)
