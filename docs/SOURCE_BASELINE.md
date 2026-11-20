# Canonical source baseline

Accepted by the user on **2026-11-16**.

**City rules: Atari ST The City v2.0, as documented by Kroah.** This is the project's source of truth for reconstructing City behavior. Start with the [local archive](../assets/documentation/kroah-city-st-v2/README.md), the [research review](KROAH_ST_REVIEW.md), and the [original site](http://bringerp.free.fr/RE/Ar/news.php5).

## Applying the decision

- Use Kroah's documented ST algorithms and tables when implementing City systems. Link each implemented rule to the relevant archived page/section and add focused behavioral checks.
- Use same-edition manuals and executable evidence to clarify or verify findings. Record contradictions or suspected errors explicitly before reconciling them; the chosen reference is authoritative for the project, not a claim that every interpretation has been independently verified.
- Treat 8-bit City documentation, C64 material, ARX and general FAQs as comparison evidence. They must not silently replace documented ST rules.
- For undocumented or ambiguous behavior, mark the gap and any provisional choice. Preserve numerical precision and update ordering where established. Separate original bugs from intended behavior; do not reproduce crashes by default.
- Retain the verified Atari 8-bit Dungeon data as the Dungeon baseline. Joining editions, two-way chapter travel and any shared-system differences are explicit remake adaptations.
- Preserve user-approved presentation and usability choices: Tail of the Dog/Grimthorn identity, selected song, modern art, live map, hold movement and test controls. Verify the ST location mapping separately before changing geography.

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
