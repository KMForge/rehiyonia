import 'dart:math';

import '../models/placed_word.dart';
import '../models/word_search_direction.dart';
import '../models/word_search_puzzle.dart';
import 'word_placement.dart';

class GridGenerator {
  const GridGenerator();

  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Generates a complete word search puzzle containing 100% of the input words.
  WordSearchPuzzle generate({
    required List<String> words,
    required int rows,
    required int cols,
    List<WordSearchDirection>? allowedDirections,
    Random? random,
    int maxAttempts = 100,
  }) {
    final rng = random ?? Random();
    final directions = allowedDirections ?? WordSearchDirection.values;

    // Clean and normalize input words (uppercase, letters only)
    final normalizedWords = words
        .map((w) => w.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), ''))
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();

    // Sort by length descending for optimal placement
    normalizedWords.sort((a, b) => b.length.compareTo(a.length));

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final puzzle = _tryGenerateGrid(
        words: normalizedWords,
        rows: rows,
        cols: cols,
        directions: directions,
        rng: rng,
      );

      if (puzzle != null) {
        return puzzle;
      }
    }

    throw StateError(
      'Failed to place all words within a ${rows}x$cols grid after $maxAttempts attempts. '
      'Consider increasing grid dimensions or reducing word count.',
    );
  }

  WordSearchPuzzle? _tryGenerateGrid({
    required List<String> words,
    required int rows,
    required int cols,
    required List<WordSearchDirection> directions,
    required Random rng,
  }) {
    final grid = List.generate(rows, (_) => List<String?>.filled(cols, null));

    final placedWords = <PlacedWord>[];

    for (final word in words) {
      if (word.length > rows && word.length > cols) {
        return null; // Word cannot physically fit in the grid
      }

      final positions = <({int r, int c, WordSearchDirection dir})>[];

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          for (final dir in directions) {
            if (WordPlacement.canPlaceWord(
              grid: grid,
              word: word,
              startRow: r,
              startCol: c,
              direction: dir,
            )) {
              positions.add((r: r, c: c, dir: dir));
            }
          }
        }
      }

      if (positions.isEmpty) {
        return null; // Cannot place this word in this configuration
      }

      // Pick a random valid position
      final chosen = positions[rng.nextInt(positions.length)];
      final coords = WordPlacement.getCoordinates(
        wordLength: word.length,
        startRow: chosen.r,
        startCol: chosen.c,
        direction: chosen.dir,
      );

      for (int i = 0; i < word.length; i++) {
        grid[coords[i].row][coords[i].col] = word[i];
      }

      placedWords.add(
        PlacedWord(word: word, coordinates: coords, direction: chosen.dir),
      );
    }

    // Fill remaining empty cells with random uppercase letters
    final finalGrid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => grid[r][c] ?? _alphabet[rng.nextInt(_alphabet.length)],
      ),
    );

    return WordSearchPuzzle(
      grid: finalGrid,
      placedWords: placedWords,
      rows: rows,
      cols: cols,
    );
  }
}
