# S05 — Candidate boundary artwork decoded

2026-11-27. Research artifact, not new game art or an implementation change. Follow-up to [boundary-rendering evidence](S05_BOUNDARY_RENDERING.md).

## Observed artwork

The [derived grayscale contact sheet](s05/candidate-boundary-artwork.png) displays four decoded candidate drawing banks from left to right. Visual inspection identifies:

| Selector | Module07 bank offset | Observed content | Candidate boundary values selecting it |
| --- | --- | --- | --- |
| 0 | `$37c8` | Stone wall | Nonzero values other than 3/4/6/14; value 0 skips drawing before selection. |
| 2 | `$4bd2` | Hinged door in stone wall | 3 |
| 4 | `$5fdc` | Open-looking colonnade/pillars | 6 and 14 |
| 6 | `$73e6` | Hinged door between columns | 4 |

The sheet shows raw stored imagery, including smaller representations packed below the large images. It uses grayscale for palette indices 0–7 to make structure visible; these are **not reconstructed historical colors**. It does not simulate perspective, category overlays, time-of-day lighting or the full original renderer.

Candidate14 is therefore an open-looking colonnade graphic with a blocked movement value in the inspected path. Candidate6 uses that same artwork but falls below the blocking threshold. This refines the earlier generic “drawing variant 4” description; neither an open-looking graphic nor a door-like canonical-map symbol proves traversal.

## Extraction evidence and limits

Module07 drawing helper `$0584..$059a` samples three source bitplanes at offsets0, `$06ae`, `$0d5c`. The four selected banks are each spaced `$140a` (5130) bytes apart: three planes of 1710 bytes. Decoded each bank as a 144-bit-wide plane (18 bytes per row), 95 rows, MSB first, combining the three bits into indices 0–7. The bank layout includes multiple scales; the 95-row contact sheet is a convenient raw-storage view, not a claim that every row belongs to a single full-size texture.

Evidence supporting this interpretation includes the bitplane sampling instructions, consistent bank spacing, coherent images at all four offsets and category-artwork copy loops stepping 18 bytes per row. The decoding is derived from unchanged checksum-verified candidate module07. The PNG doubles pixel dimensions using nearest-neighbor scaling. No palette, transparency or asset was invented for the game.

The prior high-byte selector-context limitation remains: the lookup writes the low byte of a word used by the renderer. This artifact establishes what the four observed banks contain, not that all runtime circumstances select only these banks.

## Consequences for S05

- The 125 same-threshold discrepancies using candidate14 now have a specific artwork distinction to investigate: colonnades versus the current generic City plaster face. Do not globally replace37 or13, because both codes also map to other candidate values.
- The 9 current3/candidate4 differences distinguish stone-surrounded doors from column-surrounded doors in the candidate art; current code treats both as wood. Their movement/interaction rules still need their own verification.
- The 3 current5/candidate6 differences distinguish wall-like concealed passage artwork from colonnades, with no change in the candidate blocking threshold.
- The 10 current37/candidate13 differences use stone-wall bank0 in the candidate. Visual style adaptation must be distinguished from topology or source-identity corrections.

This does not require reproducing original pixels in the remake. The actionable requirement is to preserve source-supported structural distinctions while respecting approved art direction. Canonical per-face verification, full passage semantics and final correction/save-policy decisions remain outstanding.

No gameplay code, map payload, source document or executable helper changed. No new external source downloaded. The contact sheet is locally derived analysis and remains separate from the unchanged source library.
