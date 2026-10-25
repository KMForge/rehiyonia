import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/word_search/engine/word_search_engine.dart';
import 'package:rehiyonia/features/word_search/models/puzzle_coordinate.dart';
import 'package:rehiyonia/features/word_search/widgets/word_search_grid_widget.dart';

void main() {
  testWidgets('drag coordinates align with the inner board on a small screen', (
    tester,
  ) async {
    final puzzle = const WordSearchEngine().createPuzzle(
      words: ['MANILA'],
      rows: 10,
      cols: 10,
      seed: 1,
    );
    PuzzleCoordinate? first, last;
    var ends = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: WordSearchGridWidget(
                puzzle: puzzle,
                activeSelection: const [],
                revealedHints: const {},
                onSelectionUpdate: (a, b) {
                  first = a;
                  last = b;
                },
                onSelectionEnd: () {
                  ends++;
                },
              ),
            ),
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(const Key('word_search_board')));
    final start = rect.topLeft + Offset(rect.width * .05, rect.height * .05);
    final end = rect.topLeft + Offset(rect.width * .95, rect.height * .95);
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await tester.pump();
    await gesture.up();
    expect(first, const PuzzleCoordinate(0, 0));
    expect(last, const PuzzleCoordinate(9, 9));
    expect(ends, 1);
    expect(tester.takeException(), isNull);
  });
}
