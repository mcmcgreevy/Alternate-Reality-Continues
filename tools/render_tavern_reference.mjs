// Render local ASMA references with its upstream ASAP engine (not game assets).
// Obtain the engine and SAP files as documented in docs/TAVERN_MUSIC_RESEARCH.md.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const ref = path.join(root, 'tools/reference/tavern-music');
const { ASAP, ASAPSampleFormat } = await import(pathToFileURL(path.join(ref, 'asap-with-asapwriter.mjs')));
for (const suffix of ['Dan', 'Dra']) {
  const filename = `Alternate_Reality_City_${suffix}.sap`;
  const input = fs.readFileSync(path.join(ref, filename));
  const player = new ASAP();
  player.load(filename, input, input.length);
  player.playSong(0, 30000);
  const header = new Uint8Array(4096);
  const headerSize = player.getWavHeader(header, ASAPSampleFormat.S16_L_E, true);
  const chunks = [Buffer.from(header.subarray(0, headerSize))];
  const buffer = new Uint8Array(65536);
  for (;;) {
    const count = player.generate(buffer, buffer.length, ASAPSampleFormat.S16_L_E);
    if (!count) break;
    chunks.push(Buffer.from(buffer.subarray(0, count)));
  }
  const output = path.join(ref, `atari-tavern-${suffix.toLowerCase()}-reference-30s.wav`);
  fs.writeFileSync(output, Buffer.concat(chunks));
  console.log(output);
}
