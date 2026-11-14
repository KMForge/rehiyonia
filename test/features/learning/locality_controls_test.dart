import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/core/localization/app_localizations.dart';
import 'package:rehiyonia/features/learning/screens/locality_learning_cards_screen.dart';
import 'package:rehiyonia/features/settings/models/app_language.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/providers/word_provider.dart';

void main() {
  const localities = [
    RegionalWord(
      id: 1,
      regionId: 1,
      word: 'MANILA',
      category: 'City',
      clue: 'The capital city.',
      nameEn: 'Manila',
      nameFil: 'Maynila',
    ),
    RegionalWord(
      id: 2,
      regionId: 1,
      word: 'QUEZON',
      category: 'City',
      clue: 'A city in Metro Manila.',
      nameEn: 'Quezon City',
      nameFil: 'Lungsod Quezon',
    ),
  ];
  for (final (width, scale, language) in [
    (320.0, 1.5, AppLanguage.tagalog),
    (390.0, 1.0, AppLanguage.english),
    (780.0, 1.0, AppLanguage.english),
  ]) {
    testWidgets(
      'compact locality controls at ${width}px: Previous left, Next right',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final session = ProviderContainer(
          overrides: [
            wordsForRegionProvider(1).overrideWith((ref) async => localities),
          ],
        );
        addTearDown(session.dispose);
        session.read(settingsProvider.notifier).setLanguage(language);
        final loc = AppLocalizations(language);
        Object? destinationRegion;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: session,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              onGenerateRoute: (settings) {
                expect(settings.name, AppRouter.triviaChallenge);
                destinationRegion = settings.arguments;
                return MaterialPageRoute<void>(
                  builder: (_) =>
                      const Scaffold(body: Text('Trivia destination')),
                );
              },
              home: const LocalityLearningCardsScreen(regionId: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final next = find.byKey(const Key('button_next_or_trivia'));
        final previous = find.byKey(const Key('button_previous_locality'));
        final nextBounds = tester.getRect(next);
        final previousBounds = tester.getRect(previous);
        expect(previousBounds.right, lessThan(nextBounds.left));
        expect(
          (previousBounds.left + nextBounds.right) / 2,
          closeTo(width / 2, 1),
        );
        expect(nextBounds.center.dy, closeTo(previousBounds.center.dy, .1));
        expect(nextBounds.width, lessThanOrEqualTo(168));
        expect(previousBounds.width, lessThanOrEqualTo(168));
        expect(nextBounds.height, greaterThanOrEqualTo(48));
        expect(tester.widget<OutlinedButton>(previous).onPressed, isNull);
        final photoBounds = tester.getRect(
          find.byKey(const ValueKey('locality_photo_frame_MANILA')),
        );
        expect(photoBounds.width, lessThanOrEqualTo(320));
        expect(photoBounds.height, lessThan(180));
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(find.text(loc.cardProgress(2, 2)), findsOneWidget);
        expect(tester.widget<OutlinedButton>(previous).onPressed, isNotNull);
        await tester.tap(previous);
        await tester.pumpAndSettle();
        expect(find.text(loc.cardProgress(1, 2)), findsOneWidget);
        await tester.drag(find.byType(PageView), Offset(-width, 0));
        await tester.pumpAndSettle();
        expect(find.text(loc.cardProgress(2, 2)), findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(destinationRegion, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
