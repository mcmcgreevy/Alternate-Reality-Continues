"""Preserve user WAV masters and encode matched game streams in bounded blocks."""
from pathlib import Path
import hashlib
import json
import shutil
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path.home() / 'Downloads'
OUT = ROOT / 'assets/audio/hail-and-welcome'
MASTERS = ROOT / 'tools/reference/hail-and-welcome-masters'
OUT.mkdir(parents=True, exist_ok=True)
MASTERS.mkdir(parents=True, exist_ok=True)
report = {}
for filename, slug in [('Alternate Reality The City tavern song Hail and Welcome.wav','full'),
                       ('Alternate Reality The City tavern song Hail and Welcome (Without Lead Vocal).wav','instrumental'),
                       ('Alternate Reality The City tavern song Hail and Welcome (Lead Vocal).wav','vocal')]:
    source = SOURCE / filename
    shutil.copy2(source, MASTERS / filename)
    with sf.SoundFile(source) as src:
        with sf.SoundFile(OUT / (slug+'.ogg'), 'w', samplerate=src.samplerate,
                          channels=src.channels, format='OGG', subtype='VORBIS') as dst:
            for block in src.blocks(blocksize=48000, dtype='float32'):
                dst.write(block)
        info = sf.info(OUT / (slug+'.ogg'))
        assert (info.frames, info.samplerate, info.channels) == (len(src), src.samplerate, src.channels)
        report[slug] = {'source_filename': filename,
                        'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                        'game_asset_sha256': hashlib.sha256((OUT / (slug+'.ogg')).read_bytes()).hexdigest(),
                        'sample_rate': src.samplerate, 'frames': len(src),
                        'channels': src.channels, 'seconds': len(src)/src.samplerate,
                        'game_asset': f'assets/audio/hail-and-welcome/{slug}.ogg'}
    print(slug, info.duration, flush=True)
assert len({(x['frames'], x['sample_rate']) for x in report.values()}) == 1
(ROOT/'data/music/hail-and-welcome/production-audio.json').write_text(json.dumps(report,indent=2)+'\n')
