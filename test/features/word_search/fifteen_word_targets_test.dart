import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/asset_seed_loader.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/word_search/data/repositories/word_repository.dart';
import 'package:rehiyonia/features/word_search/engine/selection_validator.dart';
import 'package:rehiyonia/features/word_search/engine/word_search_engine.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/providers/gameplay_provider.dart';
import 'package:rehiyonia/features/word_search/providers/word_provider.dart';
import 'package:rehiyonia/features/word_search/screens/word_search_screen.dart';
import 'package:rehiyonia/features/word_search/widgets/word_list_bar.dart';
import 'package:rehiyonia/shared/providers/app_initialization_provider.dart';

import '../../core/services/audio_service_test.dart';

class _PreviewGame extends GameplayNotifier {
  _PreviewGame(this.initial);
  final GameplayState initial;
  @override
  GameplayState build() => initial;
  @override
  Future<void> initGame(int regionId, {int? seed}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  final bundled =
      (jsonDecode(File('assets/data/regional_words.json').readAsStringSync())
              as List)
          .map((row) => RegionalWord.fromMap(row as Map<String, dynamic>))
          .toList();

  group('15-word regional puzzles', () {
    late AppDatabase database;
    late ProviderContainer session;
    late RegionRepository regions;
    late WordRepository words;
    setUp(() async {
      database = AppDatabase(databaseFactory: databaseFactoryFfi);
      await database.initialize(inMemory: true);
      regions = RegionRepository(appDatabase: database);
      words = WordRepository(appDatabase: database);
      await regions.insertRegions(defaultPhilippineRegions);
      await AssetSeedLoader(appDatabase: database).seedIfEmpty();
      session = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          regionRepositoryProvider.overrideWithValue(regions),
          wordRepositoryProvider.overrideWithValue(words),
        ],
      );
    });
    tearDown(() async {
      session.dispose();
      await database.close();
    });

    test(
      'all 18 regions place all 15 real locality words across multiple seeds',
      () async {
        expect(AppConstants.regionalWordTargetCount, 15);
        final game = session.read(gameplayProvider.notifier);
        for (final region in defaultPhilippineRegions) {
          final expected = bundled
              .where((w) => w.regionId == region.id)
              .map((w) => w.word)
              .toSet();
          expect(expected, hasLength(15));
          for (final seed in [0, 42, 777]) {
            await game.initGame(region.id, seed: seed);
            final state = session.read(gameplayProvider);
            expect(
              state.status,
              GameStatus.playing,
              reason: state.errorMessage,
            );
            expect(state.targetWords, hasLength(15));
            expect(state.puzzle!.placedWords, hasLength(15));
            expect(
              state.puzzle!.placedWords.map((p) => p.word).toSet(),
              expected,
            );
            expect(state.targetWords.every((w) => w.isTarget), isTrue);
            for (final placed in state.puzzle!.placedWords) {
              expect(
                SelectionValidator.getSpelledWord(
                  state.puzzle!.grid,
                  placed.coordinates,
                ),
                placed.word,
              );
            }
          }
        }
      },
    );

    test('completion and unlocking wait for the fifteenth word', () async {
      final game = session.read(gameplayProvider.notifier);
      await game.initGame(1, seed: 42);
      final initialCoins = session.read(gameplayProvider).coins;
      final placements = session.read(gameplayProvider).puzzle!.placedWords;
      for (var index = 0; index < placements.length; index++) {
        final placement = placements[index];
        game.updateDragSelection(
          placement.coordinates.first,
          placement.coordinates.last,
        );
        expect(await game.finalizeSelection(), isTrue);
        final state = session.read(gameplayProvider);
        expect(state.foundWords, hasLength(index + 1));
        if (index < 14) {
          expect(state.status, GameStatus.playing);
          expect(state.isAllWordsFound, isFalse);
          final saved = await regions.getAllRegions();
          expect(saved.singleWhere((r) => r.id == 1).starsEarned, 0);
          expect(saved.singleWhere((r) => r.id == 2).isUnlocked, isFalse);
        }
      }
      final state = session.read(gameplayProvider);
      expect(state.status, GameStatus.completed);
      expect(state.isAllWordsFound, isTrue);
      expect(state.score, 1500);
      expect(state.starsEarned, 3);
      expect(state.coins, initialCoins + 14 * 5 + 20);
      final saved = await regions.getAllRegions();
      expect(saved.singleWhere((r) => r.id == 1).starsEarned, 3);
      expect(saved.singleWhere((r) => r.id == 2).isUnlocked, isTrue);
    });

    test('older ten-target flags upgrade without resetting saved content or player progress', () async {
      final db = database.database;
      final oldFlags = db.batch();
      for (final region in defaultPhilippineRegions) {
        final records = await db.query(
          'localities',
          where: 'region_id = ?',
          whereArgs: [region.id],
          orderBy: 'id',
        );
        for (final record in records.skip(10)) {
          oldFlags.update(
            'localities',
            {'is_word_search_target': 0},
            where: 'id = ?',
            whereArgs: [record['id']],
          );
        }
      }
      await oldFlags.commit(noResult: true);
      final profile = ProfileRepository(database);
      await profile.saveName('Maya');
      await profile.saveAvatar(
        const PlayerAvatar(
          baseId: 'female',
          topId: 'explorer',
          headwearId: 'flower',
        ),
      );
      await profile.saveValue(AppConstants.keyCoins, '137');
      await db.update('regions', {
        'is_unlocked': 1,
        'stars_earned': 2,
      }, where: 'id = 18');
      final localitiesBefore = await db.query('localities', orderBy: 'id');
      final progressBefore = await db.query(
        'user_progress',
        orderBy: 'setting_key',
      );
      final profileBefore = await db.query('player_profile', orderBy: 'id');
      final regionsBefore = await db.query('regions', orderBy: 'id');
      final loader = AssetSeedLoader(appDatabase: database);
      await loader.seedIfEmpty();
      await loader.seedIfEmpty();
      final after = await db.query('localities', orderBy: 'id');
      expect(after, [
        for (final row in localitiesBefore)
          {...row, 'is_word_search_target': 1},
      ]);
      expect(
        await db.query('user_progress', orderBy: 'setting_key'),
        progressBefore,
      );
      expect(await db.query('player_profile', orderBy: 'id'), profileBefore);
      expect(await db.query('regions', orderBy: 'id'), regionsBefore);
      for (final region in defaultPhilippineRegions) {
        final localities = await words.getWordsForRegion(region.id);
        expect(localities, hasLength(15));
        expect(localities.every((word) => word.isTarget), isTrue);
      }
    });
  });

  testWidgets(
    'small phone displays Found 1 / 15 and all 15 scrollable target chips',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final targets = bundled.where((w) => w.regionId == 1).toList();
      final dimension = max(12, targets.map((w) => w.word.length).reduce(max));
      final puzzle = const WordSearchEngine().createPuzzle(
        words: targets.map((w) => w.word).toList(),
        rows: dimension,
        cols: dimension,
        seed: 42,
      );
      final state = GameplayState(
        status: GameStatus.playing,
        region: defaultPhilippineRegions.first,
        puzzle: puzzle,
        targetWords: targets,
        foundWords: {puzzle.placedWords.first.word},
      );
      final audio = AudioService(
        musicPlayer: MockAudioPlayer(),
        sfxPlayer: MockAudioPlayer(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameplayProvider.overrideWith(() => _PreviewGame(state)),
            audioServiceProvider.overrideWithValue(audio),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const WordSearchScreen(regionId: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Found: 1 / 15'), findsOneWidget);
      expect(
        tester.widget<WordListBar>(find.byType(WordListBar)).words,
        hasLength(15),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
