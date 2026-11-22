# S05 — Candidate ST map data and directional comparison

2026-11-22. Research only. No gameplay code or map payload changed. The Kroah archive remains canonical; this is evidence from the independently archived ST v2.0 candidate, not proof of byte identity with Kroah's disk.

## Finding and coverage

Located a 16384-byte map block at module-05 offsets `$34a4..$74a3`: 4096 cells, four bytes each, row-major with a 256-byte row stride. Every one of the **463 numbered cells** previously read from Kroah's map agrees with byte 2 at the same coordinate. This strongly corroborates map identity and orientation, including duplicate markers; it does not certify every wall or runtime routine.

The [cell ledger](s05/candidate-st-cells.csv) records all 4096 offsets, unchanged four-byte values, marker byte, low-five-bit type and high-three-bit flags. The [directed comparison](s05/candidate-st-face-comparison.csv) covers all 16384 faces: **16128 raw equal, 256 raw different**. Raw equality is not a historical gameplay pass. The original image-comparison ledger is deliberately unchanged; its unverified fields have not been converted to canonical fidelity passes.

## Reproduction and executable evidence

Re-ran the existing `python tools/extract_s29_st_evidence.py`: all 32 overlay records pass the original loader checksums, with no missing sectors substituted. Sources and extraction rules are documented in [S29 research](S29_ST_EFFECT_RESEARCH.md); no new download or executable helper was added.

- Original ZIP SHA-256: `1ee57ea2362345c6b6389f4ff5c813ea1c4ca311311d6d503ea7d507368a9000`.
- Decoded module 05 SHA-256: `8dcd198113217567d412f50af3ce7b2dd33a8981d14a8cde5b8545b319e56190`.
- Map block SHA-256: `bfc7e7e49cd38f0b8e3d33496b0f8bf6edd48aecda0e6e6a25c1a354e1ea5d0d`.
- Current JSON SHA-256: `2ff715f0272dc469ba1d86f670d049b5d2ac3e2907e2143c4b0db5ebda715914`.

Addresses below are module offsets, not absolute load addresses. Read-only Capstone inspection used the existing local S29 dependency installation.

| Locator | Observation | Scope |
| --- | --- | --- |
| `$1150..$11a2` | Builds a 10-row by 11-cell view buffer using four-byte copies. Map base `$34a4`; Y shifted eight bits, X shifted two bits. Direction tables at `$19c6/$19ce/$19d6` select stride and starting offset. | Independently identifies map base and stride rather than finding a coincidental marker sequence. |
| `$1058..$106a`, table `$1a0e` | Reads a word from the view's current cell, shifts by a heading/movement-dependent value and masks `$f`. Shift table begins 8,12,0,4. | Consistent with N/E/S/W nibbles: byte0 low/high, byte1 low/high. All 24 nibble permutations were compared; only this one exceeds 15000 equal current faces. |
| `$1066..$1076` | Values >=7 take a branch resetting the partial coordinate rather than advancing the integer coordinate. | Evidence of the candidate's blocking threshold in this movement path, not full door/secret behavior or input handling. |
| `$107a..$10a4` | Zero skips feedback setup; values 1–4 and 5–6 select different feedback values before advancing the integer coordinate. | The current remake's explicit E-to-open interaction must not be assumed to be the original procedure. Full presentation/input path is not traced here. |
| `$10fc..$110c` | Saves previous location type, reads current cell's final byte from the view buffer, skips update if negative, otherwise masks `$1f` and writes `a5+$1846`. | Kroah's Technical Notes names `$1846` as the location type. High flag bits must remain distinct; low bits alone are not unconditional dispatch. |
| `$1110..$114c` | Compares current and previous types and selects type-dependent dispatch entries with a 24-byte stride. | Establishes category dispatch distinct from marker identity. Individual service-index lookup still needs tracing. |

For each coordinate `(x,y)`, read bytes at `$34a4 + y*256 + x*4`. Compare `[byte0 & 15, byte0 >> 4, byte1 & 15, byte1 >> 4]` with current N/E/S/W edges independently. Check byte2 against the 463-row labeled-cell inventory. CSV counts, complete coordinate/face coverage and matching module/map hashes were checked. This was static analysis, not execution of original movement or a playtest.

## Differences requiring reconciliation

| Current raw edge | Candidate nibble | Faces |
| --- | --- | ---: |
| 27 / 28 / 29 / 30 / 31 / 32 / 33 | 3 | 32 / 8 / 22 / 6 / 5 / 4 / 2 |
| 37 | 14 / 13 / 6 | 97 / 10 / 1 |
| 38 | 4 | 6 |
| 0 | 3 | 6 |
| 3 | 0 / 4 / 14 | 1 / 9 / 3 |
| 5 | 6 / 13 | 3 / 7 |
| 13 | 3 / 14 | 6 / 28 |

The 79 faces with current service codes 27–33 all contain candidate nibble 3. This supports an encoding-layer explanation, not deleting service semantics or blindly replacing codes. Current code 37 has three distinct candidate values; no global substitution is safe. Current 38 consistently maps to candidate 4 in six faces, but meaning still needs reconciliation.

Sixteen differences among ordinary current codes cross the candidate <7 movement threshold: seven current 5 vs candidate 13, three current 3 vs candidate 14, and six current 13 vs candidate 3. These are priority passage discrepancies, not yet approved corrections. Example: (14,0) north is current 5 / candidate 13; (6,7) east is current 3 / candidate 14; (10,30) south is current 13 / candidate 3. All exact coordinates are in the face ledger. The first example is also an outer-map boundary, so a threshold difference does not by itself imply a usable route outside the map.

No save migration is needed for this research. Before any future correction, classify the affected direction-specific saved door keys and saved positions, identify intended source/adaptation behavior and provide regression routes. Do not symmetrize either representation.

## Identity findings for the research backlog

| Current identity | Candidate marker / type | Implication |
| --- | --- | --- |
| raw69 Armstrong, raw70 Apollo, raw73 David's | 53 / 6; 54 / 6; 57 / 6 | Agrees with Kroah's reused scenario categories, not the healer/guild category implied by the same marker elsewhere. |
| raw79 Paladins, raw86 Mercenary | 58 / 8; 65 / 8 | Agrees with Kroah's duplicate guild identities. Category does not establish accessibility. |
| raw60 Acrinimiril's Gate, (31,27) | 44 / 0 | Candidate retains an identity byte, but City type rather than a dedicated scenario type. Historical name and active behavior remain unproven. |
| raw61 Floating Gate, (35,36) | 45 / 0 | Same distinction: marker data exists without a dedicated scenario category. Do not activate a gate from the ARX name alone. |

The two unlabeled gate cells are therefore not data-empty in this candidate, although Kroah's map does not print their numbers. S106/S107 should investigate the meaning/use of bytes 44/45, not assume the labels are simply missing services.

## Remaining S05 work

Trace service identity lookup and full boundary/input handling; visually cross-check the priority discrepancies against the canonical map; reconcile candidate evidence with Kroah wherever they disagree. Only then define bounded corrections and save policy. Full-game access, all original directional semantics and canonical image agreement remain unverified. S05 remains open and implementation remains paused pending the user's playtest.
