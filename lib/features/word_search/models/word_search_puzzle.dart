import 'placed_word.dart';

class WordSearchPuzzle {
  const WordSearchPuzzle({
    required this.grid,
    required this.placedWords,
    required this.rows,
    required this.cols,
  });

  final List<List<String>> grid;
  final List<PlacedWord> placedWords;
  final int rows;
  final int cols;

  bool get isComplete =>
      placedWords.isNotEmpty && placedWords.every((w) => w.isFound);
  int get foundWordCount => placedWords.where((w) => w.isFound).length;
  int get totalWordCount => placedWords.length;

  WordSearchPuzzle copyWith({
    List<List<String>>? grid,
    List<PlacedWord>? placedWords,
    int? rows,
    int? cols,
  }) {
    return WordSearchPuzzle(
      grid: grid ?? this.grid,
      placedWords: placedWords ?? this.placedWords,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
    );
  }
}
