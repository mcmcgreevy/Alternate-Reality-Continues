# Current implementation

The user-selected three-track recording is now integrated, with Grimthorn Redbeard at Tail of the Dog Tavern. See [integration and caption review notes](TAVERN_MUSIC_INTEGRATION.md). The following audition plan is historical and is superseded by the selected recording.

# Tail of the Dog Tavern music audition

Direction agreed 2026-11-11. A first automatic transcription and synthetic
plucked sketch are available; see [software audition](TAVERN_MUSIC_SOFTWARE.md).
The finished arrangement and vocal audition remain pending.
Original Atari listening excerpts and source findings are recorded in
[the research notes](TAVERN_MUSIC_RESEARCH.md).

## Source

Arrange **Hail and Welcome**, preserving its recognizable melody and original
lyrics, using the user's selected [Dan Scott video](https://www.youtube.com/watch?v=7dlPu-MNC7w).
The video's description identifies the 1986 Atari ST port; this specific
selection supersedes the earlier general C64 reference for this audition.
Do not develop the four-line placeholder in scripts/tavern_music.gd or use
the provisional Thoreandan candidate. The video's metadata is verified, but
its audio, lyric alignment and musical transcription remain to be analyzed.
The user has now supplied the MP3 and full lyric text. The preserved text and
source manifest are in `data/music/hail-and-welcome/`; the reference MP3 is
in the ignored `tools/reference/tavern-music/` folder. These supersede the
earlier search candidates. Do not substitute guessed lyrics or either Atari
8-bit excerpt. The source MP3 loads in Godot and runs approximately 130.219
seconds; no listening or note-level verification is claimed.

## First audition

Produce two versions of the same arrangement:

1. Vocal: a male dwarf, with a resonant bass-baritone, warm gravel, clear words,
   and the relaxed confidence of an experienced tavern singer. Sing naturally;
   avoid a comic growl. Final key follows the verified melody and vocal range.
2. Instrumental: the identical backing performance, with the vocal stem muted.
   Preserve tempo, key, duration, mix level, and phrase positions for comparison.

Fantasy and medieval tavern instrumentation: plucked lute, bowed fiddle,
restrained hand drum, and a soft sustained drone. Add a quiet theremin-like
voice between sung phrases, hinting at the setting's science-fiction mystery.
Keep the acoustic ensemble dominant. Avoid a modern pop beat or a large
cinematic orchestra. Match the original song's character when selecting meter
and tempo rather than imposing these before listening to the reference.

Keep vocal casting per song undecided. This audition tests one dwarf singer;
it does not establish a single vocalist for the entire game.

## Playback proposal

Use independent Vocals and Song subtitles controls. This permits vocals only,
subtitles over instrumental music, both, or instrumental music alone. Existing
music mute remains separate. These controls are proposed, not implemented.

Prefer synchronized instrumental and isolated vocal stems, plus a full vocal
mix for audition. Both stems must share the same start, duration, and sample
rate. Derive subtitle cues from the actual performance, not the current
four-second placeholder intervals. Do not claim two independently generated
tracks are matching stems. If generation cannot supply aligned stems, assess
separation quality before choosing an integration strategy.

## Outstanding production work

- Verify the original tavern song, recording, melody, and lyric source.
- Prepare a faithful note transcription before selecting a vocal tool. Prefer
  a singer or note-controlled singing synthesizer for the original melody.
- Generate and listen to the two auditions; check words, melody fidelity,
  vocal character, theremin balance, and instrumental separation artifacts.
- Record source provenance and generation details alongside the final files.
- After audition feedback, prepare loop boundaries and subtitle timing, then
  integrate the approved audio into the game.

The existing playable build and its placeholder audio are unchanged.
