# Tavern song source preparation

Research date: 2026-11-11. No modern arrangement or sung audition exists yet.

## Source files received

The user subsequently supplied a full lyric transcription and an MP3 of the
selected performance. Text is preserved in
`data/music/hail-and-welcome/lyrics-source.txt`; provenance, SHA-256, text
section groupings and verification status are in the adjacent `source.json`.
The MP3 is copied to `tools/reference/tavern-music/hail-and-welcome-source.mp3`.
Godot successfully loads it and reports 130.219 seconds. This is a file-load
check, not a listening check. Previous statements below that the source file
or full lyric sheet is missing describe the earlier research stage and are
superseded by this receipt. User wording remains uncorrected pending review.

## Selected reference (user supplied)

The user selected **Hail and Welcome**, replacing the provisional Thoreandan
candidate below. Use this performance as the arrangement reference:
https://www.youtube.com/watch?v=7dlPu-MNC7w

Public YouTube metadata retrieved 2026-11-11:

- Title: Alternate Reality: The City tavern song "Hail and Welcome"
- Uploader: Dan Scott (@DanScottCAN)
- Video duration: 130 seconds (2:10); this is video length, not a verified loop length.
- Description identifies a capture from the **1986 Atari ST port**.

This user-selected Atari ST performance takes precedence over the earlier
general C64 reference preference for this audition. Do not substitute the
Atari 8-bit Dance/Dragon clips or continue looking for a C64 version as a
prerequisite. Metadata has been inspected; the audio and on-screen lyrics
have not yet been reviewed. Melody, key, meter, tempo, phrase boundaries and
subtitle timing still require analysis of this performance.

Next production step: obtain an analyzable audio/video copy of this selected
performance, establish a verse/refrain excerpt, and transcribe the music into
an editable arrangement. Preserve the male dwarf vocal direction and export
both mixes from the same backing session.

## User verification and correction

The user identifies the establishment as **Tail of the Dog Tavern** and
supplies the opening phrase "hail and welcome traveler." No verified full
lyric sheet has been recovered. Use this phrase as an identity check against
the selected video, not as a basis for inventing the remaining lyrics.

The user listened to Tavern Dragon and rejected it as a match. Tavern Dance
was reported as dead air. Follow-up sample analysis confirmed zero samples
at 0, 1, 5 and 15 seconds, with audio present near 29 seconds. The earlier
whole-file peak check was inadequate to validate a usable listening excerpt.
Neither clip is an approved reference for this arrangement. Do not use either
for melody transcription or vocal generation.

The displayed tavern name has been updated at the user's direction; this
naming change does not move the establishment or assert historical location
equivalence between platform versions.

## Earlier candidate research (superseded)

**Thoreandan** was the initial working candidate for the first audition. This was a
selection for the remake, not a claim that it was the only song or the song
assigned to the tavern at 63N,21E.

[C64-Wiki's song section](https://www.c64-wiki.de/wiki/Alternate_Reality_-_The_City#Songtexte)
explicitly associates it with taverns and describes randomized verse order.
It also explains that its song titles are editorial labels rather than titles
displayed in the game. Its lyric transcription is a comparison source, not yet
a verified performance script. Full lyrics are not reproduced here.

The [original C64 guidebook](https://www.lemon64.com/doc/alternate-reality-the-city/49)
confirms that tavern songs convey gameplay clues. Preserve this function in
the arrangement and subtitle treatment.

## Recovered source music

[ASMA](https://asma.atari.org/) preserves Atari music in SAP files containing
original executable music data. Downloaded its linked archive:
https://asma.atari.org/asmadb/asma.zip

Extracted these two files into the ignored `tools/reference/tavern-music/`
directory. Metadata below comes directly from their SAP headers.

| File | Archive title | Composer / date | Timing |
| --- | --- | --- | --- |
| Alternate_Reality_City_Dan.sap | Alternate Reality: The City - Tavern Dance | Gary Gilbertson / 1985 | NTSC, 01:27.368, loop |
| Alternate_Reality_City_Dra.sap | Alternate Reality: The City - Tavern Dragon | Gary Gilbertson / 1985 | NTSC, 02:24.799, loop |

SHA-256:

- Dance: `5bcb862d26c12d8c70f818e79e9ad5748e04ad789a83ed395704c2fab1d1562f`
- Dragon: `74ac0287e436062072b3fc1c43f769c3bf0afedb00c64cf960f62d093de9d0ae`

The [Demozoo composer index](https://demozoo.org/sceners/50829/) independently
lists both titles among the City's Atari music. The labels suggest possible
matches to Dwarf Dance and Thoreandan, respectively, but that mapping has NOT
been confirmed through synchronized in-game lyrics. Do not silently equate
these names or infer C64 note-for-note equivalence.

## Listening references

Generated 30-second WAV excerpts in the same ignored reference folder:

- `atari-tavern-dan-reference-30s.wav`
- `atari-tavern-dra-reference-30s.wav`

These are emulated original Atari performances, not modern instruments,
not C64 recordings, and not the requested vocal/instrumental auditions.
Their WAV structure, duration and non-silent samples were checked; they have
not been assessed by listening in this session.

Reproduce with `node tools/render_tavern_reference.mjs`. The script expects the
two SAP files above and the archive's upstream ASAP JavaScript engine at
`tools/reference/tavern-music/asap-with-asapwriter.mjs`, downloaded from
https://asma.atari.org/asmadb/asap-with-asapwriter.js (extension changed only).
The engine is an external reference dependency, not vendored into the game.
[ASAP documentation](https://asap.sourceforge.net/) describes its 6502/POKEY
emulation and GPL licensing. Neither the engine nor the SAP files are imported
by the playable project.

## Earlier C64 verification gap (no longer blocks selected song)

Searching the [HVSC mirror](https://6581.nl/?q=Alternate) returned
`GAMES/A-F/Alternate_Reality-The_Dungeon.sid` but no City entry. This is a search
result, not evidence that no C64 City rip exists. The Eobet archive timed out;
the individual Demozoo song pages were unavailable through the attempted
retrieval methods. No exact C64 tavern recording was recovered.

The earlier source requirement was a C64 City tavern capture with audible music and
on-screen lyrics, or a verified music rip plus an in-game comparison. Use it
to establish song identity, verse order for the audition, pitches, rhythm,
tempo and phrase boundaries. Until then, no key, BPM, note transcription or
lyric timestamps are claimed as verified.

## Arrangement preparation

For the user-selected Hail and Welcome performance, transcribe a complete verse/refrain passage
within the requested 30–60-second audition length. Keep the melody on a
separate MIDI track, with syllable positions available for a singing synth.
Preserve source harmony first; use a lute for the rhythmic harmony, bowed
strings for sustained support, hand drum for pulse, and a quiet theremin-like
response only where it leaves room for the singer. Transpose all pitched parts
together if the male bass-baritone needs a lower key.

Build one backing session with an isolated vocal track. Export the full mix
and that same mix with vocals muted, sharing start/end points and gain.
Note-controlled singing or a performed vocal remains the preferred production
route for melody fidelity. Eleven Music audio references guide new
compositions and do not promise a faithful cover; no subscription is required
for the source preparation phase.
