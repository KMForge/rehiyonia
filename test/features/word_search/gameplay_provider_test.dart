import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/word_search/data/repositories/word_repository.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/providers/gameplay_provider.dart';
import 'package:rehiyonia/features/word_search/providers/word_provider.dart';
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

  group('GameplayProvider Tests', () {
    late ProviderContainer container;
    late AppDatabase appDatabase;

    setUp(() async {
      appDatabase = AppDatabase(databaseFactory: databaseFactoryFfi);
      await appDatabase.initialize(inMemory: true);

      final regionRepo = RegionRepository(appDatabase: appDatabase);
      final wordRepo = WordRepository(appDatabase: appDatabase);

      final existing = await regionRepo.getAllRegions();
      if (existing.isEmpty) {
        await regionRepo.insertRegions([
          const Region(
            id: 1,
            code: 'NCR',
            name: 'National Capital Region',
            designation: 'NCR',
            islandGroup: 'Luzon',
            description: 'Capital region',
            isUnlocked: true,
          ),
        ]);
      }

      final existingWords = await wordRepo.getWordsForRegion(1);
      if (existingWords.isEmpty) {
        await wordRepo.insertWords([
          const RegionalWord(
            regionId: 1,
            word: 'MANILA',
            category: 'Lungsod',
            clue: 'Kabisera',
          ),
          const RegionalWord(
            regionId: 1,
            word: 'PASIG',
            category: 'Lungsod',
            clue: 'Ilog',
          ),
        ]);
      }

      final mockAudioService = AudioService(
        musicPlayer: _MockAudioPlayer(),
        sfxPlayer: _MockAudioPlayer(),
      );

      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(appDatabase),
          regionRepositoryProvider.overrideWithValue(regionRepo),
          wordRepositoryProvider.overrideWithValue(wordRepo),
          audioServiceProvider.overrideWithValue(mockAudioService),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await appDatabase.close();
    });

    test('initializes game and creates puzzle with target words', () async {
      final notifier = container.read(gameplayProvider.notifier);
      await notifier.initGame(1, seed: 42);

      final state = container.read(gameplayProvider);
      expect(state.status, GameStatus.playing);
      expect(state.region, isNotNull);
      expect(state.region!.code, 'NCR');
      expect(state.puzzle, isNotNull);
      expect(state.targetWords.length, 2);
      expect(state.foundWords, isEmpty);
      expect(state.score, 0);
    });

    test('hint deducts coins and reveals first coordinate', () async {
      final notifier = container.read(gameplayProvider.notifier);
      await notifier.initGame(1, seed: 42);

      expect(container.read(gameplayProvider).coins, 50);
      notifier.useHint();

      final state = container.read(gameplayProvider);
      expect(state.coins, 40);
      expect(state.revealedHints.length, 1);
    });

    test('drag selection and word completion works correctly', () async {
      final notifier = container.read(gameplayProvider.notifier);
      await notifier.initGame(1, seed: 42);

      final state = container.read(gameplayProvider);
      final firstPlaced = state.puzzle!.placedWords.first;

      // Select from first to last coordinate of the placed word
      notifier.updateDragSelection(
        firstPlaced.coordinates.first,
        firstPlaced.coordinates.last,
      );

      final isMatched = await notifier.finalizeSelection();
      expect(isMatched, isTrue);

      final updatedState = container.read(gameplayProvider);
      expect(updatedState.foundWords.contains(firstPlaced.word), isTrue);
      expect(updatedState.score, 100);
    });
  });
}
