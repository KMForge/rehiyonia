import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/trivia/models/trivia_item.dart';
import 'package:rehiyonia/features/trivia/providers/trivia_provider.dart';
import 'package:rehiyonia/features/trivia/screens/pre_game_trivia_screen.dart';
import 'package:rehiyonia/features/learning/screens/locality_learning_cards_screen.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/providers/word_provider.dart';

void main() {
  testWidgets('culture photo appears with the answer and remains scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const question = TriviaItem(
      regionId: 1,
      question: 'Anong pagtatanghal ang tampok sa Bagong Taong Tsino?',
      optionA: 'Sayaw ng leon',
      optionB: 'Moriones',
      optionC: 'Pintados',
      optionD: 'Sinulog',
      correctOption: 0,
      explanation: 'May sayaw ng leon sa pagdiriwang sa Binondo.',
      imagePath: 'assets/images/trivia/region_1.jpg',
      imageCaption: 'Pagdiriwang sa Binondo.',
      imageCredit: 'Zarate123 / CC BY-SA 4.0 / Wikimedia Commons',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          triviaForRegionProvider(1).overrideWith((_) async => [question]),
        ],
        child: const MaterialApp(home: PreGameTriviaScreen(regionId: 1)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trivia_culture_image')), findsNothing);
    // An incorrect answer reveals the explanation without changing player coins.
    final option = find.byKey(const Key('trivia_option_1'));
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trivia_culture_image')), findsOneWidget);
    expect(find.text('Pagdiriwang sa Binondo.'), findsOneWidget);
    final next = find.byKey(const Key('button_trivia_continue_or_start'));
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    expect(next.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'all four trivia options are present and scrollable on a small phone',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final rows = jsonDecode(
        File('assets/data/trivia.json').readAsStringSync(),
      ) as List;
      final question = TriviaItem.fromMap(rows.first as Map<String, dynamic>);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            triviaForRegionProvider(1).overrideWith((_) async => [question]),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: const PreGameTriviaScreen(regionId: 1),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        final option = find.byKey(Key('trivia_option_$i'));
        expect(option, findsOneWidget);
        await tester.ensureVisible(option);
        await tester.pumpAndSettle();
        expect(option.hitTestable(), findsOneWidget);
      }
    },
  );

  testWidgets('last locality controls fit without overlapping', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const word = RegionalWord(
      regionId: 1,
      word: 'SANJUAN',
      category: 'City',
      clue: 'Historic city',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wordsForRegionProvider(1).overrideWith((_) async => [word, word]),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: LocalityLearningCardsScreen(regionId: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('button_next_or_trivia')));
    await tester.pumpAndSettle();
    final previous = tester.getRect(find.byType(OutlinedButton));
    final next = tester.getRect(find.byKey(const Key('button_next_or_trivia')));
    expect(previous.overlaps(next), isFalse);
    expect(next.right, lessThanOrEqualTo(360));
  });
}
