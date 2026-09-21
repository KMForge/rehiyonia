import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/localization/app_localizations.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/settings/models/app_language.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/settings/screens/settings_screen.dart';

import '../../core/services/audio_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language Localization & Switching', () {
    test('Default language is English', () {
      final loc = AppLocalizations(AppLanguage.english);
      expect(loc.isEnglish, isTrue);
      expect(loc.playButton, 'PLAY');
      expect(loc.coins(100), '100 Coins');
      expect(loc.stars(5), '5 Stars');
      expect(loc.settingsTitle, 'Settings');
      expect(loc.categoryLabel('lungsod'), 'City');
      expect(loc.categoryLabel('lalawigan'), 'Province');
    });

    test('Tagalog localizations provide correct Tagalog strings', () {
      final loc = AppLocalizations(AppLanguage.tagalog);
      expect(loc.isEnglish, isFalse);
      expect(loc.playButton, 'MAGLARO');
      expect(loc.coins(100), '100 Barya');
      expect(loc.stars(5), '5 Bituin');
      expect(loc.settingsTitle, 'Mga Setting');
      expect(loc.categoryLabel('lungsod'), 'lungsod');
    });

    testWidgets('App starts in English and switches reactively to Tagalog', (
      WidgetTester tester,
    ) async {
      final mockAudioService = AudioService(
        musicPlayer: MockAudioPlayer(),
        sfxPlayer: MockAudioPlayer(),
      );

      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudioService)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RehiyoniaApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial English state
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('${AppConstants.startingCoins} Coins'), findsOneWidget);
      expect(find.text('0 Stars'), findsOneWidget);
      expect(find.text('Philippine Regional Word Search'), findsOneWidget);

      // Programmatically switch to Tagalog
      container
          .read(settingsProvider.notifier)
          .setLanguage(AppLanguage.tagalog);
      await tester.pumpAndSettle();

      // Verify UI updated to Tagalog
      expect(find.text('MAGLARO'), findsOneWidget);
      expect(find.text('${AppConstants.startingCoins} Barya'), findsOneWidget);
      expect(find.text('0 Bituin'), findsOneWidget);
      expect(find.text('Paghahanap ng Salita sa mga Rehiyon'), findsOneWidget);

      // Switch back to English
      container
          .read(settingsProvider.notifier)
          .setLanguage(AppLanguage.english);
      await tester.pumpAndSettle();

      // Verify UI reverted to English
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('${AppConstants.startingCoins} Coins'), findsOneWidget);
      expect(find.text('0 Stars'), findsOneWidget);
    });

    testWidgets('SettingsScreen allows user to select Tagalog and English', (
      WidgetTester tester,
    ) async {
      final mockAudioService = AudioService(
        musicPlayer: MockAudioPlayer(),
        sfxPlayer: MockAudioPlayer(),
      );

      final container = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(mockAudioService)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Check SettingsScreen title is in English by default
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Tagalog'), findsOneWidget);

      // Tap Tagalog button
      await tester.tap(find.text('Tagalog'));
      await tester.pumpAndSettle();

      // Verify settingsProvider updated
      expect(container.read(settingsProvider).language, AppLanguage.tagalog);
      // Title and sections should now be in Tagalog
      expect(find.text('Mga Setting'), findsWidgets);
      expect(find.text('Wika'), findsOneWidget);

      // Tap English button
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).language, AppLanguage.english);
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Language'), findsOneWidget);
    });
  });
}
