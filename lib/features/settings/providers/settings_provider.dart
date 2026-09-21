import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/services/audio_service.dart';
import '../../../shared/providers/app_initialization_provider.dart';
import '../models/app_language.dart';
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
    // English is the default language
    Future.microtask(() => _loadSavedPreferences());
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

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
    _persistLanguage(language);
  }

  Future<void> _persistLanguage(AppLanguage language) async {
    try {
      final appDb = ref.read(appDatabaseProvider);
      if (appDb.isOpen) {
        final db = appDb.database;
        await db.insert(DatabaseConstants.tableUserProgress, {
          DatabaseConstants.columnKey: AppConstants.keyLanguage,
          DatabaseConstants.columnValue: language.code,
          DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (_) {
      // Gracefully handle in-memory or headless environments
    }
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final appDb = ref.read(appDatabaseProvider);
      if (appDb.isOpen) {
        final db = appDb.database;
        final results = await db.query(
          DatabaseConstants.tableUserProgress,
          where: '${DatabaseConstants.columnKey} = ?',
          whereArgs: [AppConstants.keyLanguage],
        );
        if (results.isNotEmpty) {
          final code = results.first[DatabaseConstants.columnValue] as String?;
          state = state.copyWith(language: AppLanguage.fromCode(code));
        }
      }
    } catch (_) {}
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
