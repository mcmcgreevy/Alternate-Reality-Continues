# City weather

**New evidence, 2026-11-16:** [Kroah's ST v2.0 review](KROAH_ST_REVIEW.md) documents a more detailed weather/temperature/warmth model. The implementation below remains provisional; review that source before extending stat or clothing effects. No weather behavior was changed as part of the research review.

Implemented 2026-11-15. Reference: [archived official City handbook, ST/Mac/PC edition](../assets/documentation/arcity-survival-handbook-st-mac-pc.pdf), PDF page 4, Weather and Clothing. This is edition-specific evidence; exact 8-bit mechanics and weather probabilities are not established.

## Playtest selector

Press **F6** to cycle **Auto → Hot → Warm → Cool → Cold → Rainy → Auto**. The header shows `Test` in amber while a condition is forced. Selection applies immediately, works with the map or tavern menus open, and cancels held movement without advancing time.

Forced weather stays fixed while travelling or waiting. Shelter still applies: select Rainy indoors and step outside to test exposure. Rendering and future clothing/stat effects use the same effective condition through `weather_at()` and `weather_exposure()`.

The override lasts for the session, including journey loads, but is not saved. Restarting begins in Auto. Cycling back to Auto resumes the seeded schedule at the current game time. This is a playtest aid, not an original-game mechanic.

## Current behavior

- Five conditions: Hot, Warm, Cool, Cold, Rainy. Auto makes a seeded, equal-probability selection each game hour; consecutive hours can match. This is a provisional remake rule, not the recovered original algorithm, and does not repeat automatically each day.
- The game clock drives conditions. Travel and waiting advance it; standing still only animates rain. The schedule continues indoors and underground.
- Rain adds overcast skies, reduced sunlight and ambient light, haze and foreground streaks within the world view. Cold adds lighter cloud cover. Hot, Warm and Cool use the normal day/night sky and condition label. Cool adds a light breeze; Cold adds stronger wind; Rainy adds rain ambience and occasional lightning flashes followed by thunder. Snow is not implemented.
- The header shows condition and shelter status. The Dungeon is underground/sheltered. Rain is hidden indoors, in taverns and on the map; map travel still updates the condition label.
- Shelter follows the existing City building/passage classification; the whole Dungeon is sheltered. Wider City roof classification remains provisional.
- Saves store `weather_seed` and the clock, restoring current and future automatic weather. Older version 3/4 saves without a seed receive a stable default. Invalid seeds are rejected before live state changes.

## Required follow-up when stats and equipment are built

**Weather currently applies no character penalties.** Existing hunger/thirst action costs remain unchanged. Exposure flags are inputs, not a finished survival system.

`original_world.gd::weather_exposure()` returns condition, exposed, rain, cold and heat flags without changing state. Future effects should integrate exposure over elapsed simulation-time intervals in `advance_time()`, including weather changes and shelter, rather than apply effects each rendered frame. The cold flag treats rain as potential cold exposure, not a calculated body temperature.

The manual establishes these dependencies:

- Cold increases fatigue and slows movement.
- Rain can make the character cold; rain protection mitigates it.
- Excess clothing and sometimes armour in warm weather cause overheating and thirst. Both Warm and Hot need equipment-aware evaluation; the current heat flag only identifies Hot ambient weather.
- Indoor shelter prevents further outdoor exposure. Recovery rates remain unverified.
- Clothing needs distinct insulation and rain protection: fur-lined cloaks are strongest against cold, Dragonskin Raincoats against precipitation (not flame-resistant), and fur-lined raincoats are described as ideal all-weather clothing.

Do not label invented damage, temperature, fatigue, protection or speed formulas as original. Verify source behavior or document provisional balancing. Future speed penalties must cooperate with held movement while retaining per-step simulation costs.

## Verification

`tests/test_weather.gd` checks conditions, hourly stability, shelter/exposure, unchanged stats, saved schedules, old saves, renderer settings, F6 cycling, fixed test conditions and return to Auto. Run without `--headless` and append `-- --capture` for `docs/city-weather-rain.png`. Existing City-environment and original-route tests cover rendering and gameplay integration.

## Weather audio and storms

`weather_effects.gd` uses original procedurally generated stereo Ogg assets under `assets/audio/weather`. `tools/generate_weather_audio.py` reproduces the assets with fixed seeds; the adjacent manifest records lengths, decoded levels and hashes. These are synthesized effects, not recovered original-game recordings or third-party samples. Signal validation checks non-silence, sample counts and clipping; perceived realism and balance need listening playtests.

Cool and Cold use distinct 24-second wind loops, with Cold louder and gustier. Rain uses a 24-second continuous rain bed with small impact textures. Condition changes crossfade ambience; entering shelter or Hot/Warm stops it. M mutes weather and tavern audio together using the existing saved mute preference. Muting sound does not disable lightning visuals.

Rainy outdoor exposure schedules a first flash after 4–9 real seconds, then flashes 12–28 seconds apart. Each is a single, brief, low-opacity blue-white illumination of the first-person viewport, not the UI/map. Thunder follows 0.8–3 seconds later, choosing among three eight-second rumbles with slight pitch variation. These are cosmetic flashes, not lightning strikes or damage. Rain and storms animate while standing still without advancing game time. Their timing is presentation-only and is not saved.

Changing away from Rainy, entering any covered City cell, or entering the Dungeon cancels both active and pending storm effects. Outdoor ambience remains audible with the map open, while visual flashes are suppressed there. Use F6 outdoors to test Cool, Cold and Rainy; remain in Rainy for at least nine seconds to see the first flash. `tests/test_weather_effects.gd` covers loops, relative wind levels, flash/thunder order, timing bounds, mute, cancellation, and unchanged simulation time.
