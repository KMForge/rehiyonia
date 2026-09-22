// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appName => 'Rehiyonia';

  @override
  String get subtitle => 'Paghahanap ng Salita sa mga Rehiyon';

  @override
  String get curriculumTag => 'Araling Panlipunan • Grade 5';

  @override
  String coins(int count) {
    return '$count Barya';
  }

  @override
  String stars(int count) {
    return '$count Bituin';
  }

  @override
  String get playButton => 'MAGLARO';

  @override
  String get avatarStudioButton => 'Studio ng Avatar';

  @override
  String get badgeGalleryButton => 'Galerya ng Tsapa';

  @override
  String get settingsButton => 'Mga Setting';

  @override
  String get aboutButton => 'Tungkol sa Laro';

  @override
  String get aboutTitle => 'Tungkol sa Rehiyonia';

  @override
  String get aboutContent =>
      'Ang Rehiyonia ay isang pang-edukasyong laro ng word search para sa Grade 5 Araling Panlipunan, sumasaklaw sa 18 rehiyon ng Pilipinas nang 100% offline.';

  @override
  String get closeButton => 'Isara';

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String get languageSection => 'Wika';

  @override
  String get languageSubtitle => 'Piliin ang wika ng laro';

  @override
  String get accountSection => 'Account ng Manlalaro';

  @override
  String get customizeName => 'Baguhin ang Pangalan';

  @override
  String get enterNameHint => 'Ilagay ang pangalan';

  @override
  String get saveButton => 'I-save';

  @override
  String get cancelButton => 'Kanselahin';

  @override
  String get nameUpdatedMessage => 'Matagumpay na nabago ang pangalan!';

  @override
  String get avatarStudioTitle => 'Studio ng Avatar';

  @override
  String get skinTone => 'Kulay ng Balat';

  @override
  String get hairStyle => 'Ayos ng Buhok';

  @override
  String get hairColor => 'Kulay ng Buhok';

  @override
  String get outfitColor => 'Kulay ng Kasuotan';

  @override
  String get accessory => 'Palamuti';

  @override
  String get saveAvatar => 'I-save ang Avatar';

  @override
  String get avatarSaved => 'Matagumpay na na-update ang avatar!';

  @override
  String get badgeGalleryTitle => 'Galerya ng Tsapa';

  @override
  String badgesEarned(int earned, int total) {
    return 'Mga Tsapang Nakuha: $earned / $total';
  }

  @override
  String get lockedBadge => 'Naka-lock';

  @override
  String get unlockedBadge => 'Nakuha Na';

  @override
  String get selectIslandGroup => 'Pumili ng Pangkat ng Pulo';

  @override
  String get luzonTitle => 'Luzon';

  @override
  String get visayasTitle => 'Kabisayaan';

  @override
  String get mindanaoTitle => 'Mindanao';

  @override
  String regionsCount(int count) {
    return '$count Rehiyon';
  }

  @override
  String get regionsTitle => 'Pumili ng Rehiyon';

  @override
  String get selectRegionPrompt =>
      'Pumili ng rehiyon upang simulan ang pagtuklas!';

  @override
  String islandGroup(String group) {
    return 'Pangkat ng $group';
  }

  @override
  String get retryButton => 'Subukan Muli';

  @override
  String get errorLoadingRegions => 'May aberya sa pag-load ng mga rehiyon';

  @override
  String get regionLockedMessage =>
      'Naka-lock pa ang rehiyong ito. Tapusin muna ang naunang mga rehiyon!';

  @override
  String get regionIntroTitle => 'Pangkalahatang-ideya ng Rehiyon';

  @override
  String get culturalHighlights => 'Mga Kultural na Tampok';

  @override
  String get localitiesToExplore => '15 Lugar na Tutuklasin';

  @override
  String get startLearningButton => 'Simulan ang Pag-aaral (15 Lugar)';

  @override
  String get localityCardsTitle => 'Tuklasin ang mga Lugar';

  @override
  String cardProgress(int current, int total) {
    return 'Lugar $current ng $total';
  }

  @override
  String get provinceLabel => 'Lalawigan';

  @override
  String get categoryLabel => 'Kategorya';

  @override
  String get funFactLabel => 'Alam Mo Ba?';

  @override
  String get takeTriviaButton => 'Hamon sa Trivia';

  @override
  String get previousCard => 'Nauna';

  @override
  String get nextCard => 'Susunod';

  @override
  String get triviaTitle => 'Trivia ng Rehiyon';

  @override
  String get triviaChallenge => '🎓 Hamon sa Kaalaman ng Rehiyon';

  @override
  String questionProgress(int current, int total) {
    return 'Tanong $current ng $total';
  }

  @override
  String get selectAnswer => 'Piliin ang tamang sagot para sa dagdag na barya:';

  @override
  String get correctAnswer => '🎉 Tama! Napakahusay na kaalaman!';

  @override
  String get incorrectAnswer => 'Muntik na! Ang tamang sagot ay:';

  @override
  String get triviaBonus => '+10 Dagdag na Barya';

  @override
  String get startWordSearchButton => 'Simulan ang Word Search ➔';

  @override
  String foundCount(int found, int total) {
    return 'Nahanap: $found / $total';
  }

  @override
  String get hintButton => 'Hint (-10 🪙)';

  @override
  String get errorTitle => 'Aberya';

  @override
  String get noPuzzleError => 'Walang puzzle na mabuo.';

  @override
  String get congratulations => '🎉 Tapos na ang Antas!';

  @override
  String completedMessage(String regionName) {
    return 'Nahanap mo ang lahat ng salita sa $regionName!';
  }

  @override
  String rewardCoins(int coins, int total) {
    return '+$coins Barya (Kabuuan: $total)';
  }

  @override
  String get readTrivia => 'Basahin ang Trivia';

  @override
  String get continueButton => 'Magpatuloy';

  @override
  String get understoodButton => 'Naintindihan ko!';

  @override
  String get nextLevelButton => 'Susunod na Antas ➔';

  @override
  String get allRegionsCompleted => '🏆 Natapos ang Lahat ng 18 Rehiyon!';

  @override
  String get allRegionsCompletedMessage =>
      'Isa ka nang tunay na dalubhasa sa heograpiya at kultura ng Pilipinas!';

  @override
  String get funFactTitle => 'Alam Mo Ba?';

  @override
  String get noTriviaAvailable => 'Walang makuhang trivia.';

  @override
  String get audioSection => 'Tunog at Musika';

  @override
  String get musicTitle => 'Musika sa Background';

  @override
  String get musicSubtitle =>
      'I-play ang pampasiglang tugtugin habang naglalaro';

  @override
  String get sfxTitle => 'Mga Tunog ng Laro';

  @override
  String get sfxSubtitle => 'Tunog sa pagpili ng salita at pagpindot';

  @override
  String get volumeTitle => 'Lakas ng Tunog';
}
