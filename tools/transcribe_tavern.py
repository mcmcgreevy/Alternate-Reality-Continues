"""Make an explicitly unverified, reproducible audio-to-MIDI listening draft.

Run with tools/reference/audio-venv/Scripts/python.exe.
Dependencies and model stay in the ignored reference environment.
"""
from pathlib import Path
import json
import hashlib
import importlib.metadata
import numpy as np
import soundfile as sf
import pretty_midi
from basic_pitch.inference import predict
import basic_pitch

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'tools/reference/tavern-music/hail-and-welcome-source.mp3'
OUT = ROOT / 'builds/music/hail-and-welcome-draft'
OUT.mkdir(parents=True, exist_ok=True)
RATE = 44100
SECONDS = 45


def save_audio(name, samples, rate):
    assert np.isfinite(samples).all()
    peak = float(np.max(np.abs(samples)))
    assert peak > 0.0001, f'{name}: silent render'
    if peak > .85:
        samples = samples * (.85 / peak)
    sf.write(OUT / name, samples, rate, subtype='PCM_16')
    rms = [float(np.sqrt(np.mean(samples[i:i+rate] ** 2)))
           for i in range(0, len(samples), rate)]
    return {'duration_seconds': len(samples)/rate, 'peak_before_limit': peak,
            'rms_per_second': rms}


def synth(notes, plucked=False):
    result = np.zeros(int((SECONDS + 1) * RATE), dtype=np.float64)
    for note in notes:
        start = int(note.start * RATE)
        length = min(len(result)-start, int((note.end-note.start+.25)*RATE))
        if length <= 0:
            continue
        t = np.arange(length)/RATE
        freq = pretty_midi.note_number_to_hz(note.pitch)
        signal = np.zeros(length)
        for harmonic in range(1, 7 if plucked else 4):
            envelope = np.exp(-t*(2.5 + harmonic*.65)) if plucked else np.exp(-t*.6)
            signal += np.sin(2*np.pi*freq*harmonic*t) * envelope / harmonic**1.8
        attack = np.minimum(t/.012, 1)
        release = np.minimum(np.maximum((note.end-note.start+.20-t)/.20, 0), 1)
        result[start:start+length] += signal*attack*release*(note.velocity/127)*.12
    return result


audio, sr = sf.read(SOURCE, always_2d=True)
print(f'Decoded {len(audio)/sr:.3f}s, {sr}Hz, {audio.shape[1]} channels', flush=True)
excerpt = audio[:int(SECONDS*sr)]
stats = {'original-excerpt.wav': save_audio('original-excerpt.wav', excerpt, sr)}
model = Path(basic_pitch.__file__).parent / 'saved_models/icassp_2022/nmp.onnx'
assert model.exists(), model
print('Transcribing first 45 seconds with Basic Pitch ONNX...', flush=True)
output, midi, events = predict(OUT/'original-excerpt.wav', model_or_model_path=model,
                              onset_threshold=.5, frame_threshold=.3,
                              minimum_note_length=120, multiple_pitch_bends=False)
# Keep raw output for review; do not present 120 BPM MIDI default as measured tempo.
midi.write(str(OUT/'automatic-polyphonic.mid'))
np.savez_compressed(OUT/'model-output.npz', **output)
notes = [n for inst in midi.instruments for n in inst.notes if n.start < SECONDS]
assert notes, 'No notes detected'
for note in notes:
    note.end = min(note.end, SECONDS)
stats['automatic-note-preview.wav'] = save_audio('automatic-note-preview.wav', synth(notes), RATE)
stats['plucked-texture-study.wav'] = save_audio('plucked-texture-study.wav', synth(notes, True), RATE)
# A monophonic candidate: prefer the highest sufficiently strong sustained note.
# This is a heuristic, not proof of which part carries the sung melody.
step = .02
track = []
for t in np.arange(0, SECONDS, step):
    active = [n for n in notes if n.start <= t < n.end and 48 <= n.pitch <= 88]
    strongest = max((n.velocity for n in active), default=0)
    active = [n for n in active if n.velocity >= strongest*.65]
    track.append(max((n.pitch for n in active), default=-1))
lead = []
first = 0
for i in range(1,len(track)+1):
    if i == len(track) or track[i] != track[first]:
        if track[first] >= 0 and (i-first)*step >= .12:
            lead.append(pretty_midi.Note(90, track[first], first*step, i*step))
        first = i
lead_midi = pretty_midi.PrettyMIDI(initial_tempo=120)
instrument = pretty_midi.Instrument(0, name='UNVERIFIED melody candidate')
instrument.notes = lead
lead_midi.instruments.append(instrument)
lead_midi.write(str(OUT/'melody-candidate.mid'))
stats['melody-candidate.wav'] = save_audio('melody-candidate.wav', synth(lead), RATE)
report = {
    'status': 'automatic draft; requires user listening review',
    'source_sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
    'source_offset_seconds': 0, 'excerpt_seconds': SECONDS,
    'polyphonic_notes': len(notes), 'melody_candidate_notes': len(lead),
    'pitch_range': [int(min(n.pitch for n in notes)), int(max(n.pitch for n in notes))],
    'model': 'Spotify Basic Pitch ICASSP 2022 ONNX',
    'model_sha256': hashlib.sha256(model.read_bytes()).hexdigest(),
    'versions': {p: importlib.metadata.version(p) for p in
                 ['basic-pitch','numpy','soundfile','librosa','onnxruntime','pretty_midi']},
    'notes': ['No verified key, tempo, meter, lyrics alignment, or vocal rendering.',
              'MIDI 120 BPM is only a timebase; note times follow the audio.',
              'Plucked study uses synthetic tones, not sampled lute or finished instrumentation.',
              'Melody selection may confuse accompaniment or harmonics with the tune.'],
    'audio_checks': stats
}
(OUT/'analysis.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
cards = [('original-excerpt.wav','1. Original recording', 'First 45 seconds of your MP3.'),
         ('automatic-note-preview.wav','2. Detected notes', 'All detected pitches in a plain tone. Listen for wrong or missing notes.'),
         ('melody-candidate.wav','3. Melody candidate', 'Unverified upper-line extraction. Does it follow the tune you would sing?'),
         ('plucked-texture-study.wav','4. Plucked texture study', 'The same automatic notes with a plucked sound. Not a finished arrangement.')]
html = '''<!doctype html><html lang="en"><meta charset="utf-8"><title>Hail and Welcome — transcription audition</title>
<style>body{font:18px/1.5 system-ui;background:#17191d;color:#eee;max-width:760px;margin:48px auto;padding:0 24px}section{padding:20px;background:#252830;border-radius:12px;margin:20px 0}audio{width:100%}a{color:#b9d9ff}h1{line-height:1.15}</style>
<h1>Hail and Welcome</h1><p>Tail of the Dog Tavern · software transcription audition</p>
<p>These are unverified musical sketches. No singing is included. Compare the melody and rhythm before judging the sound.</p>'''
for file,title,desc in cards:
    html += f'<section><h2>{title}</h2><p>{desc}</p><audio controls preload="metadata" src="{file}"></audio></section>'
html += '<p><a href="automatic-polyphonic.mid">Polyphonic MIDI</a> · <a href="melody-candidate.mid">Melody MIDI</a></p>'
html += '<script>document.querySelectorAll("audio").forEach(a=>a.addEventListener("play",()=>document.querySelectorAll("audio").forEach(b=>{if(a!==b)b.pause()})))</script></html>'
(OUT/'listen.html').write_text(html,encoding='utf-8')
print(json.dumps({k:report[k] for k in ['polyphonic_notes','melody_candidate_notes','pitch_range']}),flush=True)
print(OUT/'listen.html',flush=True)
