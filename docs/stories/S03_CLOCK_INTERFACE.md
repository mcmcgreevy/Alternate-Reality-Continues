# S03 — Clock interface deliverable

## S30 prerequisite: S03-CLOCK
Status: outstanding; completing this deliverable does not close all of S03.

- [ ] Specify one named elapsed-game-time interface, with units, precision, valid input domain and fractional-time handling based on S32 (#66)'s verified timing findings.
- [ ] Define ordinary, paused and accelerated-service advancement through the same input path, without double conversion, double charging or duplicate metabolism updates.
- [ ] Provide a documented callable interface/reference adapter and fixtures for zero elapsed time, exact boundaries, equivalent time partitions, pause and accelerated time. Preserve existing continuous-clock work.
- [ ] Link the settled contract and passing checks from S30 (#64)'s readiness review.

S32 can research timing before this interface is complete. Do not infer raw timer units from spell duration. Calendar completion and the rest of S03 are not prerequisites for starting S30. Production effect scheduling belongs to S30.

Evidence: archived Kroah `world.html` Time Span, `docs/SOURCE_BASELINE.md`, and the timing findings delivered by S32.
