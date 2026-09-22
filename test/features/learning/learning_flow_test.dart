import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/learning/screens/locality_learning_cards_screen.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/regions/screens/island_group_selection_screen.dart';
import 'package:rehiyonia/features/regions/screens/region_intro_screen.dart';
import 'package:rehiyonia/features/trivia/models/trivia_item.dart';
import 'package:rehiyonia/features/trivia/providers/trivia_provider.dart';
import 'package:rehiyonia/features/trivia/screens/pre_game_trivia_screen.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/providers/word_provider.dart';

class _FakeRegionsNotifier extends RegionsNotifier {
  _FakeRegionsNotifier(this._regions);
  final List<Region> _regions;

  @override
  Future<List<Region>> build() async => _regions;
}

void main() {
  group('Phase 5 Learning Flow Widget Tests', () {
    final mockRegion = const Region(
      id: 1,
      code: 'NCR',
      name: 'National Capital Region',
      designation: 'NCR',
      islandGroup: 'Luzon',
      description:
          'The political, economic, and cultural center of the Philippines.',
      isUnlocked: true,
      starsEarned: 3,
    );

    final mockWords = [
      const RegionalWord(
        id: 1,
        regionId: 1,
        word: 'MANILA',
        category: 'City',
        clue: 'Capital of the Republic of the Philippines.',
        nameEn: 'City of Manila',
        nameFil: 'Lungsod ng Maynila',
        provinceEn: 'Metro Manila',
        provinceFil: 'Kalakhang Maynila',
        factEn: 'Home to the historic walled city of Intramuros.',
        factFil: 'Tahanan ng makasaysayang Intramuros.',
      ),
      const RegionalWord(
        id: 2,
        regionId: 1,
        word: 'QUEZON',
        category: 'City',
        clue: 'Former capital and largest city in Metro Manila.',
        nameEn: 'Quezon City',
        nameFil: 'Lungsod Quezon',
        provinceEn: 'Metro Manila',
        provinceFil: 'Kalakhang Maynila',
        factEn: 'Named after Manuel L. Quezon.',
        factFil: 'Ipinangalan kay Manuel L. Quezon.',
      ),
    ];

    final mockTrivia = [
      const TriviaItem(
        id: 1,
        regionId: 1,
        question: 'Ano ang pinakamatandang pader o tanggulan sa Maynila?',
        optionA: 'Intramuros',
        optionB: 'Fort Santiago',
        optionC: 'Luneta',
        optionD: 'Malacañang',
        correctOption: 0,
        explanation: 'Ang Intramuros ay tinaguriang Walled City.',
        questionEn: 'What is the oldest walled fortress in Manila?',
        optionAEn: 'Intramuros',
        optionBEn: 'Fort Santiago',
        optionCEn: 'Luneta',
        optionDEn: 'Malacañang',
        explanationEn: 'Intramuros was known as the Walled City.',
      ),
    ];

    testWidgets(
      'IslandGroupSelectionScreen renders Luzon, Visayas, Mindanao groups',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              regionsProvider.overrideWith(
                () => _FakeRegionsNotifier([mockRegion]),
              ),
            ],
            child: const MaterialApp(home: IslandGroupSelectionScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Select Island Group'), findsOneWidget);
        expect(find.text('Luzon'), findsOneWidget);
        expect(find.text('Visayas'), findsOneWidget);
        expect(find.text('Mindanao'), findsOneWidget);
      },
    );

    testWidgets(
      'RegionIntroScreen displays cultural overview and start learning button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              regionsProvider.overrideWith(
                () => _FakeRegionsNotifier([mockRegion]),
              ),
            ],
            child: const MaterialApp(home: RegionIntroScreen(regionId: 1)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Region Overview'), findsOneWidget);
        expect(find.text('NCR'), findsOneWidget);
        expect(find.text('Cultural Highlights'), findsOneWidget);
        expect(find.byKey(const Key('button_start_learning')), findsOneWidget);
      },
    );

    testWidgets(
      'LocalityLearningCardsScreen displays cards and swiping controls',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              wordsForRegionProvider(1)
                  .overrideWith((ref) => Future.value(mockWords)),
            ],
            child: const MaterialApp(
              home: LocalityLearningCardsScreen(regionId: 1),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Explore Localities'), findsOneWidget);
        expect(find.text('MANILA'), findsOneWidget);
        expect(find.text('City of Manila'), findsOneWidget);
        expect(find.text('Did You Know?'), findsOneWidget);
        expect(find.byKey(const Key('button_next_or_trivia')), findsOneWidget);

        // Tap next to view second card
        await tester.tap(find.byKey(const Key('button_next_or_trivia')));
        await tester.pumpAndSettle();

        expect(find.text('QUEZON'), findsOneWidget);
        expect(find.text('Quezon City'), findsOneWidget);
      },
    );

    testWidgets(
      'PreGameTriviaScreen handles answer tap and shows explanation with coins bonus',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              triviaForRegionProvider(1)
                  .overrideWith((ref) => Future.value(mockTrivia)),
            ],
            child: const MaterialApp(home: PreGameTriviaScreen(regionId: 1)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('🎓 Regional Trivia Challenge'), findsOneWidget);
        expect(
          find.text('What is the oldest walled fortress in Manila?'),
          findsOneWidget,
        );
        expect(find.text('Intramuros'), findsOneWidget);

        // Tap option A (Intramuros)
        await tester.tap(find.text('Intramuros'));
        await tester.pumpAndSettle();

        expect(find.text('+10 🪙'), findsOneWidget);
        expect(find.text('🎉 Correct! Outstanding knowledge!'), findsOneWidget);
        expect(
          find.text('Intramuros was known as the Walled City.'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('button_trivia_continue_or_start')),
          findsOneWidget,
        );
      },
    );
  });
}
