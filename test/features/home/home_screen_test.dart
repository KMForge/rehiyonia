import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';

import '../../core/services/audio_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Rehiyonia Main Menu displays game title and action buttons', (
    WidgetTester tester,
  ) async {
    final mockAudioService = AudioService(
      musicPlayer: MockAudioPlayer(),
      sfxPlayer: MockAudioPlayer(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioServiceProvider.overrideWithValue(mockAudioService)],
        child: const RehiyoniaApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and curriculum subtitle
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Philippine Regional Word Search'), findsOneWidget);
    expect(find.text('Araling Panlipunan • Grade 5'), findsOneWidget);

    // Verify player stats (Default is English)
    expect(find.text('Bayani'), findsOneWidget);
    expect(find.text('${AppConstants.startingCoins} Coins'), findsOneWidget);
    expect(find.text('0 Stars'), findsOneWidget);

    // Tap player profile chip to open Customize Player Name dialog
    await tester.tap(find.byKey(const Key('button_player_profile')));
    await tester.pumpAndSettle();

    expect(find.text('Customize Player Name'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter a new name
    await tester.enterText(find.byType(TextField), 'Gabriela');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify name updated on Home screen
    expect(find.text('Gabriela'), findsOneWidget);

    // Verify primary menu action buttons
    expect(find.byKey(const Key('menu_play_button')), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.byKey(const Key('menu_settings_button')), findsOneWidget);
    expect(find.byKey(const Key('menu_about_button')), findsOneWidget);
  });
}
