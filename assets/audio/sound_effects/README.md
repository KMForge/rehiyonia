# Game sound effects

`word_sparkle.wav` is an original 0.8-second ascending bell sparkle synthesized by `tool/generate_spark_sfx.dart`. It uses no external recordings or song samples. It is mono, 44.1 kHz, 16-bit PCM, with a short attack and fade-out to avoid clicks.

The word-search screen plays it when the accepted found-word set gains a word, including the final word. Invalid selections, repeated selections, hints and rebuilds do not trigger it. The existing sound-effects switch and master volume apply. Music and effects use separate players.

The requested "I See the Light" recording has not been bundled: the screenshot identifies the song but does not supply an audio file. A recording approved for use in the game is still needed for that background-music change.
