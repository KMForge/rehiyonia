class RegionalWord {
  const RegionalWord({
    this.id,
    required this.regionId,
    required this.word,
    required this.category,
    required this.clue,
    this.difficulty = 'Madali',
    this.nameEn,
    this.nameFil,
    this.provinceEn,
    this.provinceFil,
    this.clueEn,
    this.factEn,
    this.factFil,
    this.imagePath,
    this.isTarget = true,
  });

  final int? id;
  final int regionId;
  final String word;
  final String category;
  final String clue;
  final String difficulty;
  final String? nameEn;
  final String? nameFil;
  final String? provinceEn;
  final String? provinceFil;
  final String? clueEn;
  final String? factEn;
  final String? factFil;
  final String? imagePath;
  final bool isTarget;

  String get displayNameEn => nameEn ?? _formatTitleCase(word);
  String get displayNameFil => nameFil ?? displayNameEn;
  String get displayClueEn => clueEn ?? clue;
  String get displayClueFil => clue;
  String get displayFactEn => factEn ?? displayClueEn;
  String get displayFactFil => factFil ?? clue;
  String get resolvedImagePath =>
      imagePath ?? 'assets/images/localities/${word.toLowerCase()}.jpg';

  static String _formatTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Maps to the legacy `words` table columns
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'region_id': regionId,
      'word': word,
      'category': category,
      'clue': clue,
    };
  }

  /// Maps to the Database v2 `localities` table columns
  Map<String, dynamic> toLocalityMap() {
    return {
      if (id != null) 'id': id,
      'region_id': regionId,
      'word': word,
      'name_en': displayNameEn,
      'name_fil': displayNameFil,
      'province_en': provinceEn ?? '',
      'province_fil': provinceFil ?? '',
      'category': category,
      'description_en': displayClueEn,
      'description_fil': displayClueFil,
      'fact_en': displayFactEn,
      'fact_fil': displayFactFil,
      'image_path': resolvedImagePath,
      'is_word_search_target': isTarget ? 1 : 0,
    };
  }

  factory RegionalWord.fromMap(Map<String, dynamic> map) {
    return RegionalWord(
      id: map['id'] as int?,
      regionId: map['region_id'] as int,
      word: map['word'] as String,
      category: map['category'] as String,
      clue:
          (map['clue'] as String?) ??
          (map['description_en'] as String?) ??
          (map['description_fil'] as String? ?? ''),
      difficulty: (map['difficulty'] as String?) ?? 'Madali',
      nameEn: map['name_en'] as String?,
      nameFil: map['name_fil'] as String?,
      provinceEn: map['province_en'] as String?,
      provinceFil: map['province_fil'] as String?,
      clueEn: map['clue_en'] as String? ?? map['description_en'] as String?,
      factEn: map['fact_en'] as String?,
      factFil: map['fact_fil'] as String?,
      imagePath: map['image_path'] as String?,
      isTarget:
          map['is_word_search_target'] == null ||
          map['is_word_search_target'] == 1,
    );
  }

  @override
  String toString() =>
      'RegionalWord(id: $id, regionId: $regionId, word: $word)';
}
