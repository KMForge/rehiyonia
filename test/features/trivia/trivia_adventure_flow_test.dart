import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';
import 'package:rehiyonia/features/trivia/models/trivia_item.dart';
import 'package:rehiyonia/features/trivia/providers/trivia_provider.dart';
import 'package:rehiyonia/features/trivia/screens/pre_game_trivia_screen.dart';
import 'package:rehiyonia/shared/widgets/rehiyonia_adventure_background.dart';

void main() {
  for (final regionId in [1, 18]) {
    for (final correct in [true, false]) {
      testWidgets(
        'region $regionId: ${correct ? 'correct' : 'incorrect'} answer retains rewards and progression on a small phone',
        (tester) async {
          tester.view.physicalSize = const Size(320, 740);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final items = [
            for (var i = 0; i < 2; i++)
              TriviaItem(
                id: i + 1,
                regionId: regionId,
                question: 'Travel question ${i + 1}',
                optionA: 'Answer A',
                optionB: 'Answer B',
                optionC: 'Answer C',
                optionD: 'Answer D',
                correctOption: 0,
                explanation: 'Explanation ${i + 1}',
              ),
          ];
          final container = ProviderContainer(
            overrides: [
              triviaForRegionProvider(regionId)
                  .overrideWith((_) async => items),
            ],
          );
          addTearDown(container.dispose);
          final initial = container.read(profileProvider);
          int? destinationRegion;
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.3)),
                  child: child!,
                ),
                home: PreGameTriviaScreen(regionId: regionId),
                onGenerateRoute: (settings) {
                  expect(settings.name, AppRouter.game);
                  destinationRegion = settings.arguments as int;
                  return MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Word search')),
                  );
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(RehiyoniaAdventureBackground), findsOneWidget);

          Future<void> tapVisible(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.pumpAndSettle();
            await tester.tap(finder);
            await tester.pumpAndSettle();
          }

          await tapVisible(find.byKey(Key('trivia_option_${correct ? 0 : 1}')));
          expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
          if (!correct) {
            expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
          }
          expect(find.text('Explanation 1'), findsOneWidget);
          final expectedCoins = initial.coins + (correct ? 10 : 0);
          expect(container.read(profileProvider).coins, expectedCoins);
          // Answered choices cannot award a second reward or change feedback.
          await tapVisible(find.byKey(const Key('trivia_option_0')));
          expect(container.read(profileProvider).coins, expectedCoins);

          final next = find.byKey(const Key('button_trivia_continue_or_start'));
          await tapVisible(next);
          expect(find.text('Travel question 2'), findsOneWidget);
          expect(
            find.byKey(const Key('trivia_explanation_card')),
            findsNothing,
          );
          await tapVisible(find.byKey(const Key('trivia_option_1')));
          expect(find.text('Explanation 2'), findsOneWidget);
          expect(container.read(profileProvider).coins, expectedCoins);
          expect(container.read(profileProvider).avatar, initial.avatar);
          await tapVisible(next);
          expect(destinationRegion, regionId);
          expect(find.text('Word search'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
