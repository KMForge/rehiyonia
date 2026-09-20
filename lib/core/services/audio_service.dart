import 'package:audioplayers/audioplayers.dart';

import '../errors/app_exceptions.dart';

class AudioService {
  AudioService({AudioPlayer? musicPlayer, AudioPlayer? sfxPlayer})
    : _musicPlayer = musicPlayer ?? AudioPlayer(),
      _sfxPlayer = sfxPlayer ?? AudioPlayer();

  final AudioPlayer _musicPlayer;
  final AudioPlayer _sfxPlayer;

  bool _isMusicEnabled = true;
  bool _isSoundEffectsEnabled = true;
  double _volume = 1.0;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;
  double get volume => _volume;

  void updatePreferences({
    required bool musicEnabled,
    required bool soundEffectsEnabled,
    double? volume,
  }) {
    _isMusicEnabled = musicEnabled;
    _isSoundEffectsEnabled = soundEffectsEnabled;
    if (volume != null) {
      _volume = volume.clamp(0.0, 1.0);
      _musicPlayer.setVolume(_volume);
      _sfxPlayer.setVolume(_volume);
    }

    if (!_isMusicEnabled) {
      stopMusic();
    }
  }

  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    if (!_isMusicEnabled) return;

    try {
      if (loop) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _musicPlayer.setReleaseMode(ReleaseMode.release);
      }
      await _musicPlayer.setVolume(_volume);
      await _musicPlayer.play(AssetSource(assetPath));
    } on Exception catch (e) {
      throw AudioException('Failed to play music: $assetPath', e);
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } on Exception catch (e) {
      throw AudioException('Failed to pause music', e);
    }
  }

  Future<void> resumeMusic() async {
    if (!_isMusicEnabled) return;
    try {
      await _musicPlayer.resume();
    } on Exception catch (e) {
      throw AudioException('Failed to resume music', e);
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } on Exception catch (e) {
      throw AudioException('Failed to stop music', e);
    }
  }

  Future<void> playSoundEffect(String assetPath) async {
    if (!_isSoundEffectsEnabled) return;

    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.play(AssetSource(assetPath));
    } on Exception {
      // Sound effects fail gracefully to not break gameplay
    }
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
