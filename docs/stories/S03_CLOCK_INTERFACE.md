# S03 — Clock interface deliverable

## S30 prerequisite: S03-CLOCK
Status: complete. [S03 implementation and acceptance review](../S03_CLOCK.md)
also covers the full calendar/time story; 65 focused checks pass.

S32 research is complete: see [timing contract](../S32_ST_TIMING_RESEARCH.md).
Supply nonnegative integer game microseconds (60,000,000 per game minute), retain
fractional real-to-game conversion remainder in the clock adapter, and reject
overflow/invalid elapsed input before mutation. Ordinary conversion is 15 game
seconds per real second; accelerated service conversion is 3600; pause supplies
zero. Both use the same elapsed input, with no dropped time or duplicate updates.
Provide timestamped event boundaries so S30 can process earlier deadlines before
later events and owner events before timers at an equal timestamp. Precision is
remake architecture; the original 240-call phase is not the production API.

- [x] Specify one named elapsed-game-time interface, with units, precision, valid input domain and fractional-time handling based on S32 (#66)'s verified timing findings.
- [x] Define ordinary, paused and accelerated-service advancement through the same input path, without double conversion, double charging or duplicate metabolism updates.
- [x] Provide a documented callable interface/reference adapter and fixtures for zero elapsed time, exact boundaries, equivalent time partitions, pause and accelerated time. Preserve existing continuous-clock work.
- [x] Link the settled contract and passing checks from S30 (#64)'s readiness review.

S32 research and this interface are complete. Production effect scheduling belongs
to S30; typed stat actions still belong to S08-SPEED.

Evidence: archived Kroah `world.html` Time Span, `docs/SOURCE_BASELINE.md`, and the timing findings delivered by S32.
