# Reference documentation library

[Kroah's Atari ST City v2.0 reverse-engineering collection](kroah-city-st-v2/README.md): 20 archived pages, with separate text extracts. See the collection's scope limitations and [project review](../../docs/KROAH_ST_REVIEW.md).

Downloaded manuals and supporting documents are kept here unchanged. This is a development reference collection, not runtime game content. `.gdignore` keeps it out of Godot's asset imports. See `catalog.json` for URLs, editions, retrieval dates and checksums.

## The City — Official Adventurer's Survival Handbook

[Local PDF](arcity-survival-handbook-st-mac-pc.pdf) · [Original scan](https://mocagh.org/datasoft/arcity-hintbook.pdf)

Edition: Atari ST, Apple Macintosh, and IBM PC. Retrieved 2026-11-15. Do not treat it as the 8-bit handbook; its introduction explicitly notes differences between versions.

**Weather and Clothing:** PDF page 4 (printed page 4) describes hot, warm, cool, cold and rainy conditions. Excess clothing/armour in warmth can cause heat and thirst; cold causes fatigue and slower movement; rain can make the character cold. Shops, taverns and inns provide shelter. A fur-lined cloak provides the strongest cold insulation, a Dragonskin Raincoat the best precipitation protection, and a fur-lined raincoat is described as ideal for all-weather use. The Dragonskin Raincoat is explicitly not flame-resistant.

This establishes qualitative effects for these editions, not exact random-weather probabilities, exposure formulas, or equivalence with 8-bit mechanics. Weather gameplay is not implemented by archiving this reference.

## GitHub planning references

The `github-planning/` directory contains unchanged HTML snapshots for Projects, issue hierarchies and the REST sub-issues API, retrieved 2026-11-17. See `catalog.json` for source URLs and SHA-256 checksums. External assets are not mirrored. These are tooling references, not evidence about original game mechanics.

### S29 original ST research (2026-11-19)

`s29-st-research/` preserves unchanged source-discovery pages, the candidate Datasoft v2.0 disk ZIP and STX format documentation. See `docs/S29_ST_EFFECT_RESEARCH.md` for provenance, executable findings and limitations. Text extracts are convenience derivatives, not original sources. The candidate is development evidence excluded from game imports; its rules are not silently substituted for Kroah.
