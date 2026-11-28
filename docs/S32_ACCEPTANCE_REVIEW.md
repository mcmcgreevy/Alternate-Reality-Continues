# S32 acceptance review — 2026-11-20

**Complete for the bounded S30 research handoff.** No production scheduler, stat
mutation, gameplay content or save integration was added.

| Criterion | Result |
| --- | --- |
| AC1: unit and phase | Original clock/caller chain traced. Ordinary period matches one calendar minute; accelerated/pause paths and successful-cast phase reset executed. Candidate polling loss and 29-minute Physical Speed window explicitly reconciled with user. |
| AC2: order | Owner events before timers, descending owner slots, ascending effect slots, reload/incubation/cure/action/counter/removal order documented. Bounded ties and linked invalidation executed. |
| AC3: boundaries | 18 original-code cases cover zero timer, zero interval, finite/zero counter, incubation/text, coincident actions/removal, clock phase and Physical Speed endpoints. |
| AC4: support contract | Integer game microseconds, timer/counter domains, text state, typed byte Add/Sub and explicit unsupported/cure rejection specified. Historical findings separated from approved duration/elapsed-time normalization. |
| AC5: handoff | S03-CLOCK, S08-SPEED, S30 readiness, decision ledger and captured fixtures updated. Verification below passes. |

Evidence: [research and contract](S32_ST_TIMING_RESEARCH.md),
[captured original-code results](../tests/fixtures/s32_st_timing_results.json).
The user approved preserving the documented 30-minute duration and processing
all elapsed time after both candidate discrepancies were presented. Full hardware
emulation, whole service scenes, arbitrary effect operations, historical item
binding and natural-cure RNG remain outside the supported slice, not hidden gates.

Validation:

- Original extraction: 32 records pass source hashes and loader checksums;
  focused timing listing verifies five module hashes.
- S32: 18 original-code scenarios pass; captured JSON equals a fresh rerun.
- S29: all 13 prior original-code scenarios still pass.
- Both provenance/contract validators pass; all 23 Python validation tests pass.
- Planning parser and Git whitespace checks pass.

S32 can be Done. S30 remains Backlog: S03-CLOCK and S08-SPEED still need callable
interfaces/reference implementations and passing integration fixtures. F01 stays
open for S30 and S31. These are research-tool checks, not a new playable feature
or a claim that production timing acceptance tests already pass.
