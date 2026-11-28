# Sprint closeout: November 28, 2026

## Acceptance decision

The F02/F03 sprint goal is met. The user confirmed restart-safe save/load and responsive movement, accepted the corrected Dungeon distance rendering, and explicitly authorized committing and merging all completed work on November 28. Individual manual checklist rows were not separately reported; no such results are implied.

## Integrated build validation

Integrated `feature/atmosphere-art-pass` (including preserved local work at `d6f342d`) into `codex/f02-f03-sprint` after rendering correction `2722a01`. Resolved the save/load overlap by retaining v8 candidate validation, recoverable writes and saved gameplay randomness, while preserving centered-save restrictions and resetting transient movement only on successful load. Retained both branches' documentation and source provenance.

Godot 4.5.1 validation on the integrated tree: all 22 headless test suites pass, plus the actual OpenGL Dungeon distance regression. Counted suites total 854 checks, with additional pass/fail suites. The final checks include persistence, migration, effects, clock/calendar, movement, City/Dungeon round trip, weather, audio, and rendered darkness at dawn, noon and night. Tests use isolated application data, never the player's saves.

Two outdated test expectations were corrected: the movement migration fixture now omits the v8 random payload when representing a legacy save, and the stats scene expects the explicitly approved always-visible SPD. No production behavior was weakened to satisfy these tests. Existing resource-cleanup warnings remain in some scene suites; all gameplay assertions pass.

## Scope and remaining work

F02, F03 and S02 are accepted for completion. S03 remains complete. S05 research, source comparisons and the location backlog are integrated, but S05 remains open: proposed map corrections and location functionality are not delivered by this sprint. Known save limitations remain single-writer local use, no physical disk/power-loss guarantee, and replay tied to the supported engine generator.

The root `Play.cmd` launches the integrated main build using the original save location. Existing sprint saves remain in the sprint worktree's `tools/appdata-sprint-playtest`; continue using that worktree's `Play-Sprint.cmd` to resume those saves. No save files are committed, overwritten or moved during integration.

Stakeholder source document: [Sprint review](SPRINT_REVIEW_2026-11-28.md).
