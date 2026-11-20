# S08 — Stat action interface deliverable

## S30 prerequisite: S08-SPEED
Status: complete. [S08 implementation and acceptance](../S08_STATS.md) records
99 stat checks, eight scene checks and the full core-stat scope.

S32 research is complete: see [timing contract](../S32_ST_TIMING_RESEARCH.md).
The bounded target is named `speed_bonus`, unsigned byte 0..255; Add/Sub take
byte parameters 0..255 and saturate at 255/0. One block and zero gap only.
Apply actions synchronously in the supplied order, without reentrant callbacks.
Reject other targets, operations, widths or layouts atomically. S30 owns timer
ordering; this API must not reorder operations or synthesize rollback on removal.
Physical Speed's normalized activation grants five once; the explicit subtraction
occurs 1800 game seconds later. S31 owns content and save integration, including
no replayed activation after loading. The callable API is `OriginalWorld.apply_stat_actions(actions)`; see S08_STATS.md.

- [x] Define a bounded typed Speed-bonus state/action interface for one-byte saturating Add/Sub. Specify accepted targets, widths and values; unsupported operations must fail without partial mutation.
- [x] Preserve explicit Add/Sub execution order. Removing a linked group must not invent an inverse operation: saturation makes generic rollback incorrect. Specify owner isolation and cleanup separately from stat arithmetic.
- [x] Supply a callable interface/reference implementation and fixtures: 253 + 5 = 255; 2 - 5 = 0; Physical Speed's explicit Add-5/Sub-5 sequence starting at zero ends at zero; invalid inputs leave all state unchanged and other stat fields remain untouched.
- [x] Align operation ordering with S32 (#66), then link the settled contract and passing checks from S30 (#64).

These are action fixtures, not proof of timer units. Full stat UI, all modifiers and every S08 target are not prerequisites for S30. Production scheduling belongs to S30; gameplay/save integration belongs to S31 (#65).

Evidence: `docs/S29_ST_EFFECT_RESEARCH.md`, original-code probes in `tools/probe_s29_st_effects.py`, and archived Kroah ST v2.0 technical notes.
