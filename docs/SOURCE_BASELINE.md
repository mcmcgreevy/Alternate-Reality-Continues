# Canonical source baseline

City baseline accepted **2026-11-16**; shared-mechanics precedence approved **2026-11-27**.

**City rules: Atari ST The City v2.0, as documented by Kroah.** This is the project's source of truth for reconstructing City behavior. Start with the [local archive](../assets/documentation/kroah-city-st-v2/README.md), the [research review](KROAH_ST_REVIEW.md), and the [original site](http://bringerp.free.fr/RE/Ar/news.php5).

## Applying the decision

- Use Kroah's documented ST algorithms and tables when implementing City systems. Link each implemented rule to the relevant archived page/section and add focused behavioral checks.
- Use same-edition manuals and executable evidence to clarify or verify findings. Record contradictions or suspected errors explicitly before reconciling them; the chosen reference is authoritative for the project, not a claim that every interpretation has been independently verified.
- Treat 8-bit City documentation, C64 material, ARX and general FAQs as comparison evidence. They must not silently replace documented ST rules.
- For undocumented or ambiguous behavior, mark the gap and any provisional choice. Preserve numerical precision and update ordering where established. Separate original bugs from intended behavior; do not reproduce crashes by default.
- Retain verified Atari 8-bit Dungeon evidence for Dungeon-specific content and mechanics. Resolve shared-mechanics conflicts using the decision below. Joining editions and two-way chapter travel remain explicit remake adaptations.
- Preserve user-approved presentation and usability choices: Tail of the Dog/Grimthorn identity, selected song, modern art, live map, hold movement and test controls. Verify the ST location mapping separately before changing geography.

## Shared mechanics across chapters

User decision, **2026-11-27**:

> Use Atari ST City v2.0, as documented by Kroah, for shared mechanics unless a documented Dungeon-specific requirement justifies an exception. Record every exception.

This is an approved remake policy for a consistent combined game, not historical evidence of how an unreleased ST Dungeon would have worked.

- Shared stats, time, effects, equipment, metabolism and other genuinely shared systems default to documented ST City rules when conflicts arise.
- Verified 8-bit Dungeon evidence remains authoritative for Dungeon geography, encounters, puzzles, treasures, progression and mechanics without a City equivalent. Shared rules may govern how content is resolved; they do not replace the content itself.
- Review content-sensitive conflicts before applying a shared rule that could break a Dungeon puzzle, encounter, reward or progression requirement. A documented requirement can justify a narrow exception. Do not silently change content or preserve prototype behavior without evidence.
- Missing ST evidence remains a gap. Do not invent ST behavior; identify available sources and label provisional choices. Independently demonstrated contradictions still require explicit reconciliation.
- Existing approved remake choices remain in force. This decision guides research, story acceptance and implementation; it does not certify existing code, authorize broad rewrites or merging, or waive save migration and playtests.

### Exception records

Document each exception in the affected system or story and link it here. Record:

1. Mechanic and chapter scope.
2. Conflicting editions and archived source locators.
3. The documented Dungeon-specific requirement.
4. Chosen behavior and rationale.
5. Cross-chapter character and save-state implications.
6. Acceptance checks.

Evidence-backed exceptions follow this policy. A discretionary new remake adaptation that changes established scope or behavior requires an explicit decision rather than being presented as historical necessity.

**Exception register:** None newly approved by this decision. Existing differences still require review; this does not assert that no exceptions will be needed. Previously approved travel and presentation adaptations remain documented separately.

## Existing implementation awaiting reconciliation

| Area | Current departure / next verification |
| --- | --- |
| Calendar and time | S03 reconciles the ST start date, calendar, ordinary/accelerated clock and explicit pause policy; see S03_CLOCK.md. Service content and movement distance calibration remain separately owned. |
| Weather | Five combined conditions and hourly equal probabilities versus separate weather types, seasonal selection, durations and ambient temperature. |
| Storms | Cosmetic prototype timing; reconcile ordinary rain versus storm strength and documented frequency. |
| Stats and metabolism | S08 supplies fractional base/effective/displayed views, hidden Speed and typed Speed actions; see S08_STATS.md. Metabolism formulas, delusion producers and timed content remain separately owned. |
| Clothing and equipment | Not implemented; derive protection, warmth and modifiers from the ST reference. |
| Taverns | Existing 8-bit/ARX-informed prices, free water and simplified menus require ST reconciliation, including local price factors and friendship. |
| City geography | Tail of the Dog and the northern Dungeon entrance are now checked against ST markers 16 and 49; see `ST_LOCATION_CORRECTION.md`. Wider ARX geometry and other establishment identities still need ST validation. |

This decision establishes direction; it does not claim those systems have already been converted. The existing playable build remains a scaffold until each subsystem is reconciled and tested.

## Playtest UI choices — 2026-11-27

User approved always displaying SPD in the remake HUD. The underlying historical reveal flag remains intact for saves and rules. Dungeon geometry beyond the rendered neighborhood uses black background/fog without City sky contribution.
