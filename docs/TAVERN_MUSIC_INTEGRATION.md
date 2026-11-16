# Hail and Welcome — game integration

The user supplied and selected three 48 kHz stereo WAV files revised on 2026-11-13: full mix, Without Lead Vocal, and Lead Vocal. Each contains 8,974,080 frames (186.96 seconds). These replace the previous 219.76-second take. The revised filenames begin with `Alternate Reality The City tavern song Hail and Welcome`. Untouched masters from both versions are preserved locally in ignored `tools/reference/hail-and-welcome-masters/`. `tools/prepare_tavern_audio.py` converts them to the three Ogg Vorbis assets under `assets/audio/hail-and-welcome/`; source and output hashes are recorded in `data/music/hail-and-welcome/production-audio.json`. The runtime copies are compressed; no level normalization or trimming was applied.

Tail of the Dog Tavern's barkeep and singer is **Grimthorn Redbeard**, a bald male dwarf with a long red beard. His identity is in `data/tavern.json` and the tavern screen. The title, map, guide and journal use the new tavern name. This names the existing establishment without moving its mapped location.

## Playback

- **L**: switch between full mix and Without Lead Vocal. Both run on one AudioStreamSynchronized clock, avoiding a restart. The latter may retain backing vocals from the supplied mix.
- **K**: independently show/hide song subtitles.
- **M**: mute/unmute while the clock continues.

Options persist in `user://music_settings.cfg`, independently of journey saves, and work within tavern menus. Leaving stops playback; returning restarts it. The complete recording repeats at its existing end, preserving intro/outro; this is not a seamless musical loop. The isolated vocal asset is preserved for production work, not added to the already complete full mix. The old prototype scene retains its synthetic cue as a regression fixture.

## Provisional captions — listening review still required

The authoritative text remains the user's `lyrics-source.txt`, including **drumfire** and **It is safe and warm**. `subtitles.json` now has all 34 source lines, matched to local Whisper small.en word timestamps from the revised full mix. The repeated chorus begins at approximately 1:02. Original spelling is preserved rather than copying recognition errors; phrase endings have small readability extensions.

These replace the old partial 21-cue pass; the previous timings are not reused. Recognition does not establish exact sung wording or timing. No auditory verification was available during integration, so listening review remains required. Review the opening refrain (0:00), narrative verse (0:30), repeated refrain (1:02), combat verse (2:03), and ending (2:33).

## Checks

`tests/test_tavern_music.gd` checks asset lengths, shared playback, switching without restart, independent caption/mute options, cue ordering, tavern exit/re-entry and saved preferences. `tests/test_original_route.gd` exercises the game scene and round trip. The original WAVs have matching frame counts; this is a technical alignment check, not a listening assessment of stem quality.
