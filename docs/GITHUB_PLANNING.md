# GitHub planning setup

Reviewed 2026-11-17. Recommendation: use GitHub Issues plus one user-owned GitHub Project for this repository. GitHub supports nested sub-issues and Project table, board and roadmap views. Published 2026-11-17: 7 epics, 26 features and 27 stories, linked through 53 native sub-issue relationships, with five undated milestones and a roadmap index. [Open the live roadmap](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/61). `GITHUB_BACKLOG_INDEX.json` maps local IDs to live issue URLs. GitHub issues are now the workflow-status authority.

The [GitHub Project](https://github.com/users/mcmcgreevy/projects/1) is now created with 61 items (60 backlog issues plus the roadmap index). It retains GitHub's private visibility and uses this repository as its default. Browser setup was used because the existing Git credential lacks Projects API scopes.

Configured views:

- [Backlog](https://github.com/users/mcmcgreevy/projects/1/views/1): native epic/feature/story hierarchy, with Status, sub-issue progress, Milestone, Labels and Parent issue columns.
- [Story board](https://github.com/users/mcmcgreevy/projects/1/views/2): 27 stories filtered by `kind:story`, with Backlog, Refining, Ready, In Progress, Playtest and Done stages.
- [Delivery phases](https://github.com/users/mcmcgreevy/projects/1/views/3): 26 features filtered by `kind:feature`, grouped by the five repository milestones. Dates remain uncommitted.

All imported work starts in Backlog. The initial import omitted E01; it was added and the final 61-item total and seven-epic hierarchy verified. Project Status is the live workflow authority; the initial `status:backlog` labels should be updated or removed as stories move rather than treated as a second independent workflow.


## Structure

- Epic: parent issue, label `kind:epic`; retain the E01–E07 IDs.
- Feature: child issue, label `kind:feature`; retain F01–F26.
- Story: child of its feature, label `kind:story`; retain S01–S27, then split/refine with new stable IDs.
- Research and defect work: labels `kind:research` / `kind:bug`, linked to the appropriate feature.

Use labels for these categories so the plan does not depend on organization-only issue-type administration. Keep taxonomy (`area:world`, `area:character`, etc.) separate from workflow status. An epic may span milestones; assign delivery milestones to stories and feature increments rather than forcing one milestone onto the whole epic.

Optional future Project fields (not created beyond Status; milestones and coverage labels currently serve Phase and Coverage): Status (Backlog, Refining, Ready, In progress, Playtest, Done); Priority (P0 regression, P1 foundation, P2 planned, P3 later); Phase (M1–M5/Later); Fidelity (Original ST, Dungeon 8-bit, Adaptation, Unresolved); Coverage (Not built, Scaffold, Prototype, Partial, Verified). Use start/target dates only when there is an actual forecast.

Views: backlog table grouped by epic/area; Ready/In progress/Playtest board for current work; milestone/phase table for the undated roadmap; dated roadmap view when forecasts exist. The roadmap layout itself is a timeline, so an undated phase plan is initially clearer in a table.

## Story template

Title: `[Sxx] Observable player/developer outcome`

Parent feature and epic IDs; user story; source page/section and edition; current behavior; intended behavior; acceptance examples; dependencies; uncertainty/adaptation notes; validation plan; migration implications. Link the implementing pull request to the issue.

## Initial population

The user authorized publishing the full reviewed baseline. All initial stories are open and labeled `status:backlog`; none is marked ready. Refine only the next small batch before implementation. Retain local BACKLOG/ROADMAP as the scope and decision baseline; use live issues as the status authority. The Project views are configured and saved.

## Verified documentation

- [About Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects): user- or organization-level planning with table, board and roadmap layouts.
- [Adding sub-issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues): parent/child issue hierarchy.

These pages and the REST sub-issues API documentation are now archived unchanged in `assets/documentation/github-planning/`, with URLs, retrieval dates and SHA-256 hashes in the documentation catalog. The earlier sandbox DNS limitation was resolved through authorized network access. These sources concern tooling only, not game rules.

## F01 refinement — 2026-11-18

Published [F01 completion criteria](F01_RULE_EFFECT_PLAN.md) and four M1 child
stories: [S28 #62](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/62),
[S29 #63](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/63),
[S30 #64](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/64), and
[S31 #65](https://github.com/mcmcgreevy/Alternate-Reality-Continues/issues/65).
Native sub-issue links verified. S01 #34 remains closed; its stale proposal text
was corrected. Repository backlog now contains 31 stories (65 planning issues
including the roadmap), rather than the initial 27-story snapshot above.

New stories carry `status:backlog`; no claim of Ready is made. S28 is the next
research candidate, with explicit readiness gates on the implementation stories.
Project membership/status for these four new issues remains unverified: the
existing API credential lacks Project access and computer-use app approval timed
out before board editing. Add #62–#65 to Project 1 with Status Backlog when access
is available. The old Project item count above is a historical snapshot.

## Project access resolved — 2026-11-19

GitHub CLI Project access verified. Project 1 contains 65 items; S28–S31
(#62–#65) were already present with Status Backlog. S01 remains Done and F01
remains Backlog. No board mutations were needed. The pending-addition record
has been cleared; the earlier access limitation is resolved.
