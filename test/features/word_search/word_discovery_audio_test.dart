import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/word_search/engine/word_search_engine.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/features/word_search/providers/gameplay_provider.dart';
import 'package:rehiyonia/features/word_search/screens/word_search_screen.dart';

class _Player extends Fake implements AudioPlayer {
  @override
  Future<void> setVolume(double value) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

class _Audio extends AudioService {
  _Audio() : super(musicPlayer: _Player(), sfxPlayer: _Player());
  final effects = <String>[];
  @override
  Future<void> playSoundEffect(String assetPath) async =>
      effects.add(assetPath);
}

class _Game extends GameplayNotifier {
  @override
  GameplayState build() => GameplayState(
    status: GameStatus.playing,
    region: defaultPhilippineRegions.first,
    puzzle: const WordSearchEngine().createPuzzle(
      words: ['MANILA', 'LUZON'],
      rows: 10,
      cols: 10,
      seed: 5,
    ),
    targetWords: const [
      RegionalWord(
        regionId: 1,
        word: 'MANILA',
        category: 'City',
        clue: 'Capital',
      ),
      RegionalWord(
        regionId: 1,
        word: 'LUZON',
        category: 'Island',
        clue: 'Island group',
      ),
    ],
  );
  @override
  Future<void> initGame(int regionId, {int? seed}) async {}
}

void main() {
  testWidgets(
    'sparkles once per new discovery, honors mute, includes final word',
    (tester) async {
      final audio = _Audio();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameplayProvider.overrideWith(_Game.new),
            audioServiceProvider.overrideWithValue(audio),
          ],
          child: const MaterialApp(home: WordSearchScreen(regionId: 1)),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WordSearchScreen)),
      );
      final game = container.read(gameplayProvider.notifier);
      final initial = container.read(gameplayProvider);
      expect(audio.effects, isEmpty);

      game.updateStateForTesting(initial.copyWith(foundWords: {'MANILA'}));
      await tester.pumpAndSettle();
      expect(audio.effects, [AppConstants.audioSfxWordFound]);
      // Duplicate acceptance, invalid drag cleanup, hints and rebuilding change
      // other state without introducing a new word.
      game.updateStateForTesting(
        container
            .read(gameplayProvider)
            .copyWith(coins: 40, activeSelection: []),
      );
      await tester.pumpAndSettle();
      expect(audio.effects.length, 1);

      container.read(settingsProvider.notifier).toggleSoundEffects();
      game.updateStateForTesting(
        container
            .read(gameplayProvider)
            .copyWith(foundWords: {'MANILA', 'LUZON'}),
      );
      await tester.pumpAndSettle();
      expect(audio.effects.length, 1);

      // Fresh game: resetting the found set does not emit a sound.
      game.updateStateForTesting(initial);
      container.read(settingsProvider.notifier).toggleSoundEffects();
      game.updateStateForTesting(initial.copyWith(foundWords: {'MANILA'}));
      await tester.pumpAndSettle();
      game.updateStateForTesting(
        container
            .read(gameplayProvider)
            .copyWith(
              foundWords: {'MANILA', 'LUZON'},
              status: GameStatus.completed,
              starsEarned: 3,
            ),
      );
      await tester.pumpAndSettle();
      expect(audio.effects.length, 3);
      expect(
        audio.effects.every((path) => path == AppConstants.audioSfxWordFound),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
