abstract final class DatabaseConstants {
  static const String databaseName = 'rehiyonia.db';
  static const int databaseVersion = 2;

  // Table Names
  static const String tableRegions = 'regions';
  static const String tableWords = 'words';
  static const String tableLocalities = 'localities';
  static const String tableTrivia = 'trivia';
  static const String tableTriviaQuestions = 'trivia_questions';
  static const String tableUserProgress = 'user_progress';
  static const String tablePlayerProfile = 'player_profile';
  static const String tableAchievements = 'achievements';

  // Common Column Names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Regions Columns
  static const String columnRegionCode = 'code';
  static const String columnRegionName = 'name';
  static const String columnRegionDesignation = 'designation';
  static const String columnIslandGroup = 'island_group';
  static const String columnDescription = 'description';
  static const String columnIsUnlocked = 'is_unlocked';
  static const String columnStarsEarned = 'stars_earned';

  // Words & Localities Columns
  static const String columnRegionId = 'region_id';
  static const String columnWord = 'word';
  static const String columnCategory = 'category';
  static const String columnClue = 'clue';
  static const String columnNameEn = 'name_en';
  static const String columnNameFil = 'name_fil';
  static const String columnProvinceEn = 'province_en';
  static const String columnProvinceFil = 'province_fil';
  static const String columnDescriptionEn = 'description_en';
  static const String columnDescriptionFil = 'description_fil';
  static const String columnFactEn = 'fact_en';
  static const String columnFactFil = 'fact_fil';
  static const String columnImagePath = 'image_path';
  static const String columnIsWordSearchTarget = 'is_word_search_target';

  // Trivia Columns
  static const String columnQuestion = 'question';
  static const String columnOptionA = 'option_a';
  static const String columnOptionB = 'option_b';
  static const String columnOptionC = 'option_c';
  static const String columnOptionD = 'option_d';
  static const String columnCorrectOption = 'correct_option';
  static const String columnExplanation = 'explanation';

  // Trivia Questions Bilingual Columns
  static const String columnQuestionEn = 'question_en';
  static const String columnQuestionFil = 'question_fil';
  static const String columnOptionAEn = 'option_a_en';
  static const String columnOptionAFil = 'option_a_fil';
  static const String columnOptionBEn = 'option_b_en';
  static const String columnOptionBFil = 'option_b_fil';
  static const String columnOptionCEn = 'option_c_en';
  static const String columnOptionCFil = 'option_c_fil';
  static const String columnOptionDEn = 'option_d_en';
  static const String columnOptionDFil = 'option_d_fil';
  static const String columnExplanationEn = 'explanation_en';
  static const String columnExplanationFil = 'explanation_fil';

  // Player Profile Columns
  static const String columnPlayerName = 'player_name';
  static const String columnAvatarSkin = 'avatar_skin';
  static const String columnAvatarHair = 'avatar_hair';
  static const String columnAvatarHairColor = 'avatar_hair_color';
  static const String columnAvatarOutfit = 'avatar_outfit';
  static const String columnAvatarAccessory = 'avatar_accessory';
  static const String columnCoins = 'coins';
  static const String columnTotalStars = 'total_stars';

  // User Progress Keys
  static const String columnKey = 'setting_key';
  static const String columnValue = 'setting_value';

  // Achievements Columns
  static const String columnAchievementCode = 'code';
  static const String columnTitle = 'title';
  static const String columnUnlockedAt = 'unlocked_at';
}
