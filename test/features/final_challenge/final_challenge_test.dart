import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/constants/database_constants.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/badges/region_landmark.dart';
import 'package:rehiyonia/features/final_challenge/final_challenge_catalog.dart';
import 'package:rehiyonia/features/final_challenge/final_challenge_provider.dart';
import 'package:rehiyonia/features/final_challenge/final_challenge_repository.dart';
import 'package:rehiyonia/features/final_challenge/screens/final_challenge_screen.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/settings/models/audio_preferences.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/word_search/engine/word_search_engine.dart';
import 'package:rehiyonia/features/word_search/providers/gameplay_provider.dart';
import 'package:rehiyonia/features/word_search/screens/word_search_screen.dart';
import 'package:rehiyonia/shared/providers/app_initialization_provider.dart';

class _FinalPreview extends GameplayNotifier {
  _FinalPreview(this.initial);
  final GameplayState initial;
  @override
  GameplayState build() => initial;
  @override
  Future<void> initFinalChallenge({bool replay = false, int? seed}) async {}
  @override
  Future<void> initGame(int regionId, {int? seed}) async {}
}

class _CompletedRegions extends RegionsNotifier {
  @override
  Future<List<Region>> build() async => [
    for (final region in defaultPhilippineRegions)
      Region(
        id: region.id,
        code: region.code,
        name: region.name,
        designation: region.designation,
        islandGroup: region.islandGroup,
        description: region.description,
        isUnlocked: true,
        starsEarned: 3,
      ),
  ];
}

class _SilentSettings extends SettingsNotifier {
  @override
  AudioPreferences build() =>
      const AudioPreferences(isSoundEffectsEnabled: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  test('15 unique clues draw from all 18 regions, include NIR and every island group, and have real offline photos', () {
    final photos = parseRegionLandmarks(
      File('assets/data/region_landmarks.json').readAsStringSync(),
    );
    final observed = <int>{};
    expect(finalChallengeCatalog, hasLength(18));
    for (var seed = 0; seed < 40; seed++) {
      final ids = selectFinalRegions(seed);
      observed.addAll(ids);
      expect(ids.toSet(), hasLength(15));
      expect(ids, contains(18));
      expect(
        defaultPhilippineRegions
            .where((r) => ids.contains(r.id))
            .map((r) => r.islandGroup)
            .toSet(),
        {'Luzon', 'Visayas', 'Mindanao'},
      );
      final clues = FinalChallengeRound(regionIds: ids, seed: seed).clues;
      expect(clues.where((word) => word.isTriviaWord), hasLength(7));
      expect(clues.where((word) => !word.isTriviaWord), hasLength(8));
      final puzzle = const WordSearchEngine().createPuzzle(
        words: clues.map((c) => c.word).toList(),
        rows: 13,
        cols: 13,
        seed: seed,
      );
      expect(
        puzzle.placedWords.map((p) => p.word).toSet(),
        clues.map((c) => c.word).toSet(),
      );
      for (final clue in clues) {
        expect(RegExp(r'^[A-Z]+$').hasMatch(clue.word), isTrue);
        expect(clue.english, isNotEmpty);
        expect(clue.filipino, isNotEmpty);
        expect(
          File(clue.imagePath ?? photos[clue.regionId]!.assetPath).existsSync(),
          isTrue,
        );
      }
    }
    expect(observed, {for (var id = 1; id <= 18; id++) id});
  });

  test('trivia words are vocabulary from actual saved culture answers and reuse their correct photographs', () {
    final rows = (jsonDecode(
      File('assets/data/regional_culture.json').readAsStringSync(),
    ) as List).cast<Map<String, dynamic>>();
    String normalize(String value) => value
        .toUpperCase()
        .replaceAll('Ñ', 'N')
        .replaceAll(RegExp('[^A-Z]'), '');
    expect(finalTriviaWords, hasLength(18));
    expect(
      finalTriviaWords.map((word) => word.word),
      containsAll(['SINULOG', 'MASSKARA', 'VINTA', 'INABEL']),
    );
    for (final word in finalTriviaWords) {
      final source = rows.firstWhere(
        (row) => row['region_id'] == word.regionId,
      );
      final answers = (source['questions'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (question) => normalize(
              (question['options'] as List)[question['correct_option'] as int]
                  as String,
            ),
          );
      expect(
        answers.any((answer) => answer.contains(word.word)),
        isTrue,
        reason: word.word,
      );
      expect(word.imagePath, source['image_path']);
      expect(word.factEn, isNotEmpty);
      expect(word.factFil, isNotEmpty);
      expect(File(word.imagePath!).existsSync(), isTrue);
    }
  });

  group('saved final challenge', () {
    late Directory directory;
    late AppDatabase db;
    late RegionRepository regions;
    late ProviderContainer container;
    late String path;

    Future<void> open() async {
      db = AppDatabase(databaseFactory: databaseFactoryFfi);
      await db.initialize(databasePath: path);
      regions = RegionRepository(appDatabase: db);
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      await container.read(profileProvider.notifier).loadProfile();
    }

    Future<void> unlock() async {
      for (final region in defaultPhilippineRegions) {
        await regions.unlockRegion(region.id);
        await regions.updateStars(region.id, 3);
      }
      container.invalidate(regionsProvider);
    }

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('rehiyonia_final_');
      path = '${directory.path}/game.db';
      await open();
      await regions.insertRegions(defaultPhilippineRegions);
    });
    tearDown(() async {
      container.dispose();
      await db.close();
      await directory.delete(recursive: true);
    });

    test('17 completed regions and a locked or unfinished NIR never unlock final play', () async {
      await unlock();
      await regions.updateStars(18, 0);
      final repo = container.read(finalChallengeRepositoryProvider);
      expect(finalChallengeUnlocked(await regions.getAllRegions()), isFalse);
      await expectLater(repo.start(), throwsStateError);
      expect(await repo.load(), isNull);
      await container.read(gameplayProvider.notifier).initFinalChallenge();
      expect(container.read(gameplayProvider).status, GameStatus.error);
      expect(await repo.load(), isNull);
      await regions.updateStars(18, 1);
      expect(finalChallengeUnlocked(await regions.getAllRegions()), isTrue);
      expect(await repo.start(seed: 42), isA<FinalChallengeRound>());
      expect(await regions.getAllRegions(), hasLength(18));
    });

    test('a repeated or concurrent discovery awards coins only once', () async {
      await unlock();
      final repo = container.read(finalChallengeRepositoryProvider);
      final round = await repo.start(seed: 42);
      final before = (await ProfileRepository(db).load()).coins;
      await Future.wait([
        repo.discover(round.clues.first.word),
        repo.discover(round.clues.first.word),
      ]);
      expect((await ProfileRepository(db).load()).coins, before + 5);
      expect((await repo.load())!.found, {round.clues.first.word});
    });

    test('older in-progress final rounds retain their original words, hints and found answers', () async {
      await unlock();
      final old = FinalChallengeRound(
        regionIds: selectFinalRegions(42),
        seed: 42,
        includeTriviaWords: false,
      );
      final first = old.clues.first.word;
      final json = old.toJson()..remove('include_trivia_words');
      json['found'] = [first];
      await db.database.insert(DatabaseConstants.tableUserProgress, {
        DatabaseConstants.columnKey: FinalChallengeRepository.progressKey,
        DatabaseConstants.columnValue: jsonEncode(json),
      });
      final repo = container.read(finalChallengeRepositoryProvider);
      final resumed = await repo.start();
      expect(resumed.includeTriviaWords, isFalse);
      expect(resumed.found, {first});
      expect(
        resumed.clues.map((word) => word.word),
        old.clues.map((word) => word.word),
      );
      await repo.hint(old.clues[1].word);
      await repo.discover(old.clues[2].word);
      final saved = (await repo.load())!;
      expect(saved.includeTriviaWords, isFalse);
      expect(saved.hints, {old.clues[1].word});
      expect(saved.found, {first, old.clues[2].word});
    });

    test('resume restores the same grid, clues, discoveries and hints; only 15/15 completes, without a 19th region', () async {
      await unlock();
      final profile = ProfileRepository(db);
      const avatar = PlayerAvatar(baseId: 'male', hairStyleIndex: 2);
      await profile.saveAvatar(avatar);
      await profile.saveValue(AppConstants.keyCoins, '137');
      await container.read(profileProvider.notifier).loadProfile();
      final beforeRegions = await db.database.query('regions');
      var game = container.read(gameplayProvider.notifier);
      await game.initFinalChallenge(seed: 42);
      var state = container.read(gameplayProvider);
      final originalGrid = jsonEncode(state.puzzle!.grid);
      final originalWords = state.targetWords.map((w) => w.word).toList();
      expect(state.targetWords, hasLength(15));
      expect(state.isFinalChallenge, isTrue);
      final first = state.puzzle!.placedWords.first;
      game.updateDragSelection(first.coordinates.first, first.coordinates.last);
      expect(await game.finalizeSelection(), isTrue);
      final repo = container.read(finalChallengeRepositoryProvider);
      final hintedWord = state.puzzle!.placedWords[1].word;
      await repo.hint(hintedWord);
      container.dispose();
      await db.close();
      await open();
      game = container.read(gameplayProvider.notifier);
      await game.initFinalChallenge();
      state = container.read(gameplayProvider);
      expect(jsonEncode(state.puzzle!.grid), originalGrid);
      expect(state.targetWords.map((w) => w.word), originalWords);
      expect(state.foundWords, {first.word});
      expect(state.revealedHints, hasLength(1));
      expect(container.read(profileProvider).avatar, avatar);
      for (final placed in state.puzzle!.placedWords.where((p) => !p.isFound)) {
        game.updateDragSelection(
          placed.coordinates.first,
          placed.coordinates.last,
        );
        expect(await game.finalizeSelection(), isTrue);
        if (container.read(gameplayProvider).foundWords.length < 15) {
          expect(container.read(gameplayProvider).status, GameStatus.playing);
        }
      }
      state = container.read(gameplayProvider);
      expect(state.status, GameStatus.completed);
      expect(state.foundWords, hasLength(15));
      expect(state.starsEarned, 2);
      expect(state.coins, 137 + 14 * 5 + 20 - 10);
      expect(game.hasNextLevel, isFalse);
      expect(await db.database.query('regions'), beforeRegions);
      final saved = (await container
          .read(finalChallengeRepositoryProvider)
          .load())!;
      expect(saved.completed, isTrue);
      expect(saved.bestStars, 2);
      await game.initFinalChallenge(replay: true, seed: 99);
      expect(container.read(gameplayProvider).foundWords, isEmpty);
      expect(
        (await container.read(finalChallengeRepositoryProvider).load())!
            .bestStars,
        2,
      );
      expect(await db.database.query('regions'), beforeRegions);
    });

    testWidgets('locked final screen has no start action', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: FinalChallengeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('final_challenge_locked')), findsOneWidget);
      expect(find.byKey(const Key('start_final_challenge')), findsNothing);
    });

    testWidgets(
      'unlocked final screen opens the shared puzzle route without changing region records',
      (tester) async {
        await tester.runAsync(() async {
          await unlock();
          await container.read(regionsProvider.future);
          await container.read(finalChallengeProgressProvider.future);
        });
        final before = await tester.runAsync(
          () => db.database.query('regions'),
        );
        String? destination;
        Object? arguments;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: const FinalChallengeScreen(),
              onGenerateRoute: (settings) {
                destination = settings.name;
                arguments = settings.arguments;
                return MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('Final puzzle')),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        final start = find.byKey(const Key('start_final_challenge'));
        await tester.ensureVisible(start);
        await tester.tap(start);
        await tester.pumpAndSettle();
        expect(destination, AppRouter.finalGame);
        expect(arguments, isFalse);
        expect(
          await tester.runAsync(() => db.database.query('regions')),
          before,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'the last regional completion offers the unlocked final challenge',
      (tester) async {
        await tester.runAsync(() async {
          await unlock();
          await container.read(regionsProvider.future);
        });
        final initial = GameplayState(
          status: GameStatus.playing,
          region: defaultPhilippineRegions.last,
        );
        final preview = ProviderContainer(
          overrides: [
            gameplayProvider.overrideWith(() => _FinalPreview(initial)),
            regionsProvider.overrideWith(() => _CompletedRegions()),
          ],
        );
        addTearDown(preview.dispose);
        String? destination;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: preview,
            child: MaterialApp(
              home: const WordSearchScreen(regionId: 18),
              onGenerateRoute: (settings) {
                destination = settings.name;
                return MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('Final intro')),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        preview
            .read(gameplayProvider.notifier)
            .updateStateForTesting(
              initial.copyWith(status: GameStatus.completed, starsEarned: 3),
            );
        await tester.pumpAndSettle();
        final action = find.byKey(const Key('button_open_final_challenge'));
        await tester.ensureVisible(action);
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(destination, AppRouter.finalChallenge);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '15 plain word boxes include trivia vocabulary, both word types reveal matching photos, and the last photo precedes completion',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.runAsync(() async {
          await unlock();
          await container
              .read(gameplayProvider.notifier)
              .initFinalChallenge(seed: 42);
        });
        final prepared = container.read(gameplayProvider);
        final photos = await tester.runAsync(
          () => container.read(regionLandmarksProvider.future),
        );
        final preview = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            gameplayProvider.overrideWith(() => _FinalPreview(prepared)),
            regionLandmarksProvider.overrideWith((_) async => photos!),
            settingsProvider.overrideWith(_SilentSettings.new),
          ],
        );
        addTearDown(preview.dispose);
        await tester.runAsync(
          () => preview.read(profileProvider.notifier).loadProfile(),
        );
        await tester.runAsync(
          () => preview.read(finalTriviaPhotoCreditsProvider.future),
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: preview,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: const WordSearchScreen(regionId: 1, isFinalChallenge: true),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final word in prepared.targetWords) {
          expect(find.text(word.word), findsOneWidget);
          expect(find.text(word.displayClueEn), findsNothing);
        }
        expect(
          prepared.targetWords.where((word) => word.category == 'Trivia'),
          hasLength(7),
        );
        expect(find.text('Word'), findsNothing);
        expect(find.textContaining(RegExp(r'^Trivia ·')), findsNothing);
        expect(find.byKey(const Key('final_discovery_popup')), findsNothing);
        final word = prepared.targetWords.first;
        // An unfound word chip cannot reveal a photo before discovery.
        await tester.ensureVisible(find.text(word.word));
        await tester.tap(find.text(word.word));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('final_discovery_popup')), findsNothing);
        final game = preview.read(gameplayProvider.notifier);
        final placed = prepared.puzzle!.placedWords.firstWhere(
          (p) => p.word == word.word,
        );
        game.updateDragSelection(
          placed.coordinates.first,
          placed.coordinates.last,
        );
        await tester.runAsync(() async {
          expect(await game.finalizeSelection(), isTrue);
        });
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey('final_discovery_photo_${word.regionId}')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('final_discovered_word')), findsOneWidget);
        final box = tester.getRect(
          find.byKey(const Key('final_discovery_box')),
        );
        expect(box.width, lessThanOrEqualTo(420));
        expect(box.left, greaterThanOrEqualTo(20));
        expect(box.right, lessThanOrEqualTo(300));
        expect(box.center.dx, closeTo(160, 1));
        expect(box.center.dy, closeTo(370, 2));
        expect(box.height, lessThanOrEqualTo(740 * .8));
        expect(find.text(word.displayClueEn), findsWidgets);
        final balance = preview.read(profileProvider).coins;
        final next = find.byKey(const Key('continue_final_discovery'));
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {});
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('final_discovery_popup')), findsNothing);
        expect(preview.read(profileProvider).coins, balance);
        // A rebuild and an already-found selection cannot open another popup.
        game.updateStateForTesting(preview.read(gameplayProvider));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('final_discovery_popup')), findsNothing);

        // A trivia word is an ordinary word target with its own cultural photo.
        final triviaWord = prepared.targetWords[1];
        final triviaPlaced = prepared.puzzle!.placedWords.firstWhere(
          (p) => p.word == triviaWord.word,
        );
        game.updateDragSelection(
          triviaPlaced.coordinates.first,
          triviaPlaced.coordinates.last,
        );
        await tester.runAsync(() async {
          expect(await game.finalizeSelection(), isTrue);
        });
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey('final_discovery_photo_${triviaWord.regionId}')),
          findsOneWidget,
        );
        final image = tester.widget<Image>(
          find.byKey(ValueKey('final_discovery_photo_${triviaWord.regionId}')),
        );
        expect(
          ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
          triviaWord.imagePath,
        );
        expect(find.text(triviaWord.displayFactEn), findsOneWidget);
        expect(
          preview.read(gameplayProvider).foundWords,
          contains(triviaWord.word),
        );
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {});
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('final_discovery_popup')), findsNothing);

        // Resume a legitimately saved 14/15 round without replaying old photos.
        final last = prepared.targetWords.last;
        final found14 = prepared.targetWords
            .where((w) => w.word != last.word)
            .map((w) => w.word)
            .toSet();
        await tester.runAsync(() async {
          final repo = preview.read(finalChallengeRepositoryProvider);
          for (final answer in found14) {
            await repo.discover(answer);
          }
          await preview.read(profileProvider.notifier).loadProfile();
        });
        game.updateStateForTesting(
          const GameplayState(
            status: GameStatus.loading,
            isFinalChallenge: true,
          ),
        );
        game.updateStateForTesting(
          prepared.copyWith(
            foundWords: found14,
            puzzle: prepared.puzzle!.copyWith(
              placedWords: [
                for (final p in prepared.puzzle!.placedWords)
                  p.copyWith(isFound: found14.contains(p.word)),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('final_discovery_popup')), findsNothing);
        final lastPlaced = prepared.puzzle!.placedWords.firstWhere(
          (p) => p.word == last.word,
        );
        game.updateDragSelection(
          lastPlaced.coordinates.first,
          lastPlaced.coordinates.last,
        );
        await tester.runAsync(() async {
          expect(await game.finalizeSelection(), isTrue);
        });
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey('final_discovery_photo_${last.regionId}')),
          findsOneWidget,
        );
        expect(find.text('Final Challenge Complete!'), findsNothing);
        expect(preview.read(gameplayProvider).status, GameStatus.completed);
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {});
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('final_discovery_popup')), findsNothing);
        expect(find.text('Final Challenge Complete!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
