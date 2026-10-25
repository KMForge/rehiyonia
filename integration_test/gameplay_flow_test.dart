import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehiyonia/features/learning/screens/locality_learning_cards_screen.dart';
import 'package:rehiyonia/features/trivia/screens/pre_game_trivia_screen.dart';
import 'package:rehiyonia/features/word_search/providers/gameplay_provider.dart';
import 'package:rehiyonia/features/word_search/screens/word_search_screen.dart';

import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Gameplay flow: selects region, views word clues, and triggers hint',
    (tester) async {
      await launchTestApp(tester);

      // 1. Enter Region Selection
      await tester.tap(find.byKey(const Key('menu_play_button')));
      await tester.pumpAndSettle();

      // Follow the actual learning/trivia flow before the puzzle.
      await tester.tap(find.text('National Capital Region').first);
      await tester.pumpAndSettle();
      final start = find.byKey(const Key('button_start_learning'));
      await tester.scrollUntilVisible(start, 180);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.byType(LocalityLearningCardsScreen), findsOneWidget);
      for (
        var i = 0;
        i < 50 &&
            find.byType(LocalityLearningCardsScreen).evaluate().isNotEmpty;
        i++
      ) {
        final next = find.byKey(const Key('button_next_or_trivia'));
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(find.byType(PreGameTriviaScreen), findsOneWidget);
      for (
        var i = 0;
        i < 50 && find.byType(PreGameTriviaScreen).evaluate().isNotEmpty;
        i++
      ) {
        final answer = find.byKey(const Key('trivia_option_0'));
        await tester.ensureVisible(answer);
        await tester.tap(answer);
        await tester.pumpAndSettle();
        final next = find.byKey(const Key('button_trivia_continue_or_start'));
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(find.byType(WordSearchScreen), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WordSearchScreen)),
      );
      final before = container.read(gameplayProvider);

      // 3. Verify gameplay elements loaded
      expect(find.text('National Capital Region'), findsWidgets);
      expect(find.textContaining('Hint (-10'), findsOneWidget);

      expect(before.status, GameStatus.playing);
      expect(before.coins, greaterThanOrEqualTo(10));

      // Trivia can award coins, so verify the hint's relative cost.
      await tester.tap(find.textContaining('Hint (-10'));
      await tester.pumpAndSettle();
      expect(container.read(gameplayProvider).coins, before.coins - 10);
      expect(container.read(gameplayProvider).revealedHints, isNotEmpty);

      // 5. Tap target word chip to open educational clue sheet
      final word = before.targetWords.first;
      final chip = find.text(word.word);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();

      // Verify clue contents
      expect(find.text(word.displayNameEn), findsOneWidget);
      expect(find.text(word.displayClueEn), findsOneWidget);

      // 6. Close bottom sheet
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
    },
  );
}
