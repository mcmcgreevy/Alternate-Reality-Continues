# S05 — Boundary drawing versus movement

2026-11-27. Static candidate-executable and current-renderer review only. No gameplay or map changes. Builds on [difference triage](S05_SHOP_STATE_AND_TRIAGE.md).

## Key finding

The candidate's boundary drawing classification is separate from its movement classification. In module07's lookup at `$105e`, values6 and14 both select drawing variant4; the previously verified module05 movement branch permits6 but blocks14. Values5 and13 similarly share drawing selector0 but lie on opposite sides of the movement threshold. Therefore appearance alone cannot establish traversal or reciprocity.

This supports retaining the earlier Arena directionality questions: a door-like mark is compatible with blocked candidate data. It does not prove the canonical image was generated with this exact renderer or settle every original input path.

## Drawing evidence

The sixteen lookup bytes at module07 `$105e..$106d` are:

`00 00 00 02 06 00 04 00 00 00 00 00 00 00 04 00`

Boundary nibble3 selects2, nibble4 selects6, nibbles6/14 select4, and all other entries select0. Nibble0 bypasses face drawing before table use, so a zero lookup value must not be read as “nothing is drawn” for nonzero faces.

The side and forward drawing paths at `$065a..$067a`, `$06fe..$071e`, `$0788..$07a8` and `$08b4..$08c6` extract/mask the face nibble, skip zero, store its lookup byte at `a5-$415b` and specially call category-graphic selection for nibble3. The latter takes the neighboring category byte and is detailed in the City-helper report.

The drawing helper `$0444..$047c` uses the word at `a5-$415c` to index a relative table at `$0bd8`. Entries at offsets0/2/4/6 point to module offsets `$37c8/$4bd2/$5fdc/$73e6`. The observed nibble lookup controls the low byte; the full high-byte lifetime and every rendering branch have not been traced. Thus this report establishes lookup distinctions, not a complete pixel renderer specification. The pointed-to artwork has not been independently decoded or named here.

Projection helpers `$0936..$0992` use view-position/interpolation arithmetic, including division by36, to determine drawing extents. They do not perform marker-based chapter selection. This does not assign the physical distance units or replace S06 movement calibration.

## Impact on the remaining difference groups

The [154-face rendering ledger](s05/boundary-rendering-review.csv) covers all 135 blocked/blocked differences and all 19 below-threshold/below-threshold differences. Each retains an unresolved canonical-artwork status.

| Difference group | Faces | Consequence |
| --- | ---: | --- |
| Current37 or13 → candidate 14 | 125 | Both inspected movement paths block, but candidate selects drawing variant4. Current City renderer uses generic plaster for37/13. Matching collision is insufficient to call these equivalent. Exact appearance still unverified. |
| Current37 → candidate13 | 10 | Both block; candidate selector0. Current generic plaster does not by itself prove canonical visual equivalence. |
| Current3 → candidate4 | 9 | Both permit eventual movement in the inspected paths, but candidate uses variant6 rather than variant2. Current renderer treats both as wood. Preserve their distinct source values. |
| Current5 → candidate6 | 3 | Both below movement threshold; candidate lookup differs (0 versus4). Current closed City faces use generic plaster for both. |
| Current0 → candidate3 | 6 | Current face draws nothing; candidate face draws with variant2 and category-dependent graphic handling. A visibility/interaction difference even though both movement thresholds allow passage. |
| Current3 → candidate0 | 1 | Current wood face versus candidate skipped face. Do not dismiss because both are below threshold. |

These 19 differences can also affect the remake's explicit E-to-open behavior. Historical movement below7 is not proof that current input handling is faithful. No blanket encoding substitution is proposed.

## Scope and next decisions

All 154 rows now have a candidate drawing-variant classification, but none has been promoted to a complete historical visual pass. Next resolve the underlying artwork/selector context and compare representative and exceptional canonical map faces; then assign explicit per-face dispositions. Priorities remain the 23 non-service threshold differences and confirmed candidate correction scopes, with source-supported visual corrections kept separate from movement fixes.

S05 remains open. Remaining game-update callbacks, full canonical face coverage, exact correction/save policy and acceptance are not completed by this rendering evidence. No need to change either Da Place! state or service behavior for this research.

Inputs: unchanged checksum-verified module07, existing 256-row difference ledger and current `original_view.gd` boundary material selection. Derived CSV checked for 154 unique faces, 135/19 group coverage and 125 candidate 14 entries. No new source downloaded, no source document altered and no executable helper added.
