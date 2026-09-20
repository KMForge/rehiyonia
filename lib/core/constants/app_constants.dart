abstract final class AppConstants {
  static const String appName = 'Rehiyonia';
  static const String appVersion = '1.0.0';

  // Game economy constants
  static const int startingCoins = 50;
  static const int hintCostCoins = 10;
  static const int puzzleRewardCoins = 20;
  static const int triviaRewardCoins = 10;

  // Audio preference default keys
  static const String keySoundEffectsEnabled = 'sfx_enabled';
  static const String keyMusicEnabled = 'music_enabled';
  static const String keyVolume = 'master_volume';

  // Audio asset paths
  static const String audioMusicMainTheme = 'audio/music/main_theme.wav';
  static const String audioSfxButtonClick =
      'audio/sound_effects/button_click.wav';
  static const String audioSfxWordFound = 'audio/sound_effects/word_found.wav';
  static const String audioSfxPuzzleComplete =
      'audio/sound_effects/puzzle_complete.wav';
}
