# S06 — Speed and incremental travel
Parent: F06 (#13). Refined 2026-11-22. Awaiting user movement feedback and calibration disposition; no new code authorized.

## Existing evidence
Kroah characterStats.html Walking Speed and world.html Time Span establish effective-Speed-derived rate and continuous 15x time. S08 supplies the stat view; S03 the clock. The original working folder contains uncommitted incremental movement and docs/MOVEMENT.md that are NOT included in the sprint branch. Do not claim that implementation is integrated or rewrite it in parallel.

## Required decisions/evidence
- Record the exact original-folder build and movement files tested; separate original-folder results from the isolated F02/F03 build.
- Review six walking units per tile as an explicitly provisional remake calibration. Seek same-edition measurements if available; absence of a measurement must remain a gap. Do not promote this constant into an original ST rule.
- Ask for a calibration/control decision only after presenting measurement evidence or clearly labeled alternatives; user acceptance of the current feel does not establish historical fidelity.
- Use pending playtest feedback for tap/release completion, hold/classic mode, turns/interactions while moving, live map and focus/overview pause. Preserve approved usability choices.

## Acceptance after coding resumes
- Retain fractional movement/camera and cell-centered gameplay actions; no duplicated game-time charge from movement and frame updates.
- Test effective Speed tiers at actual walking-rate thresholds (a +5 bonus from 13 to 18 stays at rate 6); include zero and capped rates, fractional bases and penalties.
- Verify 30/60/144 FPS and a delayed-frame case with the same elapsed input, documenting intentional input scheduling differences rather than requiring unsupported equivalence.
- Verify collision, one-way faces, transition cancellation, map position, pause/resume, active-effect expiry during travel, save/load at allowed boundaries, and no held-input carryover after restore.
- Review and integrate the existing movement work with S02's save changes; run original route, Dungeon, clock, stats and persistence regressions.
- Record physical tile/time calibration and City-to-Dungeon application as adaptations unless independently verified.

Dependencies: user playtest + baseline reconciliation; S03/S08/S30/S31 implemented, S02 automated acceptance complete. Remains refinement/test-dependent, not Ready for implementation.
