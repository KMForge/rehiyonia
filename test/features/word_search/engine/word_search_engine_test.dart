import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/word_search/engine/selection_validator.dart';
import 'package:rehiyonia/features/word_search/engine/word_placement.dart';
import 'package:rehiyonia/features/word_search/engine/word_search_engine.dart';
import 'package:rehiyonia/features/word_search/models/puzzle_coordinate.dart';
import 'package:rehiyonia/features/word_search/models/word_search_direction.dart';

void main() {
  group('Pure Word Search Engine Tests', () {
    const engine = WordSearchEngine();

    test('generates puzzle containing 100% of input words', () {
      final inputWords = ['MANILA', 'QUEZON', 'MAKATI', 'PASIG', 'TAGUIG'];
      final puzzle = engine.createPuzzle(
        words: inputWords,
        rows: 10,
        cols: 10,
        seed: 42,
      );

      expect(puzzle.placedWords.length, inputWords.length);

      final placedWordTexts = puzzle.placedWords.map((p) => p.word).toSet();
      for (final word in inputWords) {
        expect(placedWordTexts, contains(word));
      }

      // Verify each placed word matches characters in the generated grid
      for (final placed in puzzle.placedWords) {
        final extracted = SelectionValidator.getSpelledWord(
          puzzle.grid,
          placed.coordinates,
        );
        expect(extracted, placed.word);
      }
    });

    test('deterministic seed produces identical grid and word placements', () {
      final words = ['ILOCOS', 'CAGAYAN', 'BICOL'];
      final puzzle1 = engine.createPuzzle(
        words: words,
        rows: 8,
        cols: 8,
        seed: 12345,
      );
      final puzzle2 = engine.createPuzzle(
        words: words,
        rows: 8,
        cols: 8,
        seed: 12345,
      );

      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          expect(puzzle1.grid[r][c], puzzle2.grid[r][c]);
        }
      }
    });

    test('rejects word placement that exceeds grid boundaries', () {
      final fits = WordPlacement.fitsInBounds(
        rows: 5,
        cols: 5,
        wordLength: 6,
        startRow: 0,
        startCol: 0,
        direction: WordSearchDirection.horizontalForward,
      );
      expect(fits, isFalse);
    });

    test('allows overlapping words when intersecting characters match', () {
      final grid = List.generate(5, (_) => List<String?>.filled(5, null));

      // Place "CAT" horizontally at (1, 1) -> (1, 1)=C, (1, 2)=A, (1, 3)=T
      grid[1][1] = 'C';
      grid[1][2] = 'A';
      grid[1][3] = 'T';

      // Place "BAT" vertically at (0, 2) -> (0, 2)=B, (1, 2)=A (matches!), (2, 2)=T
      final canPlace = WordPlacement.canPlaceWord(
        grid: grid,
        word: 'BAT',
        startRow: 0,
        startCol: 2,
        direction: WordSearchDirection.verticalDown,
      );
      expect(canPlace, isTrue);

      // Try placing "DOG" vertically at (0, 2) -> (1, 2) has 'A', collides with 'O'
      final cannotPlace = WordPlacement.canPlaceWord(
        grid: grid,
        word: 'DOG',
        startRow: 0,
        startCol: 2,
        direction: WordSearchDirection.verticalDown,
      );
      expect(cannotPlace, isFalse);
    });

    test('SelectionValidator detects valid straight lines and rejects crooked lines', () {
      // Valid horizontal line
      final validHorizontal = [
        const PuzzleCoordinate(2, 2),
        const PuzzleCoordinate(2, 3),
        const PuzzleCoordinate(2, 4),
      ];
      expect(SelectionValidator.isValidLine(validHorizontal), isTrue);

      // Valid diagonal line
      final validDiagonal = [
        const PuzzleCoordinate(1, 1),
        const PuzzleCoordinate(2, 2),
        const PuzzleCoordinate(3, 3),
      ];
      expect(SelectionValidator.isValidLine(validDiagonal), isTrue);

      // Crooked line (turns corner)
      final crookedLine = [
        const PuzzleCoordinate(1, 1),
        const PuzzleCoordinate(1, 2),
        const PuzzleCoordinate(2, 2),
      ];
      expect(SelectionValidator.isValidLine(crookedLine), isFalse);
    });

    test(
      'SelectionValidator.getLineBetween creates continuous coordinates',
      () {
        final line = SelectionValidator.getLineBetween(
          const PuzzleCoordinate(0, 0),
          const PuzzleCoordinate(0, 3),
        );
        expect(line, isNotNull);
        expect(line!.length, 4);
        expect(line[0], const PuzzleCoordinate(0, 0));
        expect(line[3], const PuzzleCoordinate(0, 3));
      },
    );

    test('checkSelection identifies forward and reverse swiped words', () {
      final puzzle = engine.createPuzzle(
        words: ['CEBU'],
        rows: 6,
        cols: 6,
        allowedDirections: [WordSearchDirection.horizontalForward],
        seed: 99,
      );

      final placed = puzzle.placedWords.first;

      // Forward swipe
      final matchForward = engine.checkSelection(
        puzzle: puzzle,
        selectedCoordinates: placed.coordinates,
      );
      expect(matchForward, isNotNull);
      expect(matchForward!.word, 'CEBU');

      // Reverse swipe
      final matchReverse = engine.checkSelection(
        puzzle: puzzle,
        selectedCoordinates: placed.coordinates.reversed.toList(),
      );
      expect(matchReverse, isNotNull);
      expect(matchReverse!.word, 'CEBU');
    });
  });
}
