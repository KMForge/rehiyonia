import 'package:flutter/material.dart';

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
  PuzzleCoordinate? _startCoord;

  static const List<Color> _highlightColors = [
    Color(0xFFE8F5E9), // Light Green
    Color(0xFFFFF9C4), // Light Yellow
    Color(0xFFE1F5FE), // Light Blue
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFFFE0B2), // Light Orange
    Color(0xFFFCE4EC), // Light Pink
  ];

  static const List<Color> _highlightTextColors = [
    Color(0xFF2E7D32),
    Color(0xFFF57F17),
    Color(0xFF0277BD),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFFC2185B),
  ];

  PuzzleCoordinate? _getCoordFromOffset(Offset localOffset, Size size) {
    final rows = widget.puzzle.rows;
    final cols = widget.puzzle.cols;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    final col = (localOffset.dx / cellWidth).floor();
    final row = (localOffset.dy / cellHeight).floor();

    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      return PuzzleCoordinate(row, col);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.puzzle.rows;
    final cols = widget.puzzle.cols;

    // Map found coordinates to color index
    final foundCoordMap = <PuzzleCoordinate, int>{};
    for (int i = 0; i < widget.puzzle.placedWords.length; i++) {
      final placed = widget.puzzle.placedWords[i];
      if (placed.isFound) {
        for (final coord in placed.coordinates) {
          foundCoordMap[coord] = i % _highlightColors.length;
        }
      }
    }

    final activeSet = widget.activeSelection.toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = constraints.biggest;
        final dimension = availableSize.shortestSide.clamp(280.0, 480.0);

        return Center(
          child: SizedBox(
            width: dimension,
            height: dimension,
            child: GestureDetector(
              onPanStart: (details) {
                final coord = _getCoordFromOffset(
                  details.localPosition,
                  Size(dimension, dimension),
                );
                if (coord != null) {
                  _startCoord = coord;
                  widget.onSelectionUpdate(coord, coord);
                }
              },
              onPanUpdate: (details) {
                if (_startCoord == null) return;
                final coord = _getCoordFromOffset(
                  details.localPosition,
                  Size(dimension, dimension),
                );
                if (coord != null) {
                  widget.onSelectionUpdate(_startCoord!, coord);
                }
              },
              onPanEnd: (_) {
                _startCoord = null;
                widget.onSelectionEnd();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: rows * cols,
                  itemBuilder: (context, index) {
                    final row = index ~/ cols;
                    final col = index % cols;
                    final coord = PuzzleCoordinate(row, col);
                    final letter = widget.puzzle.grid[row][col];

                    final isFound = foundCoordMap.containsKey(coord);
                    final isSelected = activeSet.contains(coord);
                    final isHint = widget.revealedHints.contains(coord);

                    Color bgColor = const Color(0xFFF8F9FA);
                    Color textColor = const Color(0xFF212529);
                    FontWeight fontWeight = FontWeight.w600;

                    if (isSelected) {
                      bgColor = Theme.of(context).colorScheme.primary;
                      textColor = Colors.white;
                      fontWeight = FontWeight.w900;
                    } else if (isFound) {
                      final colorIndex = foundCoordMap[coord]!;
                      bgColor = _highlightColors[colorIndex];
                      textColor = _highlightTextColors[colorIndex];
                      fontWeight = FontWeight.w800;
                    } else if (isHint) {
                      bgColor = const Color(0xFFFFF3E0);
                      textColor = const Color(0xFFE65100);
                      fontWeight = FontWeight.w800;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: isHint && !isSelected && !isFound
                            ? Border.all(color: Colors.orange, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: cols > 10 ? 14 : 16,
                          fontWeight: fontWeight,
                          color: textColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
