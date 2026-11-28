"""Render original procedural weather effects; no third-party recordings.

Run with tools/reference/audio-venv/Scripts/python.exe (numpy, soundfile).
Periodic filtered noise and modulation make ambience loops seamless. Thunder
uses non-looping envelopes. Fixed seeds keep generated assets reproducible.
"""
from pathlib import Path
import hashlib
import json
import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'assets/audio/weather'
SAMPLE_RATE = 24000
LOOP_SECONDS = 24
random = np.random.default_rng(76163)
OUTPUT.mkdir(parents=True, exist_ok=True)
manifest = {}


def filtered_noise(frame_count, low_cutoff, high_cutoff):
    """Frequency-domain filtering preserves periodic boundaries for looped beds."""
    frequencies = np.fft.rfftfreq(frame_count, 1 / SAMPLE_RATE)
    gain = 1 / np.sqrt(1 + (frequencies / high_cutoff) ** 4)
    gain *= frequencies / np.sqrt(frequencies**2 + low_cutoff**2)
    spectrum = np.fft.rfft(random.normal(size=frame_count)) * gain
    samples = np.fft.irfft(spectrum, n=frame_count)
    return samples / np.std(samples)


def write_asset(name, stereo_samples, peak):
    stereo_samples *= peak / np.max(np.abs(stereo_samples))
    path = OUTPUT / (name + '.ogg')
    with sf.SoundFile(path, 'w', samplerate=SAMPLE_RATE, channels=2,
                      format='OGG', subtype='VORBIS') as output:
        for start in range(0, len(stereo_samples), SAMPLE_RATE):
            output.write(stereo_samples[start:start + SAMPLE_RATE])
    decoded, rate = sf.read(path, dtype='float32', always_2d=True)
    assert rate == SAMPLE_RATE and decoded.shape == stereo_samples.shape
    rms = float(np.sqrt(np.mean(decoded**2)))
    assert rms > 0.005 and np.max(np.abs(decoded)) < 0.99
    manifest[name] = {'file': path.name, 'seconds': len(decoded) / rate,
                      'sample_rate': rate, 'rms': rms,
                      'peak': float(np.max(np.abs(decoded))),
                      'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


frames = SAMPLE_RATE * LOOP_SECONDS
time = np.arange(frames) / SAMPLE_RATE
for name, strength, cutoff in [('cool-breeze', 0.32, 900), ('cold-wind', 0.52, 1500)]:
    channels = []
    for channel in range(2):
        gust = 0.6 + 0.22 * np.sin(2 * np.pi * time / 12 + channel * 0.4)
        gust += 0.13 * np.sin(2 * np.pi * time / 8 + 1.3)
        wind = filtered_noise(frames, 45, cutoff) * gust
        wind += filtered_noise(frames, 300, 2600) * (gust**3) * 0.12
        channels.append(wind)
    write_asset(name, np.column_stack(channels), strength)

rain_channels = []
for channel in range(2):
    rain = filtered_noise(frames, 650, 6500) * 0.55
    rain += filtered_noise(frames, 120, 1000) * 0.25
    # Dense small impacts over the continuous rain bed, with a short decay.
    impacts = np.zeros(frames)
    positions = random.integers(0, frames, 3800)
    np.add.at(impacts, positions, random.uniform(0.3, 1.0, len(positions)))
    kernel_time = np.arange(480) / SAMPLE_RATE
    kernel = np.exp(-kernel_time * 260) * np.sin(kernel_time * 2 * np.pi * 1800)
    rain += np.fft.irfft(np.fft.rfft(impacts) * np.fft.rfft(kernel, n=frames), n=frames) * 0.55
    rain_channels.append(rain)
write_asset('rain', np.column_stack(rain_channels), 0.46)

for variant in range(3):
    thunder_frames = SAMPLE_RATE * 8
    thunder_time = np.arange(thunder_frames) / SAMPLE_RATE
    rumble = filtered_noise(thunder_frames, 28, 260 + variant * 35)
    crack = filtered_noise(thunder_frames, 120, 2200) * np.exp(-thunder_time * 7)
    envelope = (1 - np.exp(-thunder_time * 28)) * np.exp(-thunder_time * 0.52)
    envelope *= 0.8 + 0.2 * np.sin(thunder_time * 7 + variant)
    tail_fade = np.clip((8 - thunder_time) / 1.5, 0, 1)
    mono = (rumble * envelope + crack * 0.45) * tail_fade
    delayed = np.concatenate([np.zeros(1700), mono[:-1700]])
    stereo = np.column_stack([mono * 0.9 + delayed * 0.1, mono * 0.7 + delayed * 0.3])
    write_asset('thunder-' + str(variant + 1), stereo, 0.65)

(OUTPUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
for name, details in manifest.items():
    print(name, details['seconds'], 'seconds; RMS', round(details['rms'], 4))
