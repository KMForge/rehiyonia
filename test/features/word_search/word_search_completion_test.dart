import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/word_search/data/repositories/word_repository.dart';
import 'package:rehiyonia/features/word_search/models/placed_word.dart';
import 'package:rehiyonia/features/word_search/models/puzzle_coordinate.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/models/word_search_direction.dart';
import 'package:rehiyonia/features/word_search/models/word_search_puzzle.dart';
import 'package:rehiyonia/features/word_search/providers/gameplay_provider.dart';
import 'package:rehiyonia/features/word_search/screens/word_search_screen.dart';
import 'package:rehiyonia/shared/providers/app_initialization_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

class _MockAudioPlayer extends Fake implements AudioPlayer {
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('Word Search Completion & Next Level Flow Tests', () {
    late AppDatabase appDatabase;
    late RegionRepository regionRepo;
    late WordRepository wordRepo;

    setUp(() async {
      appDatabase = AppDatabase(databaseFactory: databaseFactoryFfi);
      await appDatabase.initialize(inMemory: true);
      regionRepo = RegionRepository(appDatabase: appDatabase);
      wordRepo = WordRepository(appDatabase: appDatabase);

      await regionRepo.insertRegions(defaultPhilippineRegions);
      await wordRepo.insertWords([
        const RegionalWord(
          regionId: 1,
          word: 'MANILA',
          category: 'City',
          clue: 'Capital',
          nameEn: 'City of Manila',
        ),
      ]);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    testWidgets('Tapping Proceed to Next Level button navigates to next region trivia', (
      WidgetTester tester,
    ) async {
      final mockAudioService = AudioService(
        musicPlayer: _MockAudioPlayer(),
        sfxPlayer: _MockAudioPlayer(),
      );

      final dummyPuzzle = WordSearchPuzzle(
        grid: [
          ['M', 'A', 'N', 'I', 'L', 'A'],
          ['A', 'B', 'C', 'D', 'E', 'F'],
        ],
        placedWords: [
          const PlacedWord(
            word: 'MANILA',
            direction: WordSearchDirection.horizontalForward,
            coordinates: [
              PuzzleCoordinate(0, 0),
              PuzzleCoordinate(0, 1),
              PuzzleCoordinate(0, 2),
              PuzzleCoordinate(0, 3),
              PuzzleCoordinate(0, 4),
              PuzzleCoordinate(0, 5),
            ],
            isFound: true,
          ),
        ],
        rows: 2,
        cols: 6,
      );

      String? pushedRoute;
      Object? pushedArguments;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(appDatabase),
            regionRepositoryProvider.overrideWithValue(regionRepo),
            audioServiceProvider.overrideWithValue(mockAudioService),
          ],
          child: MaterialApp(
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Next Screen')),
              );
            },
            home: const WordSearchScreen(regionId: 1),
          ),
        ),
      );

      // Pump once to trigger initState microtask
      await tester.pump();
      // Allow async initGame to finish
      await tester.pump(const Duration(milliseconds: 500));

      final element = tester.element(find.byType(WordSearchScreen));
      final container = ProviderScope.containerOf(element);

      // Now trigger completion
      container.read(gameplayProvider.notifier).updateStateForTesting(
        GameplayState(
          status: GameStatus.completed,
          region: defaultPhilippineRegions.first,
          puzzle: dummyPuzzle,
          foundWords: {'MANILA'},
          score: 100,
          starsEarned: 3,
        ),
      );

      // Settle dialog entrance animation
      await tester.pumpAndSettle();

      // Verify completion dialog is visible
      expect(find.text('🎉 Level Complete!'), findsOneWidget);
      expect(find.byKey(const Key('button_next_level')), findsOneWidget);

      // Tap Proceed to Next Level button
      await tester.tap(find.byKey(const Key('button_next_level')));
      await tester.pumpAndSettle();

      // Verify that it navigated to triviaChallenge with Region 2 (CAR)
      expect(pushedRoute, equals(AppRouter.triviaChallenge));
      expect(pushedArguments, equals(2));

      // Drain any pending sqflite lock warning timer
      await tester.pump(const Duration(seconds: 11));
    });
  });
}
