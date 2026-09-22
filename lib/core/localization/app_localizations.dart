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
  String get avatarStudioButton =>
      isEnglish ? 'Avatar Studio' : 'Studio ng Avatar';
  String get badgeGalleryButton =>
      isEnglish ? 'Badge Gallery' : 'Galerya ng Tsapa';
  String get settingsButton => isEnglish ? 'Settings' : 'Mga Setting';
  String get aboutButton => isEnglish ? 'About Game' : 'Tungkol sa Laro';
  String get aboutTitle =>
      isEnglish ? 'About Rehiyonia' : 'Tungkol sa Rehiyonia';
  String get aboutContent => isEnglish
      ? 'Rehiyonia is an educational word search game designed for Grade 5 Araling Panlipunan, covering all 18 Philippine regions with 100% offline gameplay.'
      : 'Ang Rehiyonia ay isang pang-edukasyong laro ng word search para sa Grade 5 Araling Panlipunan, sumasaklaw sa 18 rehiyon ng Pilipinas nang 100% offline.';
  String get closeButton => isEnglish ? 'Close' : 'Isara';

  // Avatar Studio
  String get avatarStudioTitle =>
      isEnglish ? 'Avatar Studio' : 'Studio ng Avatar';
  String get skinTone => isEnglish ? 'Skin Tone' : 'Kulay ng Balat';
  String get hairStyle => isEnglish ? 'Hair Style' : 'Ayos ng Buhok';
  String get hairColor => isEnglish ? 'Hair Color' : 'Kulay ng Buhok';
  String get outfitColor => isEnglish ? 'Outfit Color' : 'Kulay ng Kasuotan';
  String get accessory => isEnglish ? 'Accessory' : 'Palamuti';
  String get saveAvatar => isEnglish ? 'Save Avatar' : 'I-save ang Avatar';
  String get avatarSaved => isEnglish
      ? 'Avatar updated successfully!'
      : 'Matagumpay na na-update ang avatar!';

  // Badge Gallery
  String get badgeGalleryTitle =>
      isEnglish ? 'Badge Gallery' : 'Galerya ng Tsapa';
  String badgesEarned(int earned, int total) => isEnglish
      ? 'Badges Earned: $earned / $total'
      : 'Mga Tsapang Nakuha: $earned / $total';
  String get lockedBadge => isEnglish ? 'Locked' : 'Naka-lock';
  String get unlockedBadge => isEnglish ? 'Unlocked' : 'Nakuha Na';

  // Island Groups & Regions
  String get selectIslandGroup =>
      isEnglish ? 'Select Island Group' : 'Pumili ng Pangkat ng Pulo';
  String get luzonTitle => 'Luzon';
  String get visayasTitle => isEnglish ? 'Visayas' : 'Kabisayaan';
  String get mindanaoTitle => 'Mindanao';
  String regionsCount(int count) =>
      isEnglish ? '$count Regions' : '$count Rehiyon';
  String get regionsTitle => isEnglish ? 'Select Region' : 'Pumili ng Rehiyon';
  String get selectRegionPrompt => isEnglish
      ? 'Choose a region to begin exploring!'
      : 'Pumili ng rehiyon upang simulan ang pagtuklas!';
  String islandGroup(String group) =>
      isEnglish ? '$group Group' : 'Pangkat ng $group';
  String get retryButton => isEnglish ? 'Retry' : 'Subukan Muli';
  String get errorLoadingRegions => isEnglish
      ? 'Error loading regions'
      : 'May aberya sa pag-load ng mga rehiyon';
  String get regionLockedMessage => isEnglish
      ? 'This region is locked. Complete previous regions first!'
      : 'Naka-lock pa ang rehiyong ito. Tapusin muna ang naunang mga rehiyon!';

  // Region Intro
  String get regionIntroTitle =>
      isEnglish ? 'Region Overview' : 'Pangkalahatang-ideya ng Rehiyon';
  String get culturalHighlights =>
      isEnglish ? 'Cultural Highlights' : 'Mga Kultural na Tampok';
  String get localitiesToExplore =>
      isEnglish ? '15 Localities to Explore' : '15 Lugar na Tutuklasin';
  String get startLearningButton => isEnglish
      ? 'Start Learning (15 Localities)'
      : 'Simulan ang Pag-aaral (15 Lugar)';

  // Locality Cards
  String get localityCardsTitle =>
      isEnglish ? 'Explore Localities' : 'Tuklasin ang mga Lugar';
  String cardProgress(int current, int total) =>
      isEnglish ? 'Locality $current of $total' : 'Lugar $current ng $total';
  String get provinceLabel => isEnglish ? 'Province' : 'Lalawigan';
  String get categoryLabelText => isEnglish ? 'Category' : 'Kategorya';
  String get funFactLabel => isEnglish ? 'Did You Know?' : 'Alam Mo Ba?';
  String get takeTriviaButton =>
      isEnglish ? 'Take Trivia Challenge' : 'Hamon sa Trivia';
  String get previousCard => isEnglish ? 'Previous' : 'Nauna';
  String get nextCard => isEnglish ? 'Next' : 'Susunod';

  // Trivia Challenge
  String get triviaTitle => isEnglish ? 'Regional Trivia' : 'Trivia ng Rehiyon';
  String get triviaChallenge => isEnglish
      ? '🎓 Regional Trivia Challenge'
      : '🎓 Hamon sa Kaalaman ng Rehiyon';
  String questionProgress(int current, int total) =>
      isEnglish ? 'Question $current of $total' : 'Tanong $current ng $total';
  String get selectAnswer => isEnglish
      ? 'Select the correct answer to earn bonus coins:'
      : 'Piliin ang tamang sagot para sa dagdag na barya:';
  String get correctAnswer => isEnglish
      ? '🎉 Correct! Outstanding knowledge!'
      : '🎉 Tama! Napakahusay na kaalaman!';
  String get incorrectAnswer => isEnglish
      ? 'Nice try! The correct answer is:'
      : 'Muntik na! Ang tamang sagot ay:';
  String get triviaBonus =>
      isEnglish ? '+10 Bonus Coins' : '+10 Dagdag na Barya';
  String get startWordSearchButton =>
      isEnglish ? 'Start Word Search ➔' : 'Simulan ang Word Search ➔';

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

  // Player Account & Profile
  String get accountSection =>
      isEnglish ? 'Player Account' : 'Account ng Manlalaro';
  String get customizeName =>
      isEnglish ? 'Customize Player Name' : 'Baguhin ang Pangalan';
  String get enterNameHint =>
      isEnglish ? 'Enter player name' : 'Ilagay ang pangalan';
  String get saveButton => isEnglish ? 'Save' : 'I-save';
  String get cancelButton => isEnglish ? 'Cancel' : 'Kanselahin';
  String get nameUpdatedMessage => isEnglish
      ? 'Player name updated successfully!'
      : 'Matagumpay na nabago ang pangalan!';

  // Gameplay Screen
  String foundCount(int found, int total) =>
      isEnglish ? 'Found: $found / $total' : 'Nahanap: $found / $total';
  String get hintButton => 'Hint (-10 🪙)';
  String get errorTitle => isEnglish ? 'Error' : 'Aberya';
  String get noPuzzleError =>
      isEnglish ? 'No puzzle could be generated.' : 'Walang puzzle na mabuo.';
  String get congratulations =>
      isEnglish ? '🎉 Level Complete!' : '🎉 Tapos na ang Antas!';
  String completedMessage(String regionName) => isEnglish
      ? 'You found all words in $regionName!'
      : 'Nahanap mo ang lahat ng salita sa $regionName!';
  String rewardCoins(int coins, int total) => isEnglish
      ? '+$coins Coins (Total: $total)'
      : '+$coins Barya (Kabuuan: $total)';
  String get readTrivia => isEnglish ? 'Read Trivia' : 'Basahin ang Trivia';
  String get continueButton => isEnglish ? 'Continue' : 'Magpatuloy';
  String get understoodButton => isEnglish ? 'Got it!' : 'Naintindihan ko!';
  String get nextLevelButton =>
      isEnglish ? 'Next Level ➔' : 'Susunod na Antas ➔';
  String get allRegionsCompleted => isEnglish
      ? '🏆 All 18 Regions Completed!'
      : '🏆 Natapos ang Lahat ng 18 Rehiyon!';
  String get allRegionsCompletedMessage => isEnglish
      ? 'You are now a true master of Philippine geography and culture!'
      : 'Isa ka nang tunay na dalubhasa sa heograpiya at kultura ng Pilipinas!';
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
