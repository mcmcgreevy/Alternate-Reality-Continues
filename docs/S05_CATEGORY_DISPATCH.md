# S05 — Verified candidate category dispatch bindings

2026-11-22. Static chain verification against the archived candidate ST v2.0 image; not a full-game runtime test. Canonical source remains Kroah. No game implementation changed.

## Finding

The resident dispatch construction, overlay binding and category call sites agree: location types 0–9 select modules 7–16 respectively. This resolves the specific category-to-overlay uncertainty left in the service and special-passage reports. It does not resolve all behavior inside those handlers or all possible alternative call paths.

| Type | Category | Module | Init / update / leave dispatch offsets |
| --- | --- | --- | --- |
| 0 | City | 07 | 01b2 / 01b8 / 01be |
| 1 | Inn | 08 | 01ca / 01d0 / 01d6 |
| 2 | Tavern | 09 | 01e2 / 01e8 / 01ee |
| 3 | Bank | 10 | 01fa / 0200 / 0206 |
| 4 | Shop | 11 | 0212 / 0218 / 021e |
| 5 | Smithy | 12 | 022a / 0230 / 0236 |
| 6 | Special | 13 | 0242 / 0248 / 024e |
| 7 | Healer | 14 | 025a / 0260 / 0266 |
| 8 | Guild | 15 | 0272 / 0278 / 027e |
| 9 | Combat | 16 | 028a / 0290 / 0296 |

All table values are hexadecimal dispatch offsets relative to a5, not module instruction addresses. The [machine-readable table](s05/category-dispatch.csv) separately records each target module's header offsets. The [focused evidence listing](s05/category-dispatch-evidence.txt) preserves original instruction bytes and decoded operations.

## Evidence chain

1. Read the archived STX with the existing hash-pinned sector parser. Concatenate present logical sectors43–50 for the raw resident bootstrap, following the existing S29 extraction convention. Bootstrap labels use origin `$62`; they are logical labels, not runtime addresses. The listing records a hash of those exact bytes.
2. Bootstrap `$0142..$01ac` starts six-byte dispatch entries at a5+2, constructs the first resident groups, then uses entry counts at logical `$01ce`. Each entry stores a function pointer plus module number shifted left four bits. Modules7–16 each have four entries. Summing earlier group sizes produces module7 base `$01b2` and 24-byte spacing thereafter.
3. Bootstrap dispatcher `$047c..$04f8` reads the inline dispatch offset and resolves its pointer/module metadata. A not-yet-loaded overlay points at loader `$0526`. The loader path `$0612..$0638` obtains the selected record through dispatch `$0026`; `$066c..$0684` uses the loaded module's header count and signed relative entry offsets to populate six-byte slots. `$0688..$069e` resumes through the requested bound pointer.
4. Module05 `$02bc..$02d4` initializes with base `$01b2` and updates with base `$01b8`. `$1138..$114c` computes `24 * location_type + base` and invokes the resident dispatch bridge. `$10fc..$1134` updates type from the map cell, calls the old type's leave slot at base `$01be` when it changes, then enters the initialization path. Thus the derived table is used by actual category call sites, not merely a plausible layout.
5. Module13's header maps its init/update/leave entries to `$000a/$0048/$0070`. Initialization stores state offset `$20` in its continuation stack. Update retrieves that word and jumps relative to `$006c`, reaching `$008c`, the marker switch previously inspected. This ties the scenario switch to the category6 update path in the initial state.

The bootstrap entry counts and all ten decoded module headers were checked independently; every derived category base equals `$01b2 + 24*type`. The listing skips inline dispatch words and excludes pointer-table data from instruction decoding. No emulator probe or new executable helper was added.

## Consequences for unresolved locations

- Type0 cells dispatch City module07 through this path. Marker44/45 gate cells and marker51 Arena approach cells therefore do not enter module13 merely because that module contains matching marker cases.
- The unnumbered Palace gate cell (53,22), marker48/type0, likewise uses City dispatch. The marker48 branch in module13 is insufficient evidence for chapter travel from that cell.
- Candidate marker46/type6 at (24,8) and marker47/type6 at (59,17) do select module13. The request/refusal/previous-position restoration paths documented in [special-passage research](S05_SPECIAL_PASSAGES.md) are now tied to their category handler, conditional on reaching the cells and progressing through that handler.
- The service-index and shared-shop-state findings are now tied to the correct category modules. Both Da Place! type4 occurrences select module11, which uses their shared marker-derived index. This does not independently verify disk serialization or every transaction behavior.

No blanket claim is made that type0 cells have no special behavior anywhere: City module07 and other event paths still need review for marker-specific handling. No new chapter support or gate activation follows from this evidence.

## Remaining work

Investigate City-module handling of special markers, original directional boundary behavior and the remaining visual/material distinctions. Complete canonical face classifications and reconcile material discrepancies before defining the final correction/save migration scope. User playtest and implementation acceptance remain pending. The specific category-to-overlay binding gap is resolved for this candidate; successful scenario media loading and original-game route execution are not.

## City-handler follow-up — 2026-11-23

Inspected module07 initialization `$000a..$0168` and update entry `$016a..$0236`. Marker-sensitive branches at `$00a4`, `$0158` and `$01f8` compare against `$5f` (95); the higher-marker path indexes a presentation table at `$15b8`. Markers44,45,48,51 all take the lower-marker paths in these comparisons. No explicit branch for those four marker values appears in these inspected ranges.

This narrows the investigation but does not prove absence of special behavior: calls to `$05e0`, `$0a36`, `$0bc8`, resident dispatches and later continuations still require examination. The update uses a continuation stack, so linear decoding cannot substitute for control-flow coverage. At `$0236` execution branches to `$027a`; bytes immediately following are not treated as a verified continuation. No dormant gate was promoted to an active feature.
