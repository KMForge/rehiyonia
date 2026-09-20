class RegionalWord {
  const RegionalWord({
    this.id,
    required this.regionId,
    required this.word,
    required this.category,
    required this.clue,
    this.difficulty = 'Madali',
  });

  final int? id;
  final int regionId;
  final String word;
  final String category;
  final String clue;
  final String difficulty;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'region_id': regionId,
      'word': word,
      'category': category,
      'clue': clue,
    };
  }

  factory RegionalWord.fromMap(Map<String, dynamic> map) {
    return RegionalWord(
      id: map['id'] as int?,
      regionId: map['region_id'] as int,
      word: map['word'] as String,
      category: map['category'] as String,
      clue: map['clue'] as String,
      difficulty: (map['difficulty'] as String?) ?? 'Madali',
    );
  }

  @override
  String toString() =>
      'RegionalWord(id: $id, regionId: $regionId, word: $word)';
}
