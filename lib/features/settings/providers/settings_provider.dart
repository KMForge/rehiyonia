import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_service.dart';
import '../models/audio_preferences.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class SettingsNotifier extends Notifier<AudioPreferences> {
  @override
  AudioPreferences build() {
    return const AudioPreferences();
  }

  void toggleMusic() {
    state = state.copyWith(isMusicEnabled: !state.isMusicEnabled);
    _syncAudioService();
  }

  void toggleSoundEffects() {
    state = state.copyWith(isSoundEffectsEnabled: !state.isSoundEffectsEnabled);
    _syncAudioService();
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
    _syncAudioService();
  }

  void _syncAudioService() {
    ref
        .read(audioServiceProvider)
        .updatePreferences(
          musicEnabled: state.isMusicEnabled,
          soundEffectsEnabled: state.isSoundEffectsEnabled,
          volume: state.volume,
        );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AudioPreferences>(
  SettingsNotifier.new,
);
