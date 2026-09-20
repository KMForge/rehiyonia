class AudioPreferences {
  const AudioPreferences({
    this.isMusicEnabled = true,
    this.isSoundEffectsEnabled = true,
    this.volume = 1.0,
  });

  final bool isMusicEnabled;
  final bool isSoundEffectsEnabled;
  final double volume;

  AudioPreferences copyWith({
    bool? isMusicEnabled,
    bool? isSoundEffectsEnabled,
    double? volume,
  }) {
    return AudioPreferences(
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSoundEffectsEnabled:
          isSoundEffectsEnabled ?? this.isSoundEffectsEnabled,
      volume: volume ?? this.volume,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPreferences &&
          runtimeType == other.runtimeType &&
          isMusicEnabled == other.isMusicEnabled &&
          isSoundEffectsEnabled == other.isSoundEffectsEnabled &&
          volume == other.volume;

  @override
  int get hashCode =>
      isMusicEnabled.hashCode ^
      isSoundEffectsEnabled.hashCode ^
      volume.hashCode;
}
