# S29 original ST executable research — 2026-11-19

User direction: research original ST behavior before choosing remake policies.
This research establishes several missing details and exposes discrepancies that
must be reconciled before the complete S29 lifecycle can be called compliant.
The Kroah baseline remains authoritative; candidate executable observations below
are independently reproducible evidence, not a silent replacement baseline.

## Sources and reproducibility

- Kroah's current Technical Notes are byte-identical to our canonical archive.
- His archived forum thread, **Alternate Reality: The Decompilation**, identifies
  ST v2.0 as his principal target. Neither page supplies the missing routines.
- [AtariMania record 20759](https://www.atarimania.com/games/atari-st-games-alternate-reality-the-city-20759)
  identifies the downloaded Datasoft disk as v2.0. The raw bootstrap also contains
  `V2.0`. This does not prove it is byte-identical to Kroah's particular copy.
- Unchanged pages and the original ZIP are in
  `assets/documentation/s29-st-research/`, with provenance and hashes in the catalog.
  The Hatari STX header documentation supports container parsing only.
- ZIP SHA-256: `1ee57ea2362345c6b6389f4ff5c813ea1c4ca311311d6d503ea7d507368a9000`.
  Contained STX SHA-256: `e8088c06a27e87369aaabc714a22b1964787c0c344134a5c5fde5931302eca56`.
- Reproduce with `python tools/extract_s29_st_evidence.py`. Optional
  `--disassemble` requires Capstone 5.0.9. Outputs go to the ignored
  `tools/reference/s29-verified/` directory. No emulator or original runtime was
  executed; findings are static analysis, not observed playthrough traces.

The extractor pins both source hashes, checks STX boundaries and sector status,
and rejects missing or ambiguous sectors. The three absent sectors are track 79,
sectors 7–9; none is used by the 32 decoded records (3–34). Records 1/2 describe
the resident raw bootstrap and are excluded from encoded-overlay extraction.
Every sector used by those 32 records passes the loader's own checksum.
The earlier exploratory zero-padded `.st` file is **not** the verified input.

Bootstrap addresses below are logical offsets with its beginning labeled `$62`;
they are not load addresses. At `$c3e`, each byte is XORed with the preceding
decoded byte, starting at zero for each sector. At `$b46..$b56`, the trailing
checksum word is saved and replaced with track/sector bytes before checking.
`$c5c` computes CRC-CCITT with the record's seed and a final byte swap. The
directory starts at track 4/sector 5, has 1,530 payload bytes and seed `$0101`.
Each encoded sector contributes 510 payload bytes. Directory records contain
seed, track, sector and byte length. These are not ordinary FAT files.

Module 05 is 37,698 bytes, beginning at track 6/sector 7. Its SHA-256 is
`8dcd198113217567d412f50af3ce7b2dd33a8981d14a8cde5b8545b319e56190`.
All addresses below are offsets in that decoded module. The generated focused
listing recognizes inline dispatch words after `jsr (a5)` as data.

## Findings relevant to S29

| Question | Candidate executable evidence | Qualification |
| --- | --- | --- |
| Opposing pairs | Get removes Drop listeners at `$286c..$2872`, then activates Get at `$2876..$287c`. Drop removes Get at `$2956..$295a`, then activates Drop. Use removes Unuse at `$2976..$297c`; Unuse removes Use at `$2992..$2998`. | These pairs are supported by code, not inferred from names. Drop's branch requires the entity's held flag. Item bookkeeping precedes some calls. |
| Simultaneous events | Dispatcher `$283c..$29e6` tests masks `$01`, `$02`, `$04`, `$08`, `$10` in that order: Get, Drop, Use, Unuse, Delete. | This is branch order, not a guarantee all branches run: Get may consume/delete an entity and exit early. Alignment processing is called before these branches. |
| Event clearing | `$2840` reads pending bits; `$284e` clears the entity's pending byte; `$2852` retains the captured value in a register. | Clear occurs **before** processing. S29's existing wording about clearing after handling needs reconciliation. Reentrant handling and timer ties remain untested. |
| Delete | `$29b2..$29d6` removes Get, Drop, Use and Unuse listener groups, in that order, then `$29de` calls entity deletion. | There is no Delete-listener activation call in this dispatcher. Do not assume Delete is a symmetric ordinary event. |
| Capacity and allocation | `$261c..$2638` scans 96 slots in ascending order for marker `$80`; `$2640..$266e` searches consecutive slots for long text. Active storage is `a5+$1c7e`. | Exhaustion reaches a fatal/error dispatch; reproducing that failure is not authorized. Stable IDs and safe failure remain reconstruction concerns. |
| FF/00 linkage | `$29f6` initializes the current group to FF; `$2a20..$2a26` resets it for a nonzero source link byte. `$2a32..$2a38` adopts the allocated slot when no group exists; `$2a50` writes that group to the copied instance. | A first 00 effect starts its own group. Skipped definitions do not update the group register. A subsequent 00 uses the last successfully allocated group. |
| Duplicate comparison | `$2acc..$2b06` compares the low three type bits and bytes 6–14 inclusive against 96 slots. | This agrees with Kroah's eight quantities (interval and offset occupy two bytes each). It does not compare timer/counter/ID/owner. Caller-pointer handling still needs checking; see discrepancies below. |
| H disabled | `$2a10..$2a1c` bypasses comparison and proceeds to allocation when bit 7 is clear. | Allocation is fresh; no refresh operation appears here. This does not establish how all applied modifiers compose. |
| Group removal | `$25c8..$260a` scans slots with live marker at least `$81`, matches their byte-1 group, and marks them `$80`. Long text also frees its second slot. | No arithmetic inverse or callback occurs in this routine. Do not invent universal stat rollback. Entity-level group lookup still needs reconciliation. |

## Discrepancies and limits that matter for implementation

1. Kroah describes events being cleared after handling; the candidate clears the
   pending byte before running captured events. Record this distinction rather
   than changing the baseline prose or silently choosing a reentrancy policy.
2. Delete has no listener-activation branch here, despite being named among the
   available event bits in the notes. Entity deletion itself walks definitions
   and removes groups (`$2708..$278c`). Full delete behavior must include that path.
3. Opposing removal reads each entity definition's byte 15 as a group identifier
   (`$2aac..$2ab8`). Activation writes owner information into byte 15 of a copied
   non-text instance (`$2a64..$2a68`). The relationship and template updates are
   not yet traced. Do not claim owner-scoped cleanup is implemented or proven.
4. The H comparison routine reads its candidate through `a0`, while iteration
   tracks the definition in `a6`. The call at `$2a16` does not explicitly copy
   `a6` to `a0`. Follow all preceding paths before assuming the correct definition
   reaches the comparison, particularly after skips or preceding activations.
5. The definition-advance test at `$2a6c` reads byte **2**, whereas copy length at
   `$2a42` reads byte **0**. This may be a historical defect or require surrounding
   data constraints. It is not permission to reproduce unsafe text handling.
6. Removal is slot invalidation, not general undo. To resolve modifier cleanup,
   trace actual stat-modifying definitions and their opposing-event companions.
   A safe reconstruction must distinguish permanent writes from contributions;
   generic subtract-on-remove would not be justified by this routine.

## Adjacent S30 evidence, not implemented here

At `$2466..$2472`, a zero timer is skipped; otherwise it decrements and only an
expiry continues. `$2476` reloads the interval, `$247c` handles incubation, and
`$2480..$24a4` checks natural cure before executing an action. `$2518..$2528`
decrements a nonzero counter **after** execution and removes the effect when it
becomes zero. This supplies ordering missing from the prose but does not resolve
scheduler tick units, service acceleration or event/timer ties. The cure path
uses a preliminary low-nibble RNG gate; do not model its byte as a plain percent.

## Consequence for delivery

S29 remains In Progress. Its existing immutable definition registry and pure
duplicate gate are unchanged. This pass adds reproducible executable evidence;
it does not add event dispatch, alter gameplay or change saves. The next research
step is to follow byte-15/group writes and real item/spell definitions, then turn
the verified bounded behavior into lifecycle fixtures. Update the S28 decision
ledger and S29 acceptance wording explicitly when those discrepancies are
resolved; the old ledger is a record of the original archive-only review, not a
claim that the new evidence was already incorporated.
