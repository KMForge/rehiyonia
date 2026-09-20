import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/services/audio_service.dart';

class MockAudioPlayer extends Fake implements AudioPlayer {
  bool isStopped = false;
  double _volume = 1.0;
  ReleaseMode _releaseMode = ReleaseMode.release;

  @override
  double get volume => _volume;

  @override
  ReleaseMode get releaseMode => _releaseMode;

  @override
  Future<void> setVolume(double value) async {
    _volume = value;
  }

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    _releaseMode = mode;
  }

  @override
  Future<void> stop() async {
    isStopped = true;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('AudioService Tests', () {
    late MockAudioPlayer mockMusicPlayer;
    late MockAudioPlayer mockSfxPlayer;
    late AudioService audioService;

    setUp(() {
      mockMusicPlayer = MockAudioPlayer();
      mockSfxPlayer = MockAudioPlayer();
      audioService = AudioService(
        musicPlayer: mockMusicPlayer,
        sfxPlayer: mockSfxPlayer,
      );
    });

    test('initial values are enabled with full volume', () {
      expect(audioService.isMusicEnabled, isTrue);
      expect(audioService.isSoundEffectsEnabled, isTrue);
      expect(audioService.volume, 1.0);
    });

    test('updatePreferences updates values and clamps volume', () {
      audioService.updatePreferences(
        musicEnabled: false,
        soundEffectsEnabled: true,
        volume: 1.5, // Should clamp to 1.0
      );

      expect(audioService.isMusicEnabled, isFalse);
      expect(audioService.isSoundEffectsEnabled, isTrue);
      expect(audioService.volume, 1.0);
      expect(mockMusicPlayer.volume, 1.0);
      expect(
        mockMusicPlayer.isStopped,
        isTrue,
      ); // Disabling music stops music player
    });

    test('stopping music calls stop on music player', () async {
      await audioService.stopMusic();
      expect(mockMusicPlayer.isStopped, isTrue);
    });
  });
}
