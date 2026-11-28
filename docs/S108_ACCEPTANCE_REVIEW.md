# S108 implementation and acceptance

November 28, 2026. Implemented on `codex/s108-city-map-corrections`. Automated acceptance passes; manual route/visual acceptance remains pending. S108 is not Done and this gameplay branch is not merged.

## Exact correction and provenance

Changed exactly eight directed faces in `data/maps/city.json`: (10,30) south/(10,31) north, (11,31) east/(12,31) west and (10,32) east/(11,32) west from 13 to 3; (26,34) south/(26,35) north from 5 to 13. All other cell fields remain unchanged. No service encoding, Arena/Palace approach, southeast crossing or Dungeon map changed.

Evidence is the unchanged archived Kroah ST City v2.0 Map.png, the annotated crops in `docs/s05/priority-face-review.png`, and matching candidate face data. [Exact diff and source hashes](s108/map-change-verification.json) record the implementation. Existing E-to-open and independent approached-face state are remake interaction behavior, not newly demonstrated ST input semantics.

## Save and geometry policy

New saves use version 9 and require `city_geometry_revision: 1`; versions 3–8 remain readable. Map-set identity remains `original-route-1`. Unknown, missing, mistyped or unsupported revision values in v9 reject atomically. A pre-v9 version carrying a geometry revision also rejects, rather than discarding a newer contract. Version 8 and 9 both require the existing lossless gameplay-random payload.

`scripts/city_geometry.gd` owns the narrowly scoped normalization:

- Retire only `city:26,34:2` and `city:26,35:0` as obsolete wall-door entries on load and in saved snapshots. Current wall geometry rejects movement even if a live stale key is true.
- Versions 3–8 allowed arbitrary boolean door keys without validating geometry. The six newly added door faces were previously walls, so any legacy entries for those exact faces are invalid historical opening state. Reset those six changed-face entries during legacy migration, ensuring the new doors start closed.
- Version 9 retains legitimate openings of those six doors, including independent opposite-side state. No mirroring occurs.
- Preserve every other door entry, including unknown keys, false values and same-coordinate Dungeon keys. Preserve player position; no cell is removed and no teleport is introduced.
- Check door value types before normalization, and normalize only a detached load candidate. A later validation failure cannot partially mutate the live journey. Normalization does not rewrite the old file; the next explicit save publishes v9 through the existing recoverable save transaction.

The six legacy-wall-key reset is the resolution of S108's arbitrary-key readiness gate. It does not broaden cleanup to unrelated keys. Old binaries cannot load v9; this branch's manual saves are isolated.

## Validation

- `test_city_geometry.gd`: 330 checks, zero failures. Both directions of all corrected boundaries; closed/open behavior; no reciprocal opening; stale wall keys; current full-state round trips; versions 3–8 at every boundary; migrated resave/reload; invalid revisions and atomic rejection; preservation of unrelated keys; current clock/effect/random state.
- Actual model movement reaches each of the 20 newly accessible cells, saves/reloads there and returns to the tavern. This supplements the earlier graph analysis; it is not substituted for player acceptance.
- Northern City/Dungeon return and southeast non-transition remain covered. Existing route suite verifies both tavern cells and the south exit.
- All 23 headless suites pass, including persistence/write-failure handling, clock, effects, stats, movement, weather, tavern and Dungeon integration. Legacy fixtures now omit the v9 field when representing earlier formats; the unsupported-version fixture uses v10.
- The separate real OpenGL Dungeon distance test passes. Existing scene shutdown resource-cleanup warnings remain; no gameplay assertions fail.
- The isolated checkpoint preparation tool successfully generated a legacy-v8 fixture at the first doorway. Its path guard prevents use against a regular save directory.

No production save/door check was weakened to make tests pass. The new test initially reversed the expected/restored arguments to an existing JSON numeric comparator; that test error was corrected. Neutral stat-display normalization is represented explicitly in the fixture.

## Manual handoff

Use [the S108 playtest](S108_PLAYTEST.md) and `Play-S108.cmd`. The eight checkpoints are intentionally stale-key legacy saves in a dedicated folder. Final closure and merge wait for the player's route/visual acceptance and resolution of any findings.
