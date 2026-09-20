import 'dart:math';

import '../models/placed_word.dart';
import '../models/puzzle_coordinate.dart';
import '../models/word_search_direction.dart';
import '../models/word_search_puzzle.dart';
import 'grid_generator.dart';
import 'selection_validator.dart';

class WordSearchEngine {
  const WordSearchEngine({GridGenerator? generator})
    : _generator = generator ?? const GridGenerator();

  final GridGenerator _generator;

  /// Creates a word search puzzle with deterministic seeding or random layout.
  WordSearchPuzzle createPuzzle({
    required List<String> words,
    required int rows,
    required int cols,
    List<WordSearchDirection>? allowedDirections,
    int? seed,
  }) {
    return _generator.generate(
      words: words,
      rows: rows,
      cols: cols,
      allowedDirections: allowedDirections,
      random: seed != null ? Random(seed) : null,
    );
  }

  /// Checks whether a selected coordinate sequence matches an unfound placed word.
  /// Returns the matching PlacedWord if found, or null otherwise.
  PlacedWord? checkSelection({
    required WordSearchPuzzle puzzle,
    required List<PuzzleCoordinate> selectedCoordinates,
  }) {
    if (selectedCoordinates.isEmpty) return null;

    final spelled = SelectionValidator.getSpelledWord(
      puzzle.grid,
      selectedCoordinates,
    );

    for (final placed in puzzle.placedWords) {
      if (placed.isFound) continue;

      // Check forward match
      if (placed.word == spelled &&
          _coordinatesMatch(placed.coordinates, selectedCoordinates)) {
        return placed;
      }

      // Check backward match (if user swiped in reverse direction)
      final reversedSelection = selectedCoordinates.reversed.toList();
      final reversedSpelled = SelectionValidator.getSpelledWord(
        puzzle.grid,
        reversedSelection,
      );

      if (placed.word == reversedSpelled &&
          _coordinatesMatch(placed.coordinates, reversedSelection)) {
        return placed;
      }
    }

    return null;
  }

  bool _coordinatesMatch(List<PuzzleCoordinate> a, List<PuzzleCoordinate> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
