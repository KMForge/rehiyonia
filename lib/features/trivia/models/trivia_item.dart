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
    this.questionEn,
    this.optionAEn,
    this.optionBEn,
    this.optionCEn,
    this.optionDEn,
    this.explanationEn,
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
  final String? questionEn;
  final String? optionAEn;
  final String? optionBEn;
  final String? optionCEn;
  final String? optionDEn;
  final String? explanationEn;

  String getQuestion(bool isEnglish) =>
      isEnglish ? (questionEn ?? question) : question;
  String getOptionA(bool isEnglish) =>
      isEnglish ? (optionAEn ?? optionA) : optionA;
  String getOptionB(bool isEnglish) =>
      isEnglish ? (optionBEn ?? optionB) : optionB;
  String getOptionC(bool isEnglish) =>
      isEnglish ? (optionCEn ?? optionC) : optionC;
  String getOptionD(bool isEnglish) =>
      isEnglish ? (optionDEn ?? optionD) : optionD;
  String getExplanation(bool isEnglish) =>
      isEnglish ? (explanationEn ?? explanation) : explanation;

  String getAnswer(bool isEnglish) {
    switch (correctOption) {
      case 0:
        return getOptionA(isEnglish);
      case 1:
        return getOptionB(isEnglish);
      case 2:
        return getOptionC(isEnglish);
      case 3:
        return getOptionD(isEnglish);
      default:
        return getOptionA(isEnglish);
    }
  }

  String get answer => getAnswer(false);

  String get funFact => explanation;

  /// Maps to the legacy `trivia` table columns
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

  /// Maps to the Database v2 `trivia_questions` table columns
  Map<String, dynamic> toTriviaQuestionMap() {
    return {
      if (id != null) 'id': id,
      'region_id': regionId,
      'question_en': getQuestion(true),
      'question_fil': getQuestion(false),
      'option_a_en': getOptionA(true),
      'option_a_fil': getOptionA(false),
      'option_b_en': getOptionB(true),
      'option_b_fil': getOptionB(false),
      'option_c_en': getOptionC(true),
      'option_c_fil': getOptionC(false),
      'option_d_en': getOptionD(true),
      'option_d_fil': getOptionD(false),
      'correct_option': correctOption,
      'explanation_en': getExplanation(true),
      'explanation_fil': getExplanation(false),
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
      questionEn: map['question_en'] as String?,
      optionAEn: map['option_a_en'] as String?,
      optionBEn: map['option_b_en'] as String?,
      optionCEn: map['option_c_en'] as String?,
      optionDEn: map['option_d_en'] as String?,
      explanationEn: map['explanation_en'] as String?,
    );
  }

  @override
  String toString() =>
      'TriviaItem(id: $id, regionId: $regionId, question: $question)';
}
