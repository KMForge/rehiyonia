import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../regions/models/region.dart';
import '../../regions/providers/region_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/selection_validator.dart';
import '../engine/word_search_engine.dart';
import '../models/puzzle_coordinate.dart';
import '../models/regional_word.dart';
import '../models/word_search_puzzle.dart';
import 'word_provider.dart';

enum GameStatus { loading, playing, paused, completed, error }

class GameplayState {
  const GameplayState({
    required this.status,
    this.region,
    this.puzzle,
    this.targetWords = const [],
    this.foundWords = const {},
    this.activeSelection = const [],
    this.revealedHints = const {},
    this.elapsedSeconds = 0,
    this.score = 0,
    this.starsEarned = 0,
    this.coins = 50,
    this.errorMessage,
  });

  final GameStatus status;
  final Region? region;
  final WordSearchPuzzle? puzzle;
  final List<RegionalWord> targetWords;
  final Set<String> foundWords;
  final List<PuzzleCoordinate> activeSelection;
  final Set<PuzzleCoordinate> revealedHints;
  final int elapsedSeconds;
  final int score;
  final int starsEarned;
  final int coins;
  final String? errorMessage;

  bool get isAllWordsFound =>
      puzzle != null &&
      targetWords.isNotEmpty &&
      foundWords.length >= puzzle!.placedWords.length;

  GameplayState copyWith({
    GameStatus? status,
    Region? region,
    WordSearchPuzzle? puzzle,
    List<RegionalWord>? targetWords,
    Set<String>? foundWords,
    List<PuzzleCoordinate>? activeSelection,
    Set<PuzzleCoordinate>? revealedHints,
    int? elapsedSeconds,
    int? score,
    int? starsEarned,
    int? coins,
    String? errorMessage,
  }) {
    return GameplayState(
      status: status ?? this.status,
      region: region ?? this.region,
      puzzle: puzzle ?? this.puzzle,
      targetWords: targetWords ?? this.targetWords,
      foundWords: foundWords ?? this.foundWords,
      activeSelection: activeSelection ?? this.activeSelection,
      revealedHints: revealedHints ?? this.revealedHints,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      score: score ?? this.score,
      starsEarned: starsEarned ?? this.starsEarned,
      coins: coins ?? this.coins,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class GameplayNotifier extends Notifier<GameplayState> {
  GameplayNotifier({WordSearchEngine? engine})
    : _engine = engine ?? const WordSearchEngine();

  final WordSearchEngine _engine;

  @override
  GameplayState build() {
    return const GameplayState(status: GameStatus.loading);
  }

  Future<void> initGame(int regionId, {int? seed}) async {
    state = state.copyWith(status: GameStatus.loading);

    try {
      final regionRepo = ref.read(regionRepositoryProvider);
      final wordRepo = ref.read(wordRepositoryProvider);

      final regions = await regionRepo.getAllRegions();
      final region = regions.firstWhere(
        (r) => r.id == regionId,
        orElse: () => defaultPhilippineRegions.firstWhere(
          (r) => r.id == regionId,
          orElse: () => defaultPhilippineRegions.first,
        ),
      );

      var words = await wordRepo.getWordsForRegion(regionId);
      if (words.isEmpty) {
        // Fallback words if database not yet populated
        words = [
          RegionalWord(
            regionId: regionId,
            word: region.code.replaceAll('_', ''),
            category: 'Rehiyon',
            clue: region.name,
          ),
          RegionalWord(
            regionId: regionId,
            word: region.islandGroup.toUpperCase(),
            category: 'Pangkat ng Pulo',
            clue: 'Pangkat kung saan nabibilang ang rehiyon',
          ),
        ];
      }

      final wordStrings = words.map((w) => w.word.toUpperCase()).toList();
      final maxWordLen = wordStrings.map((w) => w.length).reduce(max);
      final gridSize = max(10, maxWordLen);

      final puzzle = _engine.createPuzzle(
        words: wordStrings,
        rows: gridSize,
        cols: gridSize,
        seed: seed,
      );

      state = GameplayState(
        status: GameStatus.playing,
        region: region,
        puzzle: puzzle,
        targetWords: words,
        foundWords: {},
        activeSelection: [],
        revealedHints: {},
        elapsedSeconds: 0,
        score: 0,
        starsEarned: 0,
        coins: 50,
      );
    } catch (e) {
      state = state.copyWith(
        status: GameStatus.error,
        errorMessage: 'May aberya sa pagsisimula ng laro: $e',
      );
    }
  }

  void updateDragSelection(PuzzleCoordinate from, PuzzleCoordinate to) {
    if (state.status != GameStatus.playing || state.puzzle == null) return;

    if (from == to) {
      state = state.copyWith(activeSelection: [from]);
      return;
    }

    final line = SelectionValidator.getLineBetween(from, to);
    if (line != null) {
      state = state.copyWith(activeSelection: line);
    } else {
      state = state.copyWith(activeSelection: [from]);
    }
  }

  Future<bool> finalizeSelection() async {
    if (state.status != GameStatus.playing ||
        state.puzzle == null ||
        state.activeSelection.isEmpty) {
      state = state.copyWith(activeSelection: []);
      return false;
    }

    final selection = state.activeSelection;
    final placed = _engine.checkSelection(
      puzzle: state.puzzle!,
      selectedCoordinates: selection,
    );

    if (placed != null && !state.foundWords.contains(placed.word)) {
      final updatedFound = Set<String>.from(state.foundWords)..add(placed.word);
      final updatedPlacedWords = state.puzzle!.placedWords.map((p) {
        if (p.word == placed.word) {
          return p.copyWith(isFound: true);
        }
        return p;
      }).toList();

      final updatedPuzzle = state.puzzle!.copyWith(
        placedWords: updatedPlacedWords,
      );

      final newScore = state.score + 100;
      final isCompleted =
          updatedFound.length >= updatedPuzzle.placedWords.length;

      int stars = state.starsEarned;
      if (isCompleted) {
        if (state.elapsedSeconds < 90 && state.revealedHints.isEmpty) {
          stars = 3;
        } else if (state.elapsedSeconds < 180) {
          stars = 2;
        } else {
          stars = 1;
        }

        // Persist stars to database
        if (state.region != null) {
          final regionRepo = ref.read(regionRepositoryProvider);
          await regionRepo.updateStars(state.region!.id, stars);
          // Unlock next region
          await regionRepo.unlockRegion(state.region!.id + 1);
        }
      }

      state = state.copyWith(
        puzzle: updatedPuzzle,
        foundWords: updatedFound,
        activeSelection: [],
        score: newScore,
        coins: isCompleted ? state.coins + 20 : state.coins + 5,
        starsEarned: stars,
        status: isCompleted ? GameStatus.completed : GameStatus.playing,
      );

      try {
        final audio = ref.read(audioServiceProvider);
        if (isCompleted) {
          await audio.playSoundEffect(AppConstants.audioSfxPuzzleComplete);
        } else {
          await audio.playSoundEffect(AppConstants.audioSfxWordFound);
        }
      } catch (_) {
        // Gracefully ignore audio playback errors in headless/test environments
      }

      return true;
    }

    state = state.copyWith(activeSelection: []);
    return false;
  }

  void useHint() {
    if (state.status != GameStatus.playing || state.puzzle == null) return;
    if (state.coins < 10) return;

    for (final placed in state.puzzle!.placedWords) {
      if (!state.foundWords.contains(placed.word)) {
        final firstCoord = placed.coordinates.first;
        if (!state.revealedHints.contains(firstCoord)) {
          state = state.copyWith(
            coins: state.coins - 10,
            revealedHints: Set<PuzzleCoordinate>.from(state.revealedHints)
              ..add(firstCoord),
          );
          return;
        }
      }
    }
  }

  void tickTimer() {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }

  void togglePause() {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(status: GameStatus.paused);
    } else if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
    }
  }
}

final gameplayProvider = NotifierProvider<GameplayNotifier, GameplayState>(
  GameplayNotifier.new,
);
