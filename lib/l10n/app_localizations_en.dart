// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Rehiyonia';

  @override
  String get subtitle => 'Philippine Regional Word Search';

  @override
  String get curriculumTag => 'Araling Panlipunan • Grade 5';

  @override
  String coins(int count) {
    return '$count Coins';
  }

  @override
  String stars(int count) {
    return '$count Stars';
  }

  @override
  String get playButton => 'PLAY';

  @override
  String get avatarStudioButton => 'Avatar Studio';

  @override
  String get badgeGalleryButton => 'Badge Gallery';

  @override
  String get settingsButton => 'Settings';

  @override
  String get aboutButton => 'About Game';

  @override
  String get aboutTitle => 'About Rehiyonia';

  @override
  String get aboutContent =>
      'Rehiyonia is an offline educational word search game designed for Grade 5 Araling Panlipunan, covering all 18 Philippine regions with 100% offline gameplay.';

  @override
  String get closeButton => 'Close';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSection => 'Language';

  @override
  String get languageSubtitle => 'Select game language';

  @override
  String get accountSection => 'Player Account';

  @override
  String get customizeName => 'Customize Player Name';

  @override
  String get enterNameHint => 'Enter player name';

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get nameUpdatedMessage => 'Player name updated successfully!';

  @override
  String get avatarStudioTitle => 'Avatar Studio';

  @override
  String get skinTone => 'Skin Tone';

  @override
  String get hairStyle => 'Hair Style';

  @override
  String get hairColor => 'Hair Color';

  @override
  String get outfitColor => 'Outfit Color';

  @override
  String get accessory => 'Accessory';

  @override
  String get saveAvatar => 'Save Avatar';

  @override
  String get avatarSaved => 'Avatar updated successfully!';

  @override
  String get badgeGalleryTitle => 'Badge Gallery';

  @override
  String badgesEarned(int earned, int total) {
    return 'Badges Earned: $earned / $total';
  }

  @override
  String get lockedBadge => 'Locked';

  @override
  String get unlockedBadge => 'Unlocked';

  @override
  String get selectIslandGroup => 'Select Island Group';

  @override
  String get luzonTitle => 'Luzon';

  @override
  String get visayasTitle => 'Visayas';

  @override
  String get mindanaoTitle => 'Mindanao';

  @override
  String regionsCount(int count) {
    return '$count Regions';
  }

  @override
  String get regionsTitle => 'Select Region';

  @override
  String get selectRegionPrompt => 'Choose a region to begin exploring!';

  @override
  String islandGroup(String group) {
    return '$group Group';
  }

  @override
  String get retryButton => 'Retry';

  @override
  String get errorLoadingRegions => 'Error loading regions';

  @override
  String get regionLockedMessage =>
      'This region is locked. Complete previous regions first!';

  @override
  String get regionIntroTitle => 'Region Overview';

  @override
  String get culturalHighlights => 'Cultural Highlights';

  @override
  String get localitiesToExplore => '15 Localities to Explore';

  @override
  String get startLearningButton => 'Start Learning (15 Localities)';

  @override
  String get localityCardsTitle => 'Explore Localities';

  @override
  String cardProgress(int current, int total) {
    return 'Locality $current of $total';
  }

  @override
  String get provinceLabel => 'Province';

  @override
  String get categoryLabel => 'Category';

  @override
  String get funFactLabel => 'Did You Know?';

  @override
  String get takeTriviaButton => 'Take Trivia Challenge';

  @override
  String get previousCard => 'Previous';

  @override
  String get nextCard => 'Next';

  @override
  String get triviaTitle => 'Regional Trivia';

  @override
  String get triviaChallenge => '🎓 Regional Trivia Challenge';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get selectAnswer => 'Select the correct answer to earn bonus coins:';

  @override
  String get correctAnswer => '🎉 Correct! Outstanding knowledge!';

  @override
  String get incorrectAnswer => 'Nice try! The correct answer is:';

  @override
  String get triviaBonus => '+10 Bonus Coins';

  @override
  String get startWordSearchButton => 'Start Word Search ➔';

  @override
  String foundCount(int found, int total) {
    return 'Found: $found / $total';
  }

  @override
  String get hintButton => 'Hint (-10 🪙)';

  @override
  String get errorTitle => 'Error';

  @override
  String get noPuzzleError => 'No puzzle could be generated.';

  @override
  String get congratulations => '🎉 Level Complete!';

  @override
  String completedMessage(String regionName) {
    return 'You found all words in $regionName!';
  }

  @override
  String rewardCoins(int coins, int total) {
    return '+$coins Coins (Total: $total)';
  }

  @override
  String get readTrivia => 'Read Trivia';

  @override
  String get continueButton => 'Continue';

  @override
  String get understoodButton => 'Got it!';

  @override
  String get nextLevelButton => 'Next Level ➔';

  @override
  String get allRegionsCompleted => '🏆 All 18 Regions Completed!';

  @override
  String get allRegionsCompletedMessage =>
      'You are now a true master of Philippine geography and culture!';

  @override
  String get funFactTitle => 'Did you know?';

  @override
  String get noTriviaAvailable => 'No trivia available.';

  @override
  String get audioSection => 'Audio & Music';

  @override
  String get musicTitle => 'Background Music';

  @override
  String get musicSubtitle => 'Play uplifting background music while playing';

  @override
  String get sfxTitle => 'Sound Effects';

  @override
  String get sfxSubtitle => 'Sound on word selection and interaction';

  @override
  String get volumeTitle => 'Volume';
}
