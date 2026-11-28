# Hail and Welcome: first software audition

The first 45 seconds of the user-supplied MP3 have been processed locally
with Spotify Basic Pitch 0.4.0 using its packaged ICASSP 2022 ONNX model.
This is an automatic transcription draft, not an approved score or arrangement.

Open `builds/music/hail-and-welcome-draft/listen.html` for four listening examples:

1. The source excerpt.
2. All 313 detected note events rendered with simple additive tones.
3. A 110-note monophonic melody candidate, chosen heuristically from the
   stronger upper notes. This can mistake harmonics or accompaniment for melody.
4. The polyphonic notes rendered with a synthetic plucked timbre. This is a
   texture sketch, not a sampled lute or finished backing performance.

The same folder contains `automatic-polyphonic.mid`, `melody-candidate.mid`,
the raw model output, and `analysis.json` with input/model hashes, dependency
versions, and per-second RMS measurements. MIDI's 120 BPM setting is a timebase,
not an estimated song tempo; event timestamps retain the source timing.

All generated previews are PCM16 WAV. Their first 45 seconds contain signal
in every one-second window. The additional second allows release tails and
includes trailing silence. Files were numerically checked, not listened to
by the assistant. No sung vocals or subtitle cues have been generated.

## Reproduce

Use the isolated environment at `tools/reference/audio-venv/`:

```
tools/reference/audio-venv/Scripts/python.exe tools/transcribe_tavern.py
```

The environment and generated audio are ignored by Git. The script is kept
in source control. Exact installed versions are in the output manifest.
Dependencies are numpy, scipy, soundfile, librosa, pretty_midi, onnxruntime,
mir_eval, resampy, typing_extensions, and basic-pitch. Basic Pitch was installed
with `--no-deps` after these dependencies to select ONNX without its older
TensorFlow dependency. This Python 3.13 environment is outside Basic Pitch's
documented compatibility list; this inference run completed successfully, but
the environment should not be assumed generally supported by upstream.

Source documentation: https://github.com/spotify/basic-pitch

## Listening review before vocal production

Compare the original and melody candidate: does the candidate follow the
line you would sing, including the opening refrain? Identify any point where
it switches parts, misses a note, or loses the rhythm. Correct the MIDI before
aligning the supplied lyric syllables. The plucked sketch is only a starting
point for instrumentation; the intended fiddle, hand drum, theremin touches,
and dwarf vocal still need production.

The playable game's music is unchanged.
