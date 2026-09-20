import '../models/puzzle_coordinate.dart';
import '../models/word_search_direction.dart';

abstract final class WordPlacement {
  /// Checks if a word fits within the grid dimensions without exceeding bounds.
  static bool fitsInBounds({
    required int rows,
    required int cols,
    required int wordLength,
    required int startRow,
    required int startCol,
    required WordSearchDirection direction,
  }) {
    final endRow = startRow + (direction.dRow * (wordLength - 1));
    final endCol = startCol + (direction.dCol * (wordLength - 1));

    return startRow >= 0 &&
        startRow < rows &&
        startCol >= 0 &&
        startCol < cols &&
        endRow >= 0 &&
        endRow < rows &&
        endCol >= 0 &&
        endCol < cols;
  }

  /// Generates the list of coordinates the word would occupy from start to end.
  static List<PuzzleCoordinate> getCoordinates({
    required int wordLength,
    required int startRow,
    required int startCol,
    required WordSearchDirection direction,
  }) {
    final coords = <PuzzleCoordinate>[];
    for (int i = 0; i < wordLength; i++) {
      coords.add(
        PuzzleCoordinate(
          startRow + (direction.dRow * i),
          startCol + (direction.dCol * i),
        ),
      );
    }
    return coords;
  }

  /// Checks if placing the word at the specified position collides with any
  /// non-matching characters already in the grid.
  static bool canPlaceWord({
    required List<List<String?>> grid,
    required String word,
    required int startRow,
    required int startCol,
    required WordSearchDirection direction,
  }) {
    final rows = grid.length;
    final cols = grid[0].length;

    if (!fitsInBounds(
      rows: rows,
      cols: cols,
      wordLength: word.length,
      startRow: startRow,
      startCol: startCol,
      direction: direction,
    )) {
      return false;
    }

    final coords = getCoordinates(
      wordLength: word.length,
      startRow: startRow,
      startCol: startCol,
      direction: direction,
    );

    for (int i = 0; i < word.length; i++) {
      final cell = grid[coords[i].row][coords[i].col];
      // Cell must either be empty or match the exact character
      if (cell != null && cell != word[i]) {
        return false;
      }
    }

    return true;
  }
}
