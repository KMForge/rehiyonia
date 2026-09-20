import '../models/puzzle_coordinate.dart';
import '../models/word_search_direction.dart';

abstract final class SelectionValidator {
  /// Validates whether a list of selected coordinates forms a continuous straight
  /// line along one of the 8 valid directions.
  static bool isValidLine(List<PuzzleCoordinate> coordinates) {
    if (coordinates.length < 2) return true;

    final first = coordinates[0];
    final second = coordinates[1];

    final dRow = second.row - first.row;
    final dCol = second.col - first.col;

    // Both deltas must be in {-1, 0, 1} and not (0, 0)
    if (dRow.abs() > 1 || dCol.abs() > 1 || (dRow == 0 && dCol == 0)) {
      return false;
    }

    for (int i = 1; i < coordinates.length; i++) {
      final prev = coordinates[i - 1];
      final curr = coordinates[i];

      if (curr.row - prev.row != dRow || curr.col - prev.col != dCol) {
        return false;
      }
    }

    return true;
  }

  /// Extracts the word string formed by the coordinates on the grid.
  static String getSpelledWord(
    List<List<String>> grid,
    List<PuzzleCoordinate> coordinates,
  ) {
    final buffer = StringBuffer();
    for (final coord in coordinates) {
      if (coord.row >= 0 &&
          coord.row < grid.length &&
          coord.col >= 0 &&
          coord.col < grid[0].length) {
        buffer.write(grid[coord.row][coord.col]);
      }
    }
    return buffer.toString();
  }

  /// Calculates a continuous coordinate line between a start and end point if straight.
  static List<PuzzleCoordinate>? getLineBetween(
    PuzzleCoordinate start,
    PuzzleCoordinate end,
  ) {
    final dRow = end.row - start.row;
    final dCol = end.col - start.col;

    final stepRow = dRow == 0 ? 0 : (dRow > 0 ? 1 : -1);
    final stepCol = dCol == 0 ? 0 : (dCol > 0 ? 1 : -1);

    final absRow = dRow.abs();
    final absCol = dCol.abs();

    // Must be horizontal, vertical, or 45-degree diagonal
    final isHorizontal = absRow == 0 && absCol > 0;
    final isVertical = absCol == 0 && absRow > 0;
    final isDiagonal = absRow == absCol && absRow > 0;

    if (!isHorizontal && !isVertical && !isDiagonal) {
      return null;
    }

    final length = (absRow > absCol ? absRow : absCol) + 1;
    final line = <PuzzleCoordinate>[];

    for (int i = 0; i < length; i++) {
      line.add(
        PuzzleCoordinate(start.row + (i * stepRow), start.col + (i * stepCol)),
      );
    }

    return line;
  }

  /// Determines the direction from start to end coordinate if straight.
  static WordSearchDirection? getDirection(
    PuzzleCoordinate start,
    PuzzleCoordinate end,
  ) {
    final dRow = end.row - start.row;
    final dCol = end.col - start.col;

    final stepRow = dRow == 0 ? 0 : (dRow > 0 ? 1 : -1);
    final stepCol = dCol == 0 ? 0 : (dCol > 0 ? 1 : -1);

    for (final dir in WordSearchDirection.values) {
      if (dir.dRow == stepRow && dir.dCol == stepCol) {
        return dir;
      }
    }
    return null;
  }
}
