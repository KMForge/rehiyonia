import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/models/app_language.dart';
import '../../features/settings/providers/settings_provider.dart';

class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  bool get isEnglish => language == AppLanguage.english;

  // App & Navigation
  String get appName => 'Rehiyonia';
  String get subtitle => isEnglish
      ? 'Philippine Regional Word Search'
      : 'Paghahanap ng Salita sa mga Rehiyon';
  String get curriculumTag => 'Araling Panlipunan • Grade 5';

  // Stats
  String coins(int count) => isEnglish ? '$count Coins' : '$count Barya';
  String stars(int count) => isEnglish ? '$count Stars' : '$count Bituin';

  // Home Menu
  String get playButton => isEnglish ? 'PLAY' : 'MAGLARO';
  String get settingsButton => isEnglish ? 'Settings' : 'Mga Setting';
  String get aboutButton => isEnglish ? 'About Game' : 'Tungkol sa Laro';
  String get aboutTitle =>
      isEnglish ? 'About Rehiyonia' : 'Tungkol sa Rehiyonia';
  String get aboutContent => isEnglish
      ? 'Rehiyonia is an educational word search game designed for Grade 5 Araling Panlipunan, covering all 18 Philippine regions with 100% offline gameplay.'
      : 'Ang Rehiyonia ay isang pang-edukasyong laro ng word search para sa Grade 5 Araling Panlipunan, sumasaklaw sa 18 rehiyon ng Pilipinas nang 100% offline.';
  String get closeButton => isEnglish ? 'Close' : 'Isara';

  // Settings Screen
  String get settingsTitle => isEnglish ? 'Settings' : 'Mga Setting';
  String get languageSection => isEnglish ? 'Language' : 'Wika';
  String get languageSubtitle =>
      isEnglish ? 'Select game language' : 'Piliin ang wika ng laro';
  String get audioSection => isEnglish ? 'Audio & Music' : 'Tunog at Musika';
  String get musicTitle =>
      isEnglish ? 'Background Music' : 'Musika sa Background';
  String get musicSubtitle => isEnglish
      ? 'Play uplifting background music while playing'
      : 'I-play ang pampasiglang tugtugin habang naglalaro';
  String get sfxTitle => isEnglish ? 'Sound Effects' : 'Mga Tunog ng Laro';
  String get sfxSubtitle => isEnglish
      ? 'Sound on word selection and interaction'
      : 'Tunog sa pagpili ng salita at pagpindot';
  String get volumeTitle => isEnglish ? 'Volume' : 'Lakas ng Tunog';

  // Regions Screen
  String get regionsTitle => isEnglish ? 'Select Region' : 'Pumili ng Rehiyon';
  String islandGroup(String group) =>
      isEnglish ? '$group Group' : 'Pangkat ng $group';
  String get retryButton => isEnglish ? 'Retry' : 'Subukan Muli';
  String get errorLoadingRegions => isEnglish
      ? 'Error loading regions'
      : 'May aberya sa pag-load ng mga rehiyon';
  String get regionLockedMessage => isEnglish
      ? 'This region is locked. Complete previous regions first!'
      : 'Naka-lock pa ang rehiyong ito. Tapusin muna ang naunang mga rehiyon!';

  // Gameplay Screen
  String foundCount(int found, int total) =>
      isEnglish ? 'Found: $found / $total' : 'Nahanap: $found / $total';
  String get hintButton => isEnglish ? 'Hint (-10 🪙)' : 'Hint (-10 🪙)';
  String get errorTitle => isEnglish ? 'Error' : 'Aberya';
  String get noPuzzleError =>
      isEnglish ? 'No puzzle could be generated.' : 'Walang puzzle na mabuo.';
  String get congratulations =>
      isEnglish ? '🎉 Congratulations!' : '🎉 Maligayang Bati!';
  String completedMessage(String regionName) => isEnglish
      ? 'You found all words in $regionName!'
      : 'Nahanap mo ang lahat ng salita sa $regionName!';
  String rewardCoins(int coins, int total) => isEnglish
      ? '+$coins Coins (Total: $total)'
      : '+$coins Barya (Kabuuan: $total)';
  String get readTrivia => isEnglish ? 'Read Trivia' : 'Basahin ang Trivia';
  String get continueButton => isEnglish ? 'Continue' : 'Magpatuloy';
  String get understoodButton => isEnglish ? 'Got it!' : 'Naintindihan ko!';
  String get triviaTitle => isEnglish ? 'Regional Trivia' : 'Trivia ng Rehiyon';
  String get funFactTitle => isEnglish ? 'Did you know?' : 'Alam Mo Ba?';
  String get noTriviaAvailable =>
      isEnglish ? 'No trivia available.' : 'Walang makuhang trivia.';

  String categoryLabel(String category) {
    if (!isEnglish) return category;
    switch (category.toLowerCase()) {
      case 'lungsod':
        return 'City';
      case 'bayan':
        return 'Municipality';
      case 'lalawigan':
        return 'Province';
      case 'bulkan':
        return 'Volcano';
      case 'pista':
        return 'Festival';
      case 'isla':
        return 'Island';
      default:
        return category;
    }
  }
}

final localizationsProvider = Provider<AppLocalizations>((ref) {
  final settings = ref.watch(settingsProvider);
  return AppLocalizations(settings.language);
});
