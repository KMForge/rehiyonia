import 'app_language.dart';

class AudioPreferences {
  const AudioPreferences({
    this.isMusicEnabled = true,
    this.isSoundEffectsEnabled = true,
    this.volume = 1.0,
    this.language = AppLanguage.english,
    this.reduceMotion = false,
  });

  final bool isMusicEnabled;
  final bool isSoundEffectsEnabled;
  final double volume;
  final AppLanguage language;
  final bool reduceMotion;

  AudioPreferences copyWith({
    bool? isMusicEnabled,
    bool? isSoundEffectsEnabled,
    double? volume,
    AppLanguage? language,
    bool? reduceMotion,
  }) {
    return AudioPreferences(
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSoundEffectsEnabled:
          isSoundEffectsEnabled ?? this.isSoundEffectsEnabled,
      volume: volume ?? this.volume,
      language: language ?? this.language,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPreferences &&
          runtimeType == other.runtimeType &&
          isMusicEnabled == other.isMusicEnabled &&
          isSoundEffectsEnabled == other.isSoundEffectsEnabled &&
          volume == other.volume &&
          language == other.language &&
          reduceMotion == other.reduceMotion;

  @override
  int get hashCode =>
      isMusicEnabled.hashCode ^
      isSoundEffectsEnabled.hashCode ^
      volume.hashCode ^
      language.hashCode ^
      reduceMotion.hashCode;
}
