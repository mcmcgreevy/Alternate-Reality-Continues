# S32 — Original timing, ordering and bounded handoff

Research and user reconciliation: 2026-11-20. No production gameplay changes.
Kroah ST City v2.0 remains canonical. This report supersedes the timing unknowns
in the chronological S28/S29 notes only for the explicitly bounded cases below.

## Provenance and reproduction

No new historical source was downloaded. The unchanged candidate ZIP/STX and
Kroah pages are already cataloged under `assets/documentation/`. ZIP SHA-256:
`1ee57ea2362345c6b6389f4ff5c813ea1c4ca311311d6d503ea7d507368a9000`.
STX SHA-256: `e8088c06a27e87369aaabc714a22b1964787c0c344134a5c5fde5931302eca56`.
Module 05: `8dcd198113217567d412f50af3ce7b2dd33a8981d14a8cde5b8545b319e56190`.
Module 15: `6c2c2738fe15eb862f92adf6df7c65da95d877a81a4a78d71c883aabdb8b8cbb`.
Other service-module hashes are included in the generated listing and verified
against the checksum-verified extraction manifest. Addresses below are module
05 offsets unless a different module is named; they are not load addresses.

```powershell
python tools/extract_s29_st_evidence.py
$env:PYTHONPATH = 'tools/reference/s29-python'
python tools/extract_s32_st_timing.py
python tools/probe_s32_st_timing.py
```

Use the existing pinned Capstone 5.0.9 and Unicorn 2.1.4 dependencies. The listing
is `tools/reference/s29-verified/s32-timing-routines.asm`; the 18 captured probe
results are committed as `tests/fixtures/s32_st_timing_results.json`. The harness
executes unchanged instructions with synthetic RAM and bounded observation
points. It stops before unrelated metabolism/OS routines; it does not stub them
into success or claim a full service, spell-UI or hardware playthrough.

## Clock, caller and phase

| Evidence | Finding | Method / limit |
| --- | --- | --- |
| `$008a..008e`, `$1628..1640` | Installed clock handler increments the long counter at global `$02bc`; the calendar handler is `$163c`. | Static chain; probe calls the handler body, not the hardware interrupt entry. |
| `$1640..1678` | Pause flag `-$41ed` skips calendar work. Ordinary calendar countdown `$0f2a` reloads 240, then increments minute `$1826`; 60 minutes increment hour `$1827`. | Executed ordinary/accelerated/pause cases. |
| `$038e..03b2` | When unpaused and `$02bc` differs from last observed counter, process owner events, effects, then metabolism routines. | Events/effects executed; downstream metabolism order is static only. |
| `$2438..2446` | Ordinary effect countdown word `$0f0e` reloads 240. Accelerated flag `$1801` bypasses it. | Both paths executed. |
| `$021c..0234` | Initial effect countdown is 6, calendar countdown 70; phases are independent. | Static initialization; do not assume effects always align with calendar minute boundaries. |
| `$0b86..0b92` | Successful cast queues Use and resets the shared effect countdown to 1. | Executed fragment; not the entire spell success/RNG path. |
| Modules 08 `$03ea..0448`, `$054e..0598`; 09 `$04a6..04f0`; 10 `$0794..07de`; 15 `$0190..01ba` | Service loops enable acceleration, yield through the engine, wait on calendar progress and clear acceleration afterward. | Static callers; full service gameplay not emulated. |

An ordinary timer decrement occurs once per 240 observed clock changes, matching
240 interrupts per calendar minute when every change is serviced. One raw timer
unit therefore has a **one-game-minute steady-state period**. Kroah's Time Span
maps a game minute to four real seconds; this supports a nominal 60 clock changes
per real second. That rate is a derivation from the canonical table, not a
hardware oscillator measurement. Accelerated calendar and effects each advance
once per observed interrupt: 240 times ordinary speed, agreeing with Kroah's
one game hour per real second. Pause prevents both update paths.

This is not proof that raw timer N always means N minutes after activation.
The shared phase and cast reset matter. After a successful-cast reset, Physical
Speed adds five at observed interrupt 1 and subtracts five at 6961:
`1 + 29 * 240`. The bonus is present for **29 ordinary minute periods**, rather
than Kroah's documented 30. Cast resets also affect other active timers' phase.

The main loop compares counters for inequality; it does not process their
difference. After 480 clock interrupts without a scheduler poll, the calendar
advances two minutes but the effect countdown decrements only once. A repeated
poll without another interrupt does nothing. Resume likewise sees one changed
counter, not all paused interrupts. These observations prohibit presenting the
original caller as an elapsed-time accumulator.

## Execution order and domains

1. At a scheduler pass, pending owners are scanned in descending table-slot order
   (`$267a..26ac`). Their captured event bits use S29's Get/Drop/Use/Unuse/Delete
   order. Owner events finish before effect timers (`$03a2`, `$03a6`). Newly
   activated effects can execute in that same pass; deletion can prevent expiry.
2. Effects scan live slots in ascending order (`$244c..245a`, `$252a..2534`).
   Allocation uses the lowest available slots. Noncommuting saturating Add/Sub
   probes prove the order: starting at 253, Add5/Sub5 yields 250, while Sub5/Add5
   yields 253. Stable modern instance IDs must not be confused with these slots.
3. Text records are skipped by timer processing. An initial unsigned 16-bit timer
   of zero is dormant, not an immediate action. Otherwise decrement; on zero,
   reload the unsigned 16-bit interval **before** incubation/action processing.
4. First expiry clears incubation bit 6 and enables linked text visibility bit 3
   (`$253e..256a`), then evaluates natural cure, then executes the action. With
   cure zero, the first expiry performs the action; incubation does not skip it.
5. After action, decrement a nonzero unsigned byte counter. Zero counter means
   no execution-count expiry. A finite counter reaching zero removes the record;
   if it is the group root, linked records are removed too. A removed later slot
   does not execute just because it was due. No inverse arithmetic is performed.
6. Interval zero permits the current expiry action, then leaves timer zero and
   no further execution. A zero-counter record can remain live but dormant.
   Text enabled by incubation can be removed on that very expiry when the root's
   finite counter is exhausted; do not promise a rendered frame of visible text.

Natural cure has a preliminary RNG gate and precedes action; its complete RNG
contract is outside this slice. Definitions with nonzero cure must be rejected.
Synthetic Delete evidence supplies an explicit template-to-group binding; it
does not resolve the historical enchanted-item binding mechanism. S29's explicit
owner map remains the approved reconstruction architecture. Reentrant callbacks,
special-use hooks and arbitrary memory operations remain unsupported.

## Reconciliation decision and runtime contract

The user explicitly selected **“Preserve documented duration and reliable elapsed
time”** on 2026-11-20 after reviewing both discrepancies. Therefore:

- Preserve Physical Speed's documented 30-game-minute bonus. Do not copy the
  candidate's 29-minute active window or replay its raw template as an exact
  production schedule.
- Process all elapsed time, independent of frame/poll partitions. Do not copy
  missed-poll loss or allow casting to move unrelated effects' deadlines.

For the bounded remake, use activation-relative deadlines. This makes concrete
the existing S30 elapsed-duration contract rather than emulating the candidate's
shared interrupt phase. Physical Speed grants once at successful activation and
executes its explicit Sub5 at activation + 1800 game seconds; it is active over
`[activation, activation + 1800)`. This is the documented-duration normalization,
not a claim about the candidate's immediate grant. Raw initial zero still means
dormant: immediate grant is an explicit activation action, never a zero-timer
reinterpretation. Save at +600 seconds leaves 1200 seconds and does not replay
Add5. S31 implements this content/save path.

S30 consumes nonnegative integer **game microseconds**, with one minute =
60,000,000 units. S03 retains fractional conversion remainder; effects never
convert real time or reapply acceleration. Check overflow before mutation.
This precision is remake architecture, not original byte precision. For raw
supported positive timer/interval values 1..65535, multiply by 60,000,000;
retain zero separately as dormant/disarmed. Counters accept 0..255, distinguishing
unbounded from exhausted finite state. Incubating/text-visible are booleans;
owner/group IDs stay S29 IDs, never memory addresses.

At equal timestamps: process the supplied owner-event batch before due timers;
within an owner preserve S29's bit order. Source-ordered batch metadata must
preserve descending owner slot/rank order where multiple owners are supplied.
Due timers run in ascending scheduling-slot order, using the lowest vacant slot
on allocation; source long-text records reserve their continuation slot too.
Keep that order key separate from monotonic instance IDs. Do not recycle an
instance identity when a scheduling slot becomes available again.
Recheck liveness before each action; linked removal invalidates later due work.
No callbacks or unscheduled implicit reentrancy are supported. Event timestamps
must be explicit so a large elapsed update cannot move an event across a timer.
An event at a timer's exact timestamp runs first; earlier timers run earlier.

Required actions are named one-byte `speed_bonus` Add/Sub, saturating at 255/0,
single block, zero gap, byte parameter 0..255. Accept no arbitrary address,
entity-relative write, unsupported width/block layout, other operation or
nonzero cure. Reject invalid definitions/input atomically before activation or
elapsed-state mutation. Text has visibility/link state but no stat action.
Removal is record cleanup only, not implicit Sub5 or generic rollback.

## Handoff and acceptance

| Criterion | Evidence / disposition |
| --- | --- |
| S32-AC1 | Clock/caller/phase table; ordinary, accelerated, pause, missed-poll and cast-phase probes; explicit duration/cadence reconciliation. |
| S32-AC2 | Owner/timer order, slot order, incubation/action/counter/removal above; event/timer and deletion probes. |
| S32-AC3 | 18 reproducible original-code cases, including all requested zero/finite/incubation/tie boundaries. |
| S32-AC4 | Explicit domains, supported operations/rejections, precision and user-approved normalization above. |
| S32-AC5 | S03-CLOCK and S08-SPEED specifications and S30 readiness updated; validation results in the acceptance review. |

S32 resolves the bounded research gates. S03-CLOCK must still implement and verify
the elapsed-time interface; S08-SPEED must still implement and verify typed stat
actions. S30 remains Backlog until both deliverables pass. No entire calendar or
stats feature must close, and no production timing, stat mutation or save path
was implemented by this research.
