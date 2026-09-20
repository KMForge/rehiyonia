import 'puzzle_coordinate.dart';
import 'word_search_direction.dart';

class PlacedWord {
  const PlacedWord({
    required this.word,
    required this.coordinates,
    required this.direction,
    this.isFound = false,
  });

  final String word;
  final List<PuzzleCoordinate> coordinates;
  final WordSearchDirection direction;
  final bool isFound;

  PlacedWord copyWith({
    String? word,
    List<PuzzleCoordinate>? coordinates,
    WordSearchDirection? direction,
    bool? isFound,
  }) {
    return PlacedWord(
      word: word ?? this.word,
      coordinates: coordinates ?? this.coordinates,
      direction: direction ?? this.direction,
      isFound: isFound ?? this.isFound,
    );
  }
}
