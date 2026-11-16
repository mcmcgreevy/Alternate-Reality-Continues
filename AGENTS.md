# Project reference documentation

## Canonical City rules baseline

User decision, 2026-11-16: **Atari ST The City v2.0, as documented by Kroah, is the source of truth for City rules.** Consult the archived collection in `assets/documentation/kroah-city-st-v2/` and `docs/SOURCE_BASELINE.md` before implementing or revising City systems. Do not substitute 8-bit City, C64, ARX remake, FAQ, or provisional prototype rules when Kroah documents the ST behavior. Other editions are comparison evidence only. Record gaps, ambiguities and contradictions explicitly; do not invent undocumented details or silently override this baseline. Any independently demonstrated error should be documented for reconciliation.

Existing implementation is not automatically compliant: clock/calendar, weather, stats/metabolism, equipment, tavern economics and City location identities need reconciliation. Verified 8-bit Dungeon data remains the Dungeon baseline. Preserve explicitly approved remake choices (including Grimthorn, selected music and interface improvements) and label adaptations separately from historical rules. This source decision does not authorize indiscriminate rewrites or intentional reproduction of crash bugs.

## Code readability

Use explicit names for gameplay quantities, positions, source boundary codes and time units. Explain non-obvious invariants and reasons in comments, especially around one-way passages, transitions, save migration and independent clocks. Keep the architecture overview in `docs/CODE_GUIDE.md` current. Readability changes should preserve behavior and persisted field names, and run the relevant regression tests.

## Documentation library

The user wants reference documentation preserved in the assets library, not only linked online. When finding and using new manuals, hintbooks, or other documentation for this project, download the available document to `assets/documentation/` and add its provenance to that directory's catalog. For web-only documentation, preserve an appropriate local snapshot when available; if it cannot be archived, record the URL and limitation rather than claiming a local copy exists.

Record title, original URL, retrieval date, edition/platform, local filename, and SHA-256. Keep differing editions distinct and identify which version supports a rule. Link relevant findings from `docs/SOURCES.md`. Preserve source documents unchanged and put analysis in separate notes. Documentation is a development reference library, excluded from game imports via `.gdignore`.
