import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';

import '../../core/services/audio_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider Tests', () {
    late AudioService mockAudioService;

    setUp(() {
      mockAudioService = AudioService(
        musicPlayer: MockAudioPlayer(),
        sfxPlayer: MockAudioPlayer(),
      );
    });

    test('default preferences have sound and music enabled at volume 1.0', () {
      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudioService)],
      );
      addTearDown(container.dispose);

      final state = container.read(settingsProvider);
      expect(state.isMusicEnabled, isTrue);
      expect(state.isSoundEffectsEnabled, isTrue);
      expect(state.volume, 1.0);
    });

    test('toggleMusic flips music enabled state', () {
      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudioService)],
      );
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).toggleMusic();
      expect(container.read(settingsProvider).isMusicEnabled, isFalse);

      container.read(settingsProvider.notifier).toggleMusic();
      expect(container.read(settingsProvider).isMusicEnabled, isTrue);
    });

    test('toggleSoundEffects flips sound effects enabled state', () {
      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudioService)],
      );
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).toggleSoundEffects();
      expect(container.read(settingsProvider).isSoundEffectsEnabled, isFalse);

      container.read(settingsProvider.notifier).toggleSoundEffects();
      expect(container.read(settingsProvider).isSoundEffectsEnabled, isTrue);
    });

    test('setVolume updates volume state clamped to 0.0-1.0', () {
      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudioService)],
      );
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setVolume(0.5);
      expect(container.read(settingsProvider).volume, 0.5);

      container.read(settingsProvider.notifier).setVolume(2.0);
      expect(container.read(settingsProvider).volume, 1.0);

      container.read(settingsProvider.notifier).setVolume(-0.5);
      expect(container.read(settingsProvider).volume, 0.0);
    });
  });
}
