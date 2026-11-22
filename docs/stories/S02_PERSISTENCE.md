# S02 — Reliable journey persistence and deterministic replay

Readiness review: 2026-11-22. Implementation-ready after this refinement; not implemented or accepted by this review.
Parent: F02 (#9). Existing story: #35. These are three implementation tasks within S02, not additional or hidden sub-issues.

## Player outcome and scope
As a returning player, I can resume the same character and world state after an update, and a reported gameplay failure can be reproduced from saved state and the same actions/time inputs.

Scope is the production OriginalWorld journey, currently save version 7. Keep the separate prototype v1/v2 format working through regression tests; do not merge its format into the production journey. Music, camera/movement preferences and cosmetic storm/audio randomness are excluded from gameplay replay.

## Dependencies and sources
S03 clock, S08 stat validation, S30 runtime and S31 effect persistence are implemented. Reuse their contracts and regression suites.
- docs/SOURCE_BASELINE.md and docs/S03_CLOCK.md: approved clock precision and pause policy.
- docs/S31_ACCEPTANCE_REVIEW.md and scripts/journey_effects.gd: effect ownership and save semantics.
- third_party/ardungeon/11-s517.asm and docs/DUNGEON_LEVEL_ONE.md: random/fixed/preserved transition facing.
- Archived Kroah technicalNotes.html, Effect section, supplies historical effect context; it does NOT specify our JSON saves, filesystem replacement or random generator.
Persistence format and replay controls are remake architecture. No new original-game formula is needed.

## Task 1 — Complete-save validation and compatibility
- Inventory every persisted production field: version/map_set, chapter/position/facing, character/inventory, flags/doors, needs/provisions, weather seed, compatibility time views, precise clock and effects.
- Write explicit required/optional/type/domain rules, preserving existing supported fields and legacy defaults. Do not reject previously supported optional character extensions without documented migration.
- Keep v3–7 readable if a new version is introduced. Preserve clock remainder, active-effect deadlines/identity, stats, possessions, doors, chapter and position. Preserve existing neutral v3 needs/provisions and historical weather defaults.
- Missing file, malformed/truncated JSON, wrong types, unsupported versions, out-of-range coordinates/numbers and inconsistent clock/effect references fail without changing ANY live journey state, including random state and revision.
- Numeric validation precedes narrowing conversions; JSON numbers must not wrap into a valid position or other accepted integer.
- Fixtures cover each supported version, a complete current round trip, repeated reload and rejected inputs. Compare full relevant state, not only the field deliberately corrupted.

## Task 2 — Repeatable gameplay randomness
- Give random-facing Dungeon transitions a dedicated gameplay generator; persist its exact continuation state without JSON floating-point precision loss. Seed/time controls must be callable from tests without requiring a player-facing debug screen.
- Same saved state, action sequence and integer elapsed-time inputs yield the same facing, clock, weather, needs and effects after reload as uninterrupted play.
- Loading the same save twice reproduces the same sequence. Cosmetic randomness and unrelated global random draws cannot change gameplay outcomes.
- Fixed facing and preserve-facing transitions do not consume random draws.
- Legacy saves have no recoverable historical generator state: assign a documented stable migration seed (1701), once, and preserve the resulting state on subsequent saves. This does not claim to reconstruct old unsaved random outcomes.
- Keep existing weather-seed behavior; no weather-rule rewrite. Replay guarantee is within the supported engine/generator version, not across arbitrary future engine algorithms. Store a generator-format identifier and reject unsupported identifiers.
- Validate missing/malformed generator fields for the new format atomically. Keep new state in a new save version rather than silently requiring it in v7.

## Task 3 — Protect the last successful save
- Serialize a validated snapshot before replacing the destination. Write a sibling temporary file, check write/flush results, close it, then replace through an explicit failure-safe strategy.
- Failure to create/write/replace returns an error and leaves the previous save readable and unchanged. Never remove the sole good copy before the replacement is safe.
- Stale temporary files are not silently loaded as successful saves. Document cleanup/recovery behavior; if the platform requires a backup/rename sequence, define and test recovery between steps.
- Cover missing/unwritable target and injected write/replacement failures with a narrow file-operation seam where necessary. Do not simulate failure by filling the user's disk or modifying their real save.
- Document the actual crash/power-loss limits of the selected filesystem strategy; do not promise universal durability.

## Done evidence
Run focused new persistence/replay/failure checks, existing clock/character/effect/tavern/Dungeon/route regressions and isolated integrated save/load tests. Document format/migration and ownership in docs/CODE_GUIDE.md. Use worktree-specific APPDATA for every test or launch.
The user's previous manual playtest remains Not run. It does not block development readiness; record it separately and do not claim manual acceptance or merge into their playtest checkout.

