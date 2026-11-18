import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/badges/region_landmark.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/settings/models/audio_preferences.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/word_search/engine/word_search_engine.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/providers/gameplay_provider.dart';
import 'package:rehiyonia/features/word_search/screens/word_search_screen.dart';
import 'package:rehiyonia/shared/widgets/word_discovery_content.dart';

class _Game extends GameplayNotifier {
  _Game(this.initial);
  final GameplayState initial;
  @override
  GameplayState build() => initial;
  @override
  Future<void> initGame(int regionId, {int? seed}) async {}
}

class _Regions extends RegionsNotifier {
  @override
  Future<List<Region>> build() async => defaultPhilippineRegions;
}

class _QuietSettings extends SettingsNotifier {
  @override
  AudioPreferences build() =>
      const AudioPreferences(isSoundEffectsEnabled: false);
}

void main() {
  testWidgets(
    'all 18 regions retain 15 word labels, show each discovered photo once, and show the last photo before completion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      late List<RegionalWord> bundled;
      late Set<String> assets;
      late Map<int, RegionLandmark> photos;
      await tester.runAsync(() async {
        bundled =
            (jsonDecode(
                  await rootBundle.loadString(
                    'assets/data/regional_words.json',
                  ),
                ) as List)
                .cast<Map<String, dynamic>>()
                .map(RegionalWord.fromMap)
                .toList();
        assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
            .listAssets()
            .toSet();
        photos = parseRegionLandmarks(
          await rootBundle.loadString('assets/data/region_landmarks.json'),
        );
      });
      for (final region in defaultPhilippineRegions) {
        final words = bundled
            .where((word) => word.regionId == region.id)
            .toList();
        final dimension = max(
          12,
          words.map((word) => word.word.length).reduce(max),
        );
        final initial = GameplayState(
          status: GameStatus.playing,
          region: region,
          targetWords: words,
          puzzle: const WordSearchEngine().createPuzzle(
            words: words.map((word) => word.word).toList(),
            rows: dimension,
            cols: dimension,
            seed: region.id,
          ),
        );
        final container = ProviderContainer(
          overrides: [
            gameplayProvider.overrideWith(() => _Game(initial)),
            regionsProvider.overrideWith(_Regions.new),
            settingsProvider.overrideWith(_QuietSettings.new),
            discoveryImageAssetsProvider.overrideWith((_) async => assets),
            regionLandmarksProvider.overrideWith((_) async => photos),
          ],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: WordSearchScreen(regionId: region.id),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(words, hasLength(15));
        for (final word in words) {
          expect(find.text(word.word), findsOneWidget);
        }
        expect(find.byType(WordDiscoveryContent), findsNothing);
        final game = container.read(gameplayProvider.notifier);
        final first = words.firstWhere(
          (word) => assets.contains(word.resolvedImagePath),
        );
        game.updateStateForTesting(initial.copyWith(foundWords: {first.word}));
        await tester.pumpAndSettle();
        final photoFinder = find.byKey(
          ValueKey('final_discovery_photo_${region.id}'),
        );
        expect(find.byType(WordDiscoveryContent), findsOneWidget);
        final image = tester.widget<Image>(photoFinder);
        expect(
          ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
          first.resolvedImagePath,
        );
        expect(
          tester
              .widget<Text>(find.byKey(const Key('final_discovered_word')))
              .data,
          first.word,
        );
        game.updateStateForTesting(
          initial.copyWith(foundWords: {first.word}, coins: 55),
        );
        await tester.pumpAndSettle();
        expect(find.byType(WordDiscoveryContent), findsOneWidget);
        Future<void> closePhoto() async {
          final next = find.byKey(const Key('continue_final_discovery'));
          await tester.ensureVisible(next);
          await tester.tap(next);
          await tester.pumpAndSettle();
          await tester.runAsync(() async {});
          await tester.pumpAndSettle();
        }

        await closePhoto();
        expect(find.byType(WordDiscoveryContent), findsNothing);
        game.updateStateForTesting(
          initial.copyWith(foundWords: {first.word}, coins: 55),
        );
        await tester.pumpAndSettle();
        expect(find.byType(WordDiscoveryContent), findsNothing);

        final last = words.last;
        final found14 = words
            .where((word) => word.word != last.word)
            .map((word) => word.word)
            .toSet();
        game.updateStateForTesting(
          GameplayState(status: GameStatus.loading, region: region),
        );
        game.updateStateForTesting(initial.copyWith(foundWords: found14));
        await tester.pumpAndSettle();
        expect(find.byType(WordDiscoveryContent), findsNothing);
        game.updateStateForTesting(
          initial.copyWith(
            foundWords: words.map((word) => word.word).toSet(),
            status: GameStatus.completed,
            starsEarned: 3,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(WordDiscoveryContent), findsOneWidget);
        expect(find.text('🎉 Level Complete!'), findsNothing);
        expect(
          tester
              .widget<Text>(find.byKey(const Key('final_discovered_word')))
              .data,
          last.word,
        );
        final lastImage = tester.widget<Image>(photoFinder);
        final expectedAsset = assets.contains(last.resolvedImagePath)
            ? last.resolvedImagePath
            : photos[region.id]!.assetPath;
        expect(
          ((lastImage.image as ResizeImage).imageProvider as AssetImage)
              .assetName,
          expectedAsset,
        );
        if (!assets.contains(last.resolvedImagePath)) {
          expect(find.textContaining('Regional landmark:'), findsOneWidget);
        }
        await closePhoto();
        expect(find.text('🎉 Level Complete!'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: region.code);
        Navigator.of(tester.element(find.byType(AlertDialog))).pop();
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        container.dispose();
      }
    },
  );
}
