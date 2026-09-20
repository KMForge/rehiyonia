import '../constants/database_constants.dart';

abstract final class DatabaseTables {
  static const String createRegionsTable =
      '''
    CREATE TABLE ${DatabaseConstants.tableRegions} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnRegionCode} TEXT NOT NULL UNIQUE,
      ${DatabaseConstants.columnRegionName} TEXT NOT NULL,
      ${DatabaseConstants.columnRegionDesignation} TEXT NOT NULL,
      ${DatabaseConstants.columnIslandGroup} TEXT NOT NULL,
      ${DatabaseConstants.columnDescription} TEXT NOT NULL,
      ${DatabaseConstants.columnIsUnlocked} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnStarsEarned} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL DEFAULT (DATETIME('now')),
      ${DatabaseConstants.columnUpdatedAt} TEXT NOT NULL DEFAULT (DATETIME('now'))
    )
  ''';

  static const String createWordsTable =
      '''
    CREATE TABLE ${DatabaseConstants.tableWords} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnRegionId} INTEGER NOT NULL,
      ${DatabaseConstants.columnWord} TEXT NOT NULL,
      ${DatabaseConstants.columnCategory} TEXT NOT NULL,
      ${DatabaseConstants.columnClue} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseConstants.columnRegionId}) REFERENCES ${DatabaseConstants.tableRegions} (${DatabaseConstants.columnId}) ON DELETE CASCADE
    )
  ''';

  static const String createTriviaTable =
      '''
    CREATE TABLE ${DatabaseConstants.tableTrivia} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnRegionId} INTEGER NOT NULL,
      ${DatabaseConstants.columnQuestion} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionA} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionB} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionC} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionD} TEXT NOT NULL,
      ${DatabaseConstants.columnCorrectOption} INTEGER NOT NULL,
      ${DatabaseConstants.columnExplanation} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseConstants.columnRegionId}) REFERENCES ${DatabaseConstants.tableRegions} (${DatabaseConstants.columnId}) ON DELETE CASCADE
    )
  ''';

  static const String createUserProgressTable =
      '''
    CREATE TABLE ${DatabaseConstants.tableUserProgress} (
      ${DatabaseConstants.columnKey} TEXT PRIMARY KEY,
      ${DatabaseConstants.columnValue} TEXT NOT NULL,
      ${DatabaseConstants.columnUpdatedAt} TEXT NOT NULL DEFAULT (DATETIME('now'))
    )
  ''';

  static const String createAchievementsTable =
      '''
    CREATE TABLE ${DatabaseConstants.tableAchievements} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnAchievementCode} TEXT NOT NULL UNIQUE,
      ${DatabaseConstants.columnTitle} TEXT NOT NULL,
      ${DatabaseConstants.columnDescription} TEXT NOT NULL,
      ${DatabaseConstants.columnIsUnlocked} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnUnlockedAt} TEXT
    )
  ''';
}
