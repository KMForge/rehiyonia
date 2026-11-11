"""Build a gapless loop from a supplied recording (numpy/scipy/imageio-ffmpeg)."""
import argparse
import json
import subprocess
from pathlib import Path

import imageio_ffmpeg
import numpy as np
from scipy.signal import stft

parser = argparse.ArgumentParser()
parser.add_argument('source', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
rate = 22050
raw = subprocess.check_output([
    ffmpeg, '-v', 'error', '-i', str(args.source), '-f', 'f32le',
    '-acodec', 'pcm_f32le', '-ar', str(rate), '-ac', '2', 'pipe:1',
])
samples = np.frombuffer(raw, dtype='<f4').reshape(-1, 2).copy()
start = 93.0
# Compare four-second harmonic sequences to find a later matching phrase.
freqs, times, spectrum = stft(samples.mean(axis=1), fs=rate, nperseg=2048, noverlap=1536)
power = np.abs(spectrum)
valid = (freqs >= 80) & (freqs <= 4000)
pitch = np.rint(69 + 12 * np.log2(freqs[valid] / 440)).astype(int) % 12
chroma = np.zeros((12, len(times)))
for note in range(12):
    chroma[note] = power[valid][pitch == note].sum(axis=0)
chroma /= np.maximum(np.linalg.norm(chroma, axis=0), 1e-10)
hop = times[1] - times[0]
begin = int(round(start / hop))
window = int(round(4 / hop))
reference = chroma[:, begin:begin + window]
candidates = []
for index in range(int((start + 30) / hop), min(int((start + 95) / hop), len(times) - window)):
    score = float((reference * chroma[:, index:index + window]).sum(axis=0).mean())
    candidates.append((score, index))
score, index = max(candidates)
end = float(times[index])
segment = samples[round(start * rate):round(end * rate)].copy()
# Fade the final 180 ms into the audio immediately preceding the loop start.
# The next decoder sample is therefore the continuation at exactly 1:33.
fade = round(0.18 * rate)
preceding = samples[round(start * rate) - fade:round(start * rate)]
weight = np.linspace(0, 1, fade, dtype=np.float32)[:, None]
segment[-fade:] = segment[-fade:] * (1 - weight) + preceding * weight
peak = float(np.max(np.abs(segment)))
if peak > 0.97:
    segment *= 0.97 / peak
args.output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run([
    ffmpeg, '-v', 'error', '-y', '-f', 'f32le', '-ar', str(rate), '-ac', '2',
    '-i', 'pipe:0', '-c:a', 'libvorbis', '-q:a', '6',
    '-metadata', 'title=I See the Light - instrumental gameplay loop', str(args.output),
], input=segment.astype('<f4').tobytes(), check=True)
report = {'start_seconds': start, 'end_seconds': round(end, 3),
          'loop_seconds': round(len(segment) / rate, 3),
          'crossfade_seconds': 0.18, 'harmonic_similarity': round(score, 4),
          'source': args.source.name, 'output': args.output.name}
args.output.with_suffix('.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps(report, indent=2))
