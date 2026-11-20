# S03 — Clock interface deliverable

## S30 prerequisite: S03-CLOCK
Status: outstanding; completing this deliverable does not close all of S03.

S32 research is complete: see [timing contract](../S32_ST_TIMING_RESEARCH.md).
Supply nonnegative integer game microseconds (60,000,000 per game minute), retain
fractional real-to-game conversion remainder in the clock adapter, and reject
overflow/invalid elapsed input before mutation. Ordinary conversion is 15 game
seconds per real second; accelerated service conversion is 3600; pause supplies
zero. Both use the same elapsed input, with no dropped time or duplicate updates.
Provide timestamped event boundaries so S30 can process earlier deadlines before
later events and owner events before timers at an equal timestamp. Precision is
remake architecture; the original 240-call phase is not the production API.

- [ ] Specify one named elapsed-game-time interface, with units, precision, valid input domain and fractional-time handling based on S32 (#66)'s verified timing findings.
- [ ] Define ordinary, paused and accelerated-service advancement through the same input path, without double conversion, double charging or duplicate metabolism updates.
- [ ] Provide a documented callable interface/reference adapter and fixtures for zero elapsed time, exact boundaries, equivalent time partitions, pause and accelerated time. Preserve existing continuous-clock work.
- [ ] Link the settled contract and passing checks from S30 (#64)'s readiness review.

S32 can research timing before this interface is complete. Do not infer raw timer units from spell duration. Calendar completion and the rest of S03 are not prerequisites for starting S30. Production effect scheduling belongs to S30.

Evidence: archived Kroah `world.html` Time Span, `docs/SOURCE_BASELINE.md`, and the timing findings delivered by S32.
