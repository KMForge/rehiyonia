import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/explorer_theme.dart';
import '../models/puzzle_coordinate.dart';
import '../models/word_search_puzzle.dart';

class WordSearchGridWidget extends StatefulWidget {
  const WordSearchGridWidget({
    super.key,
    required this.puzzle,
    required this.activeSelection,
    required this.revealedHints,
    required this.onSelectionUpdate,
    required this.onSelectionEnd,
  });
  final WordSearchPuzzle puzzle;
  final List<PuzzleCoordinate> activeSelection;
  final Set<PuzzleCoordinate> revealedHints;
  final void Function(PuzzleCoordinate from, PuzzleCoordinate to)
  onSelectionUpdate;
  final VoidCallback onSelectionEnd;
  @override
  State<WordSearchGridWidget> createState() => _WordSearchGridWidgetState();
}

class _WordSearchGridWidgetState extends State<WordSearchGridWidget> {
  PuzzleCoordinate? _start;
  PuzzleCoordinate? _coordinate(Offset p, Size size) {
    if (p.dx < 0 || p.dy < 0 || p.dx >= size.width || p.dy >= size.height) {
      return null;
    }
    return PuzzleCoordinate(
      (p.dy / size.height * widget.puzzle.rows).floor(),
      (p.dx / size.width * widget.puzzle.cols).floor(),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final rows = widget.puzzle.rows, cols = widget.puzzle.cols;
      final availableWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : 480.0;
      final availableHeight = constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : 480.0;
      final width = math
          .min(
            math.min(availableWidth - 24, 480),
            (availableHeight - 16) * cols / rows,
          )
          .clamp(1.0, 480.0);
      final size = Size(width.toDouble(), width * rows / cols);
      final cellW = size.width / cols, cellH = size.height / rows;
      final active = widget.activeSelection.toSet();
      final found = widget.puzzle.placedWords
          .where((w) => w.isFound)
          .expand((w) => w.coordinates)
          .toSet();
      return Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ExplorerTheme.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            // The painter and hit-test surface share exactly the same dimensions.
            child: GestureDetector(
              key: const Key('word_search_board'),
              behavior: HitTestBehavior.opaque,
              onPanDown: (event) {
                final point = _coordinate(event.localPosition, size);
                _start = point;
                if (point != null) widget.onSelectionUpdate(point, point);
              },
              onPanUpdate: (event) {
                final point = _coordinate(event.localPosition, size);
                if (_start != null && point != null) {
                  widget.onSelectionUpdate(_start!, point);
                }
              },
              onPanEnd: (_) {
                _start = null;
                widget.onSelectionEnd();
              },
              onPanCancel: () {
                _start = null;
              },
              child: SizedBox.fromSize(
                size: size,
                child: CustomPaint(
                  painter: _SelectionPainter(
                    widget.puzzle,
                    widget.activeSelection,
                  ),
                  child: Stack(
                    children: [
                      for (var row = 0; row < rows; row++)
                        for (var col = 0; col < cols; col++)
                          Positioned(
                            left: col * cellW,
                            top: row * cellH,
                            width: cellW,
                            height: cellH,
                            child: Semantics(
                              label:
                                  '${widget.puzzle.grid[row][col]}, ${row + 1}, ${col + 1}',
                              selected:
                                  active.contains(PuzzleCoordinate(row, col)) ||
                                  found.contains(PuzzleCoordinate(row, col)),
                              child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(2),
                                decoration:
                                    widget.revealedHints.contains(
                                      PuzzleCoordinate(row, col),
                                    )
                                    ? BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF996A00),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      )
                                    : null,
                                child: Text(
                                  widget.puzzle.grid[row][col],
                                  style: TextStyle(
                                    fontSize: math.min(19, cellW * .51),
                                    fontWeight: FontWeight.w800,
                                    color:
                                        active.contains(
                                          PuzzleCoordinate(row, col),
                                        )
                                        ? Colors.white
                                        : ExplorerTheme.ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _SelectionPainter extends CustomPainter {
  const _SelectionPainter(this.puzzle, this.selection);
  final WordSearchPuzzle puzzle;
  final List<PuzzleCoordinate> selection;
  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / puzzle.cols, cellH = size.height / puzzle.rows;
    Offset center(PuzzleCoordinate p) =>
        Offset((p.col + .5) * cellW, (p.row + .5) * cellH);
    void path(List<PuzzleCoordinate> coordinates, Color color) {
      if (coordinates.isEmpty) return;
      final paint = Paint()
        ..color = color
        ..strokeWidth = math.min(cellW, cellH) * .82
        ..strokeCap = StrokeCap.round;
      if (coordinates.length == 1) {
        canvas.drawCircle(
          center(coordinates.first),
          paint.strokeWidth / 2,
          paint,
        );
      } else {
        canvas.drawLine(
          center(coordinates.first),
          center(coordinates.last),
          paint,
        );
      }
    }

    const colors = [
      Color(0xFFAADCCB),
      Color(0xFFFADE97),
      Color(0xFFBED9F3),
      Color(0xFFD8CBE9),
    ];
    var i = 0;
    for (final word in puzzle.placedWords.where((w) => w.isFound)) {
      path(word.coordinates, colors[i++ % colors.length]);
    }
    path(selection, ExplorerTheme.ocean);
  }

  @override
  bool shouldRepaint(_SelectionPainter old) =>
      old.puzzle != puzzle || old.selection != selection;
}
