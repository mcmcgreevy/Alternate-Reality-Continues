# F02/F03 story readiness — 2026-11-22

Follow-up: implementation and automated feature review are now complete; see [current acceptance](F02_F03_ACCEPTANCE.md). The readiness findings below preserve the pre-implementation review.

Reviewed live GitHub issues #9, #10, #35 and #36 against the isolated sprint baseline. This is a readiness review, not a completion review or new test run.

| Feature/story | Verdict | Required next work |
| --- | --- | --- |
| F02 / S02 #35 | Ready to implement after refinement | Execute the three explicit tasks in [S02](stories/S02_PERSISTENCE.md): complete-save validation/migration, deterministic gameplay randomness, failure-safe writes |
| F03 / S03 #36 | Already Done; do not reopen or duplicate | Reconcile feature acceptance with S03_CLOCK.md and current S30/S31 integration, run integrated regressions, record outstanding manual results |

## Findings resolved in refinement

S02's original one-line acceptance omitted production versus prototype saves, supported versions, replay scope, precision-safe generator storage, legacy random-state migration, complete-state atomicity and failed writes. Its revised specification now defines these and testable examples. Existing S03/S08/S30/S31 dependencies are implemented; no unresolved historical question blocks starting S02.

S03's live description still said S30 was blocked on S08. That is historical status text: both dependencies are now complete. F03's parent remains open with a generic backlog template despite its completed child. Update the parent to explain final acceptance work; do not infer missing implementation from that stale template.

## Feature closure checklist

F02: S02 criteria pass, save compatibility documented, focused and integrated regressions pass, evidence linked. Do not treat the existing 114 baseline checks as coverage of the new failure/replay requirements.

F03: confirm start date and twelve-month/year rollover, ordinary/accelerated/paused paths and explicit service costs, no double charging, clock persistence and integrated effect timing. Existing S03 evidence covers the implementation; the accelerated adapter does not imply completed inn/job/guild gameplay. No additional feature story is currently justified. Create a defect only if verification identifies concrete missing behavior.

Pending user playtest: Not run. It is independent of story readiness; keep F02/F03 final acceptance and merge explicitly pending until the applicable manual results are recorded. The user's working-folder variant includes unrelated movement/weather changes, so attribute any finding to its exact build before applying a fix to the sprint branch.

## Order and tracking

Start S02 validation/schema work, then generator persistence, then protected writes and integrated checks. Review F03 alongside those checks without rebuilding its clock. Three S02 tasks are checklists inside the existing story, not separate story IDs or sub-issues. GitHub issue bodies carry this refinement; this review does not change project-board status or close features.
