# S01 — Establish rule provenance and effect contracts

Parent: #8 · Epic: E01 (#1) · Milestone: M1 — Character and world foundations

<!-- ar-planning-baseline-2026-11-17 -->

## User story

As a developer, I can trace a gameplay rule or effect contract to archived evidence and distinguish original behavior from reconstruction choices, so later systems can be implemented and reviewed consistently.

## Outcome and scope

Create a small, reviewable foundation for rule implementation: a structured rule catalog, six seed records, documented effect terminology and lifecycle, and independently sourced example fixtures. This story does **not** implement the runtime effects engine. Completing it does not complete F01.

The City baseline is Kroah's Atari ST City v2.0 documentation. Dungeon behavior and remake adaptations must be identified separately. “Documented” means supported by that source, not independently verified against the original executable.

## Deliverables

1. `docs/RULE_MODEL.md`: record format, evidence classifications, effect contract, uncertainty policy and instructions for adding a rule.
2. `data/reference/rules.json`: the six seed records below. Development reference only; no gameplay dependency. Add `.gdignore` in that reference directory.
3. `tests/fixtures/rule_examples.json`: provenance-linked input/expected-output examples, with documented rules separated from adaptations.
4. `tools/validate_rule_catalog.py`: read-only validation of required fields, IDs, classifications, fixture references and local source paths/catalog hashes. Fail clearly on invalid records; do not implement production gameplay formulas in this validator.
5. Links from `docs/SOURCES.md` and `docs/CODE_GUIDE.md` explaining where future rule/effect work starts.

These deliverables were implemented locally on 2026-11-18; see the validation record below.

## Record contract

Each record has a stable rule ID, subsystem, edition/platform, source URL, unchanged local source filename, catalog SHA-256 reference and precise section/table locator. It states inputs/outputs, units, formula or event behavior, precision/rounding, bounds, trigger/cadence, documented update order, evidence classification, current implementation status/location, fixture IDs and unresolved questions.

Use separate fields for evidence (`documented`, `adaptation`, `unresolved`) and implementation coverage (`not implemented`, `partial`, `implemented`). Unknown units, bounds or ordering must say `unknown` with a question; not applicable must be explicit. Adaptations need a rationale and a link to the documented rule they adapt. Do not label a provisional choice “documented.”

## Six seed records

| ID | Scope | Evidence and boundaries |
| --- | --- | --- |
| STAT-001 | Base/effective/displayed primary stats and bonus/penalty roles | `characterStats.html`, Primary: preserve fractional base versus integer effective value; distinguish displayed value and delusion. Do not infer missing clamp rules. |
| MOVE-001 | Effective Speed to walking rate | `characterStats.html`, Walking Speed: record integer arithmetic, initial values and maximum. |
| MOVE-002 | Walking units to tile distance | Current `WALKING_UNITS_PER_TILE` in `scripts/original_world.gd` and `docs/MOVEMENT.md`: explicitly a reconstruction calibration, including its current application to Dungeon travel. |
| TIME-001 | Continuous ordinary game-clock conversion | `world.html`, Time Span: distinguish real seconds from game time. Accelerated services and exact pause-policy reconciliation are follow-up S03 scope. |
| EFFECT-001 | Effect templates versus active instances | `technicalNotes.html`, Entity / Effect: definitions belong to an entity; activation copies an effect into active state. Describe definition identity separately from instance identity. |
| EFFECT-002 | Event-triggered activation and opposing-event removal | `technicalNotes.html`, Events / Effect / Required events: capture only supported lifecycle and multiplicity statements. Unknown event bits, timer units and underspecified ordering remain questions, not invented rules. |

Source HTML and the catalog are already under `assets/documentation/`; consult raw HTML where the text extraction flattens a table. New references, if needed, follow the existing archive policy.

## Acceptance criteria

- [x] **AC1 — Traceability:** All six records point to existing unchanged source artifacts or explicitly identified implementation evidence. Catalog hashes match; each documented assertion has a section/table locator. An implementation file alone cannot establish original behavior.
- [x] **AC2 — Quantities:** Inputs, outputs, units, precision, rounding, bounds, cadence and ordering are stated or explicitly unknown/not applicable. Every uncertainty identifies the affected rule and the downstream work it may block.
- [x] **AC3 — Fidelity separation:** MOVE-002 is classified as an adaptation; the unverified tile scale and Dungeon reuse cannot be presented as established ST/Dungeon behavior. Unknown technical-note bits remain unresolved.
- [x] **AC4 — Effect contract:** The design distinguishes entity definitions, effect definitions, active effect instances, event handling and removal. A worked lifecycle example identifies what is documented and what needs verification; no unsupported stacking/expiry semantics are introduced.
- [x] **AC5 — Examples:** Fixtures include effective-stat calculation `13.75 + bonus 2 - penalty 5 -> effective 10`; effective Speed `7/13/25 -> walking rate 4/6/10`, plus a case exercising the documented cap; ordinary clock `4 real seconds -> 1 game minute`; and the current adaptation `walking rate 6, 6 units/tile -> 1 real second/tile`. Expected results come from the cited rule, not output captured from the current implementation. Effect fixtures describe supported activation/removal outcomes and explicitly flag missing ordering information.
- [x] **AC6 — Validation:** Validator succeeds on the catalog and examples. Focused negative checks demonstrate rejection of duplicate IDs, missing evidence/classification, broken local source/fixture references and a catalog hash mismatch. Validation does not modify archived files or run the game.
- [x] **AC7 — Integration and handoff:** Documentation links resolve, reference data is excluded from game imports, and no runtime behavior or persisted character fields change. List follow-up implementation questions for S08 (stats), S03 (time), S10 (items) and S09 (metabolism). Existing runtime files should not need modification for this story.

## Implementation checklist

- [x] Extract the six bounded rules from archived sections and record uncertainties.
- [x] Define the record format and seed catalog.
- [x] Write the effect contract and worked lifecycle example.
- [x] Add source-derived fixtures and catalog validation with focused negative checks.
- [x] Update guide/source links and review the six records against evidence.

## Dependencies and exclusions

Prerequisites already available: accepted source baseline, archived technical/stat/world pages and documentation catalog. No other gameplay feature must be completed first. Unresolved original-engine details need not block this documentation story if they are explicitly recorded; they may block later implementation stories.

Out of scope: full game-rule transcription; executable disassembly; copy-protection behavior; runtime modifier stacking/timers; complete stats/creation; weather penalties; equipment, combat and magic; save-schema changes; changes to the movement calibration. Those require separately refined stories under the relevant features. Refine remaining F01 runtime/design work after this contract rather than assuming this story delivers an engine.

## Implementation and validation record

Implemented locally on 2026-11-18 following the request to begin S01. All seven
acceptance criteria have been checked against the archived evidence and local
implementation. This is a local delivery record; the GitHub Project remains the
workflow-status authority and was not updated by this implementation.

- [Rule model and handoff](../RULE_MODEL.md): record schema, evidence policy,
  effect lifecycle example and S08/S03/S10/S09 follow-up questions.
- [Rule catalog](../../data/reference/rules.json): six records; original HTML
  paths and SHA-256 values match the existing archive catalog.
- [Fixtures](../../tests/fixtures/rule_examples.json): ten manually source-derived
  examples, with adaptations separated and event ordering uncertainties retained.
- `python tools/validate_rule_catalog.py`: passes, six rules and ten examples.
- `python -m unittest discover -s tests -p test_rule_catalog.py -v`: 13 checks pass,
  including the required negative cases. Archives are not modified by validation.
- Source/guide links added; reference directory has `.gdignore`. No runtime or
  persisted-field changes are part of S01. Existing unrelated workspace edits
  were preserved. F01 runtime work remains separate.
