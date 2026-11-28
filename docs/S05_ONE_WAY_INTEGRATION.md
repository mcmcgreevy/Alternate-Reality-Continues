# S05 — Five changed one-way pairs: integration risk

2026-11-27. Research only; no gameplay or map edits. Follow-up to [whole-map pair review](S05_DIRECTIONAL_PAIR_REVIEW.md).

## Decision

Keep all five changed one-way pairs outside the proposed eight-face doorway/wall patch. Two approaches enter scenario cells; changing only their boundary values would let the current movement layer explore through those cells without the original scenario handoff. The three Arena closures must be considered with the same entry/exit design, not as an isolated symmetrization exercise.

## Exact hypothetical changes

| Approached face | Current → candidate | Consequence requiring integration |
| --- | --- | --- |
| (6,7) east | 3 → 14 | Blocks approach-to-Arena direction; reverse remains 3. |
| (25,8) west | 38 → 4 | Enables approach into marker46/type 6 at (24,8); reverse remains 13. |
| (16,12) west | 3 → 14 | Blocks approach-to-Arena direction; reverse remains 3. |
| (16,12) east | 3 → 14 | Blocks approach-to-Arena direction; reverse remains 3. |
| (59,16) south | 37 → 6 | Enables approach into marker47/type 6 at (59,17); reverse remains 13. |

These are the existing five candidate one-way pairs not preserved by current potential movement, not five additional differences. None has been changed in game data.

## Two-model route comparison

The [saved analysis](s05/five-pair-route-impact.json) applies those five values only, in memory, to the unchanged current map. Current movement eligibility is retained for all other faces, starting at (39,34). Supported doors are assumed examinable/openable; no game code is executed.

| Model | Before | After | Added | Lost |
| --- | ---: | ---: | ---: | ---: |
| Current map graph without scenario interception | 3267 | 3601 | 334 | 0 |
| Same graph treating type 6 scenario cells as terminal | 3263 | 3265 | 2 | 0 |

In the first model, newly reachable cells include 124 type 0, 206 type 6 and 4 type 8 cells. The second model adds only (24,8) and (59,17), both type 6. Baselines differ because the terminal model also stops at scenario cells already reachable today. Do not compare one model's before count with the other model's after count.

The terminal model is a deliberate analysis guard, not a historical behavior claim. It does not emulate loading, refusal, position restoration, character-slot restrictions or another chapter. It demonstrates why treating scenario markers as ordinary floor cells gives misleading accessibility results.

## Required owner coordination

S77 Arena and S78 Palace must implement or explicitly define supported scenario entry/refusal behavior before enabling these approaches. S05 owns source-boundary binding and directional invariants; the scenario stories own the player-visible outcome. S79 gate/approach cells retain their category distinctions. No additional hidden story is introduced.

Acceptance for any eventual combined change must cover both directions of these boundaries, the entered scenario cell, refusal/failure return to the exact previous position, save/reload at supported positions, and prevention of unintended free exploration through scenario interiors. Verify successful transitions only for chapters actually supported by the remake; this evidence does not authorize new chapters.

Also check previously inaccessible guild/scenario duplicates remain inaccessible as intended. The four additional type 8 cells in the unrestricted model show that the impact is not confined to Arena/Palace floor tiles. Identify exact affected content when defining a real patch; the model is not permission to activate those services.

## Review handoff update

The simple three-doorway/one-wall proposal remains unchanged. Its separate eight-face route review still applies. The five one-way pairs now have a concrete integration blocker rather than a generic request for more geometry evidence. Original behavior verification, save policy and complete S05 acceptance remain open.

Validation: exactly five directed changes, distinct physical pairs, preserved opposite values, model totals and type sums checked. Candidate category values come from the existing map extraction. No new source downloaded, source document modified, executable helper added or playtest claimed.
