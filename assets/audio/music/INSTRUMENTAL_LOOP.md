# Instrumental gameplay loop

Source: user-supplied `I See the Light (From Tangled ) • Instrumental.mp3`.

- Start: 1:33.000.
- Selected end: 2:47.834.
- Loop duration: 74.834 seconds.
- Last 180 ms crossfades into the source audio immediately preceding 1:33, smoothing the wrap back to the first sample.
- Endpoint selected by comparing four-second harmonic sequences with the opening. Final musical preference should be checked by listening on the device.
- Ogg Vorbis avoids MP3 encoder-padding gaps. The player repeats the same asset and pauses/resumes with app lifecycle and the music toggle.
- `pubspec.yaml` bundles only `instrumental_loop.ogg`; the previous vocal MP3 is excluded from the APK.
- Startup, Avatar Studio and word search share one playback session. Home, menus and other screens pause music; returning to an enabled screen resumes it. App backgrounding also pauses it.
- Sparkle effects use no Android audio-focus request and a mixing iOS session, so they do not interrupt background music.

Recreate with Python, numpy, scipy and imageio-ffmpeg:

```powershell
python tool/create_instrumental_loop.py 'path/to/instrumental.mp3' assets/audio/music/instrumental_loop.ogg
```

Timing metadata is stored in `instrumental_loop.json` and is not bundled.
