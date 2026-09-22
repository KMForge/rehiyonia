import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fil'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Rehiyonia'**
  String get appName;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Philippine Regional Word Search'**
  String get subtitle;

  /// No description provided for @curriculumTag.
  ///
  /// In en, this message translates to:
  /// **'Araling Panlipunan • Grade 5'**
  String get curriculumTag;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'{count} Coins'**
  String coins(int count);

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'{count} Stars'**
  String stars(int count);

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get playButton;

  /// No description provided for @avatarStudioButton.
  ///
  /// In en, this message translates to:
  /// **'Avatar Studio'**
  String get avatarStudioButton;

  /// No description provided for @badgeGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Badge Gallery'**
  String get badgeGalleryButton;

  /// No description provided for @settingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButton;

  /// No description provided for @aboutButton.
  ///
  /// In en, this message translates to:
  /// **'About Game'**
  String get aboutButton;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Rehiyonia'**
  String get aboutTitle;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'Rehiyonia is an offline educational word search game designed for Grade 5 Araling Panlipunan, covering all 18 Philippine regions with 100% offline gameplay.'**
  String get aboutContent;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select game language'**
  String get languageSubtitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Player Account'**
  String get accountSection;

  /// No description provided for @customizeName.
  ///
  /// In en, this message translates to:
  /// **'Customize Player Name'**
  String get customizeName;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter player name'**
  String get enterNameHint;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @nameUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Player name updated successfully!'**
  String get nameUpdatedMessage;

  /// No description provided for @avatarStudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Avatar Studio'**
  String get avatarStudioTitle;

  /// No description provided for @skinTone.
  ///
  /// In en, this message translates to:
  /// **'Skin Tone'**
  String get skinTone;

  /// No description provided for @hairStyle.
  ///
  /// In en, this message translates to:
  /// **'Hair Style'**
  String get hairStyle;

  /// No description provided for @hairColor.
  ///
  /// In en, this message translates to:
  /// **'Hair Color'**
  String get hairColor;

  /// No description provided for @outfitColor.
  ///
  /// In en, this message translates to:
  /// **'Outfit Color'**
  String get outfitColor;

  /// No description provided for @accessory.
  ///
  /// In en, this message translates to:
  /// **'Accessory'**
  String get accessory;

  /// No description provided for @saveAvatar.
  ///
  /// In en, this message translates to:
  /// **'Save Avatar'**
  String get saveAvatar;

  /// No description provided for @avatarSaved.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated successfully!'**
  String get avatarSaved;

  /// No description provided for @badgeGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Badge Gallery'**
  String get badgeGalleryTitle;

  /// No description provided for @badgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges Earned: {earned} / {total}'**
  String badgesEarned(int earned, int total);

  /// No description provided for @lockedBadge.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedBadge;

  /// No description provided for @unlockedBadge.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlockedBadge;

  /// No description provided for @selectIslandGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Island Group'**
  String get selectIslandGroup;

  /// No description provided for @luzonTitle.
  ///
  /// In en, this message translates to:
  /// **'Luzon'**
  String get luzonTitle;

  /// No description provided for @visayasTitle.
  ///
  /// In en, this message translates to:
  /// **'Visayas'**
  String get visayasTitle;

  /// No description provided for @mindanaoTitle.
  ///
  /// In en, this message translates to:
  /// **'Mindanao'**
  String get mindanaoTitle;

  /// No description provided for @regionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Regions'**
  String regionsCount(int count);

  /// No description provided for @regionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get regionsTitle;

  /// No description provided for @selectRegionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a region to begin exploring!'**
  String get selectRegionPrompt;

  /// No description provided for @islandGroup.
  ///
  /// In en, this message translates to:
  /// **'{group} Group'**
  String islandGroup(String group);

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @errorLoadingRegions.
  ///
  /// In en, this message translates to:
  /// **'Error loading regions'**
  String get errorLoadingRegions;

  /// No description provided for @regionLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This region is locked. Complete previous regions first!'**
  String get regionLockedMessage;

  /// No description provided for @regionIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Region Overview'**
  String get regionIntroTitle;

  /// No description provided for @culturalHighlights.
  ///
  /// In en, this message translates to:
  /// **'Cultural Highlights'**
  String get culturalHighlights;

  /// No description provided for @localitiesToExplore.
  ///
  /// In en, this message translates to:
  /// **'15 Localities to Explore'**
  String get localitiesToExplore;

  /// No description provided for @startLearningButton.
  ///
  /// In en, this message translates to:
  /// **'Start Learning (15 Localities)'**
  String get startLearningButton;

  /// No description provided for @localityCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Localities'**
  String get localityCardsTitle;

  /// No description provided for @cardProgress.
  ///
  /// In en, this message translates to:
  /// **'Locality {current} of {total}'**
  String cardProgress(int current, int total);

  /// No description provided for @provinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get provinceLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @funFactLabel.
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get funFactLabel;

  /// No description provided for @takeTriviaButton.
  ///
  /// In en, this message translates to:
  /// **'Take Trivia Challenge'**
  String get takeTriviaButton;

  /// No description provided for @previousCard.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousCard;

  /// No description provided for @nextCard.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextCard;

  /// No description provided for @triviaTitle.
  ///
  /// In en, this message translates to:
  /// **'Regional Trivia'**
  String get triviaTitle;

  /// No description provided for @triviaChallenge.
  ///
  /// In en, this message translates to:
  /// **'🎓 Regional Trivia Challenge'**
  String get triviaChallenge;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select the correct answer to earn bonus coins:'**
  String get selectAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'🎉 Correct! Outstanding knowledge!'**
  String get correctAnswer;

  /// No description provided for @incorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Nice try! The correct answer is:'**
  String get incorrectAnswer;

  /// No description provided for @triviaBonus.
  ///
  /// In en, this message translates to:
  /// **'+10 Bonus Coins'**
  String get triviaBonus;

  /// No description provided for @startWordSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Start Word Search ➔'**
  String get startWordSearchButton;

  /// No description provided for @foundCount.
  ///
  /// In en, this message translates to:
  /// **'Found: {found} / {total}'**
  String foundCount(int found, int total);

  /// No description provided for @hintButton.
  ///
  /// In en, this message translates to:
  /// **'Hint (-10 🪙)'**
  String get hintButton;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @noPuzzleError.
  ///
  /// In en, this message translates to:
  /// **'No puzzle could be generated.'**
  String get noPuzzleError;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'🎉 Level Complete!'**
  String get congratulations;

  /// No description provided for @completedMessage.
  ///
  /// In en, this message translates to:
  /// **'You found all words in {regionName}!'**
  String completedMessage(String regionName);

  /// No description provided for @rewardCoins.
  ///
  /// In en, this message translates to:
  /// **'+{coins} Coins (Total: {total})'**
  String rewardCoins(int coins, int total);

  /// No description provided for @readTrivia.
  ///
  /// In en, this message translates to:
  /// **'Read Trivia'**
  String get readTrivia;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @understoodButton.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get understoodButton;

  /// No description provided for @nextLevelButton.
  ///
  /// In en, this message translates to:
  /// **'Next Level ➔'**
  String get nextLevelButton;

  /// No description provided for @allRegionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'🏆 All 18 Regions Completed!'**
  String get allRegionsCompleted;

  /// No description provided for @allRegionsCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You are now a true master of Philippine geography and culture!'**
  String get allRegionsCompletedMessage;

  /// No description provided for @funFactTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get funFactTitle;

  /// No description provided for @noTriviaAvailable.
  ///
  /// In en, this message translates to:
  /// **'No trivia available.'**
  String get noTriviaAvailable;

  /// No description provided for @audioSection.
  ///
  /// In en, this message translates to:
  /// **'Audio & Music'**
  String get audioSection;

  /// No description provided for @musicTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get musicTitle;

  /// No description provided for @musicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play uplifting background music while playing'**
  String get musicSubtitle;

  /// No description provided for @sfxTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get sfxTitle;

  /// No description provided for @sfxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sound on word selection and interaction'**
  String get sfxSubtitle;

  /// No description provided for @volumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
