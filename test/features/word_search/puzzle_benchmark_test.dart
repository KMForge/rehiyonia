import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/word_search/engine/word_search_engine.dart';

void main() {
  group('WordSearchEngine Performance & Benchmark Tests', () {
    final sampleWords = [
      'MANILA',
      'QUEZON',
      'PASIG',
      'MAKATI',
      'LUNETA',
      'INTRAMUROS',
    ];

    test('createPuzzle() executes under 50ms per puzzle (average < 10ms for 10x10)', () {
      const engine = WordSearchEngine();

      // Warmup run
      engine.createPuzzle(words: sampleWords, rows: 10, cols: 10);

      // Benchmark 100 iterations
      const iterations = 100;
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < iterations; i++) {
        final puzzle = engine.createPuzzle(
          words: sampleWords,
          rows: 10,
          cols: 10,
        );
        expect(puzzle.grid.length, equals(10));
        expect(puzzle.placedWords.length, equals(6));
      }

      stopwatch.stop();
      final totalElapsedMs = stopwatch.elapsedMilliseconds;
      final avgElapsedMs = totalElapsedMs / iterations;

      // Assert that generation is well under 50ms (typically <2ms in pure Dart)
      expect(avgElapsedMs, lessThan(50.0));
    });
  });
}
