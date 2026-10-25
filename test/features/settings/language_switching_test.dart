import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app.dart';
import 'package:rehiyonia/app/app_startup_provider.dart';
import 'package:rehiyonia/core/localization/app_localizations.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/settings/models/app_language.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/settings/screens/settings_screen.dart';

import '../../support/explorer_fakes.dart';

void main() {
  test('Existing bilingual labels are preserved', () {
    const en = AppLocalizations(AppLanguage.english);
    const fil = AppLocalizations(AppLanguage.tagalog);
    expect(en.playButton, 'PLAY');
    expect(fil.playButton, 'MAGLARO');
    expect(en.coins(100), '100 Coins');
    expect(fil.coins(100), '100 Barya');
  });
  testWidgets('Explorer home switches languages reactively', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appStartupProvider.overrideWith((_) async {}),
        regionsProvider.overrideWith(TestRegions.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RehiyoniaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start exploring'), findsOneWidget);
    expect(find.text('Philippine Regional Word Search'), findsOneWidget);
    container.read(settingsProvider.notifier).setLanguage(AppLanguage.tagalog);
    await tester.pumpAndSettle();
    expect(find.text('Simulan ang paglalakbay'), findsOneWidget);
    expect(find.text('Paghahanap ng Salita sa mga Rehiyon'), findsOneWidget);
    container.read(settingsProvider.notifier).setLanguage(AppLanguage.english);
    await tester.pumpAndSettle();
    expect(find.text('Start exploring'), findsOneWidget);
  });
  testWidgets('Settings selects language and reduced motion', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reduce_motion_switch')));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).reduceMotion, isTrue);
    await tester.ensureVisible(find.text('Tagalog'));
    await tester.tap(find.text('Tagalog'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).language, AppLanguage.tagalog);
    expect(find.text('Mga Setting'), findsWidgets);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).language, AppLanguage.english);
  });
}
