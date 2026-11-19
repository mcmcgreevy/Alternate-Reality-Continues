# Development roadmap

Published to GitHub on 2026-11-17: [live roadmap and epic index](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/61). Live issues are the workflow-status authority; this file preserves the planning baseline. See [issue ID mapping](GITHUB_BACKLOG_INDEX.json) and the [live GitHub Project](https://github.com/users/mcmcgreevy/projects/1).

Draft for review — 2026-11-17. Goal: a relatively faithful Atari ST City reconstruction before substantial redesign, retaining accepted modern presentation and verified 8-bit Dungeon geography. See [BACKLOG.md](BACKLOG.md) for epic/feature/story IDs and [SOURCE_BASELINE.md](SOURCE_BASELINE.md) for edition policy.

Milestones describe dependency order and playable exit criteria, not promised dates. Feature milestone assignments mean the first delivery phase; broad features may span phases. Establish estimates only after refining stories and observing delivery pace.

| Milestone | Focus and initial features | Playable exit criteria | Depends on |
| --- | --- | --- | --- |
| M0 — Current scaffold | Existing map travel, tavern/music, weather presentation, continuous clock, Speed-based motion, saves and tests | Baseline preserved; present prototype departures listed. This is a retrospective baseline, not a fidelity-complete release. | Existing build |
| M1 — Character and world foundations | F01–F03, F05–F08: rule ledger, persistence, calendar, map audit, movement calibration, creation and stats | Create/save/load a character; verify base/effective/displayed stats and modifiers; calendar and continuous time agree; explain remaining geography and movement-scale gaps. | M0 |
| M2 — A day of survival | F04, F09–F10, F15–F16, F18: seasonal weather, temperature, basic inventory/clothing, metabolism, shops, taverns and inns | Buy and equip clothing; experience heat/cold/rain consequences; eat, drink and rest; time and needs stay consistent through save/load. Tail of the Dog retains approved presentation with reconciled service rules. | M1 stats, time, effects and persistence |
| M3 — Encounters and physical combat | F11–F14, F19–F20; weapon/armor portions of F10 | Meet generated opponents; fight or use supported nonmagical responses; resolve damage, retreat, defeat, rewards and level advancement; use smithies/healers. Spell actions remain explicitly deferred until M4. | M2 survival/equipment and M1 stats |
| M4 — Complete City systems | F17, F21–F22; magical items/curses from F10; casting from F13; all deferred establishment jobs | Banking, work, guilds, spells and curses operate with correct effects and accelerated time. Finish deferred combat actions and establishment relationships. Full menu coverage review finds no untracked gameplay category. | M3 encounter resolution; shared item/effect and service infrastructure |
| M5 — Fidelity and release | F23–F26 plus unresolved gaps from all epics | Complete integrated City playthrough and City/Dungeon round trip; deliver opening credits with verified attribution and skip/replay; verify migration, performance, audio/captions and controls; explicitly accept remaining edition adaptations; produce a stable release. | M1–M4 exit criteria |
| Later — Deliberate expansion | New mechanics, deeper Dungeon content and broader redesign | Scope each change against the established faithful baseline. | M5 and separate prioritization |

## Dependency details

- Stats and the effect lifecycle precede warmth penalties, encumbrance, equipment modifiers, combat and magic.
- Calendar and scheduler precede seasonal weather, opening hours, jobs, sleep and metabolism cadence.
- Inventory identity and atomic currency transactions precede equipment and trading. M2 establishes the item model and clothing/consumables; M3 adds weapons/armor; M4 completes magical items and curses.
- Encounter generation precedes combat; combat outcomes precede rewards. Nonmagical combat can be playtested before guilds; the Combat feature cannot be closed until M4 casting is integrated.
- Jobs are shared behavior delivered through multiple establishment menus, not separate implementations of the same clock/payment rules.
- Geography auditing can run alongside rule work, but an establishment cannot be declared complete without its verified identity and entrance.
- Dungeon-specific rule fidelity is a separate research scope. Existing traversal remains supported; do not silently promote City rules to a verified Dungeon implementation.

- Opening credits (F26): research original presentation and prepare the storyboard earlier as an independent presentation task; integrate and finish by M5. Final production depends on reviewed credit text, artwork/music and the title/menu flow, not on finishing combat.

## First development slice

S01 is complete. F01 now has a [bounded completion plan](F01_RULE_EFFECT_PLAN.md): S28 evidence/design, S29 event runtime, S30 timed execution and S31 saved-effect integration. S28 research is complete with [explicit implementation blockers](EFFECT_RUNTIME_CONTRACT.md). Refine S08/S03 and resolve the F01 evidence gates next: document quantities and effect ordering, establish base/effective/displayed stats with reversible modifiers, and close the calendar/clock gaps. Then refine S10/S04/S09 into a clothing-and-weather survival slice. This directly connects the systems already visible in the game to real character consequences.

## Planning cadence

Keep only the next small batch of stories Ready. At each milestone, playtest its exit scenario, update coverage and deviations, and refine the next milestone. New discoveries become research/defect stories linked to their parent feature. Set dates only after estimating refined work; a dependency-ordered roadmap is more honest than a calendar assembled from guesses.
