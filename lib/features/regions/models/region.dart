class Region {
  const Region({
    required this.id,
    required this.code,
    required this.name,
    required this.designation,
    required this.islandGroup,
    required this.description,
    this.isUnlocked = false,
    this.starsEarned = 0,
  });

  final int id;
  final String code;
  final String name;
  final String designation;
  final String islandGroup;
  final String description;
  final bool isUnlocked;
  final int starsEarned;

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      id: map['id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
      designation: map['designation'] as String,
      islandGroup: map['island_group'] as String,
      description: map['description'] as String,
      isUnlocked: (map['is_unlocked'] as int? ?? 0) == 1,
      starsEarned: map['stars_earned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'designation': designation,
      'island_group': islandGroup,
      'description': description,
      'is_unlocked': isUnlocked ? 1 : 0,
      'stars_earned': starsEarned,
    };
  }

  Region copyWith({
    int? id,
    String? code,
    String? name,
    String? designation,
    String? islandGroup,
    String? description,
    bool? isUnlocked,
    int? starsEarned,
  }) {
    return Region(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      islandGroup: islandGroup ?? this.islandGroup,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }
}
