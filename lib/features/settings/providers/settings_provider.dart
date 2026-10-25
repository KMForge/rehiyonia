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

  Future<void> loadSavedPreferences() async {
    try {
      final appDb = ref.read(appDatabaseProvider);
      if (appDb.isOpen) {
        final db = appDb.database;
        final results = await db.query(DatabaseConstants.tableUserProgress);
        for (final row in results) {
          if (row[DatabaseConstants.columnKey] == AppConstants.keyLanguage) {
            state = state.copyWith(
              language: AppLanguage.fromCode(
                row[DatabaseConstants.columnValue] as String?,
              ),
            );
          } else if (row[DatabaseConstants.columnKey] == 'reduce_motion') {
            state = state.copyWith(
              reduceMotion: row[DatabaseConstants.columnValue] == 'true',
            );
          }
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

  Future<void> setReduceMotion(bool enabled) async {
    final db = ref.read(appDatabaseProvider);
    if (db.isOpen) {
      await db.database.insert(DatabaseConstants.tableUserProgress, {
        DatabaseConstants.columnKey: 'reduce_motion',
        DatabaseConstants.columnValue: enabled.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    state = state.copyWith(reduceMotion: enabled);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AudioPreferences>(
  SettingsNotifier.new,
);
