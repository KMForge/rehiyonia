abstract final class DatabaseConstants {
  static const String databaseName = 'rehiyonia.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String tableRegions = 'regions';
  static const String tableWords = 'words';
  static const String tableTrivia = 'trivia';
  static const String tableUserProgress = 'user_progress';
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

  // Words Columns
  static const String columnRegionId = 'region_id';
  static const String columnWord = 'word';
  static const String columnCategory = 'category';
  static const String columnClue = 'clue';

  // Trivia Columns
  static const String columnQuestion = 'question';
  static const String columnOptionA = 'option_a';
  static const String columnOptionB = 'option_b';
  static const String columnOptionC = 'option_c';
  static const String columnOptionD = 'option_d';
  static const String columnCorrectOption = 'correct_option';
  static const String columnExplanation = 'explanation';

  // User Progress Keys
  static const String columnKey = 'setting_key';
  static const String columnValue = 'setting_value';

  // Achievements Columns
  static const String columnAchievementCode = 'code';
  static const String columnTitle = 'title';
  static const String columnUnlockedAt = 'unlocked_at';
}
