# S05 — City helper control-flow review

2026-11-23. Research only; no gameplay changes. Follow-up to [verified category dispatch](S05_CATEGORY_DISPATCH.md). Addresses are module07 offsets unless explicitly stated otherwise.

## Findings

The helper ranges inspected do not contain a dedicated activation branch for marker44,45,48 or51. Several previously unknown calls can now be bounded as presentation or input-related work. This is a range-limited static finding, not proof that these markers have no effect anywhere in the game.

| Routine / range | Evidence | Interpretation and limit |
| --- | --- | --- |
| `$027a..$02d2` | Pushes continuation `$011a`, invokes dispatch `$808c`, resumes at `$0292`, then calls `$0b34`, input dispatch `$007a` and `$0abc`; pending movement invokes `$8092`. | Main continuation/input path. The continuation is relative to `$0178`, so `$0178+$011a=$0292`; do not decode intervening data as an execution path. Resident targets still need tracing. |
| `$02d8..$02e0` | Advances continuation stack and clears `$1935`. | Exit bookkeeping, not marker-specific gate logic. |
| `$05e0..$069c` | Calls `$02e2`, clears a buffer, uses heading tables and extracts face nibbles from the view buffer. For nibble3, reads a neighboring cell's category byte and calls `$0994`. | Beginning of drawing construction. Later branches through `$0934` and helper `$0936` remain outside this inspected range. |
| `$02e2..$033c` | Compares current marker with95, selects heading-dependent source data below95, copies blocks into working buffers. | Background preparation; markers44/45/48/51 take the lower-marker path. Tail of this routine remains untraced. |
| `$0994..$0a34` | Masks incoming byte to low five bits, bounds category to0–8, selects two tables and copies patterned byte blocks. | Category-dependent graphic selection, not a marker-indexed scenario dispatch. Visual asset identities are not independently decoded. |
| `$0a36..$0aba` | Compares heading fields and writes/clears patterned bytes at `$7a940`. | Display-area update. No marker read in this complete inspected routine. |
| `$0abc..$0b0e` | Uses time/flag checks, RNG dispatch `$00b6`, and writes movement-input values. | Input-affecting logic; remainder through `$0b2e` still needs inspection. Do not name its gameplay condition without further evidence. |
| `$0b34..$0bc6` | Tests coordinates and minute0; chooses feedback value5 in the Palace-side region or4 inside four rectangle tests, with shared handshake flags. | Coordinate-triggered feedback, not a chapter-request branch. Canonical world documentation describes Palace fanfare and smithy sounds; correspondence is plausible but the feedback consumer has not been traced. |
| `$0bc8..$0bd6` | Clears `$5a0` longwords starting at `a5-$3d60`. | Buffer clear, with no marker or category test. |

## Coordinate feedback evidence

The first path tests unsigned X>=50, 14<=Y<30 and minute=0. Additional flag checks control whether feedback is requested. The second path reads four rectangles at `$1248`, each as lower-inclusive/upper-exclusive X and Y bounds. This is not a gate-name or marker comparison. Do not turn it into a location interaction simply because it occurs near the Palace.

The original archive's world page separately documents hourly Palace fanfare and smithy-area sounds. This analysis deliberately leaves the exact audio identity and all scheduling flags unresolved; no new audio behavior is proposed under S05.

## Next research checkpoints

- Trace the remaining portions of `$02e2`, `$05e0` and `$0abc` and their called helpers before claiming complete City-module coverage.
- Resolve resident dispatch targets `$808c/$8092/$007a` and any relevant callbacks. Category binding is already verified; these are additional control-flow paths.
- Preserve the distinction between marker-based appearance, coordinate-triggered feedback and actual scenario dispatch.
- Continue directional semantics and canonical visual classification; the gate research issues remain open, with no activation authorized.

The scope is intentionally explicit: no assertion of complete call-graph coverage, no original-game execution, and no conclusion that lack of a branch in one range proves lack of a feature. Evidence comes from the unchanged checksum-verified module07 and archived Kroah world documentation. No new source download or executable helper added.

## Resume and dispatch targets — 2026-11-27

The previously interrupted documentation commit was pending locally; no gameplay edits were present. Resolved the three resident dispatch targets by combining the verified six-byte dispatch table bases with each decoded module header:

| Call | Actual target | Finding |
| --- | --- | --- |
| `$007a` | module04 `$0050` | Reads input flags, suppresses repeated values in some cases and writes normalized input to `a5+$2c2`. Branch targets `$007e/$0084` also inspected through return `$008c`. No marker dispatch in this routine. |
| `$8092` (offset `$0092`, high-bit dispatch mode) | module05 `$0fc2` | This is the previously inspected position snapshot / turn / movement routine. It leads to face-nibble checks and category update, rather than an additional independent gate handler. |
| `$808c` (offset `$008c`, high-bit dispatch mode) | module05 `$031e` | Broader update path. Inspected entry through `$03c2`; includes state/flag gates and calls to timed/event routines. Entire routine and descendants are not yet covered. |

Module07 `$0b0e..$0b2e` completes the previously truncated input-affecting routine: it makes an additional RNG call and conditionally writes6 to `a5+$18be`. The inline dispatch word at `$0b20` is data and was skipped when decoding. No marker comparison occurs in that tail; the meaning of the gameplay condition remains unassigned.

A material remaining path is module05 `$0376..$038a`, which conditionally calls `$02d8` when category/flag conditions permit. Earlier inspection of `$02d8..$031c` found a coordinate/scenario registry comparison: X, Y, Z and loaded-scenario values are checked against arrays relative to `a5+$2300`. Therefore marker-only branch searches cannot settle absence of gate behavior. Next investigate who populates that registry, the match/miss behavior and whether gate coordinates occur in its runtime data. Do not label this a gate registry without that evidence.

This narrows three opaque calls to concrete targets and identifies a specific remaining event path. It does not claim all callbacks are covered or that dormant-looking gates can be closed as research issues. Original-game execution, canonical boundary verification and implementation acceptance remain pending.
