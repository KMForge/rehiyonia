import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/services/audio_service.dart';

class MockAudioPlayer extends Fake implements AudioPlayer {
  bool isStopped = false;
  int plays = 0, pauses = 0, resumes = 0;
  Source? lastSource;
  AudioContext? lastContext;
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    plays++;
    lastSource = source;
    lastContext = ctx;
  }

  @override
  Future<void> pause() async {
    pauses++;
  }

  @override
  Future<void> resume() async {
    resumes++;
  }

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

    test(
      'word sparkle mixes without pausing or stealing music focus',
      () async {
        await audioService.setBackgroundMusic('music.ogg', active: true);
        await audioService.playSoundEffect('sparkle.wav');
        expect(
          mockSfxPlayer.lastContext!.android.audioFocus,
          AndroidAudioFocus.none,
        );
        expect(
          mockSfxPlayer.lastContext!.iOS.options,
          contains(AVAudioSessionOptions.mixWithOthers),
        );
        expect(mockMusicPlayer.pauses, 0);
        expect(mockMusicPlayer.isStopped, isFalse);
        expect(mockMusicPlayer.plays, 1);
        expect(mockSfxPlayer.plays, 1);
        await audioService.dispose();
      },
    );

    test('background loop survives navigation and resumes after background or mute', () async {
      const asset = 'audio/music/instrumental_loop.ogg';
      await audioService.setBackgroundMusic(asset, active: true);
      await audioService.setBackgroundMusic(asset, active: true);
      expect(mockMusicPlayer.plays, 1);
      expect((mockMusicPlayer.lastSource as AssetSource).path, asset);
      expect(mockMusicPlayer.releaseMode, ReleaseMode.loop);
      await audioService.setBackgroundMusic(asset, active: false);
      expect(mockMusicPlayer.pauses, 1);
      await audioService.setBackgroundMusic(asset, active: true);
      expect(mockMusicPlayer.resumes, 1);
      audioService.updatePreferences(
        musicEnabled: false,
        soundEffectsEnabled: true,
      );
      await audioService.setBackgroundMusic(asset, active: true);
      expect(mockMusicPlayer.pauses, 2);
      audioService.updatePreferences(
        musicEnabled: true,
        soundEffectsEnabled: true,
      );
      await audioService.setBackgroundMusic(asset, active: true);
      expect(mockMusicPlayer.resumes, 2);
      expect(mockMusicPlayer.plays, 1);
      await audioService.dispose();
    });

    test(
      'disabled music does not start until enabled while foregrounded',
      () async {
        audioService.updatePreferences(
          musicEnabled: false,
          soundEffectsEnabled: true,
        );
        await audioService.setBackgroundMusic('music.mp3', active: true);
        expect(mockMusicPlayer.plays, 0);
        audioService.updatePreferences(
          musicEnabled: true,
          soundEffectsEnabled: true,
        );
        await audioService.setBackgroundMusic('music.mp3', active: false);
        expect(mockMusicPlayer.plays, 0);
        await audioService.setBackgroundMusic('music.mp3', active: true);
        expect(mockMusicPlayer.plays, 1);
        await audioService.dispose();
      },
    );

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
