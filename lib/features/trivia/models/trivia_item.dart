class TriviaItem {
  const TriviaItem({
    this.id,
    required this.regionId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.explanation,
  });

  final int? id;
  final int regionId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int correctOption;
  final String explanation;

  String get answer {
    switch (correctOption) {
      case 0:
        return optionA;
      case 1:
        return optionB;
      case 2:
        return optionC;
      case 3:
        return optionD;
      default:
        return optionA;
    }
  }

  String get funFact => explanation;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'region_id': regionId,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
      'explanation': explanation,
    };
  }

  factory TriviaItem.fromMap(Map<String, dynamic> map) {
    return TriviaItem(
      id: map['id'] as int?,
      regionId: map['region_id'] as int,
      question: map['question'] as String,
      optionA: (map['option_a'] as String?) ?? (map['answer'] as String? ?? ''),
      optionB: (map['option_b'] as String?) ?? '',
      optionC: (map['option_c'] as String?) ?? '',
      optionD: (map['option_d'] as String?) ?? '',
      correctOption: (map['correct_option'] as int?) ?? 0,
      explanation:
          (map['explanation'] as String?) ?? (map['fun_fact'] as String? ?? ''),
    );
  }

  @override
  String toString() =>
      'TriviaItem(id: $id, regionId: $regionId, question: $question)';
}
