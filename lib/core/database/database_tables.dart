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

  static const String createLocalitiesTable =
      '''
    CREATE TABLE ${DatabaseConstants.tableLocalities} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnRegionId} INTEGER NOT NULL,
      ${DatabaseConstants.columnWord} TEXT NOT NULL,
      ${DatabaseConstants.columnNameEn} TEXT NOT NULL,
      ${DatabaseConstants.columnNameFil} TEXT NOT NULL,
      ${DatabaseConstants.columnProvinceEn} TEXT NOT NULL,
      ${DatabaseConstants.columnProvinceFil} TEXT NOT NULL,
      ${DatabaseConstants.columnCategory} TEXT NOT NULL,
      ${DatabaseConstants.columnDescriptionEn} TEXT NOT NULL,
      ${DatabaseConstants.columnDescriptionFil} TEXT NOT NULL,
      ${DatabaseConstants.columnFactEn} TEXT NOT NULL,
      ${DatabaseConstants.columnFactFil} TEXT NOT NULL,
      ${DatabaseConstants.columnImagePath} TEXT,
      ${DatabaseConstants.columnIsWordSearchTarget} INTEGER NOT NULL DEFAULT 1,
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

  static const String createTriviaQuestionsTable =
      '''
    CREATE TABLE ${DatabaseConstants.tableTriviaQuestions} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnRegionId} INTEGER NOT NULL,
      ${DatabaseConstants.columnQuestionEn} TEXT NOT NULL,
      ${DatabaseConstants.columnQuestionFil} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionAEn} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionAFil} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionBEn} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionBFil} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionCEn} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionCFil} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionDEn} TEXT NOT NULL,
      ${DatabaseConstants.columnOptionDFil} TEXT NOT NULL,
      ${DatabaseConstants.columnCorrectOption} INTEGER NOT NULL,
      ${DatabaseConstants.columnExplanationEn} TEXT NOT NULL,
      ${DatabaseConstants.columnExplanationFil} TEXT NOT NULL,
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

  static const String createPlayerProfileTable =
      '''
    CREATE TABLE ${DatabaseConstants.tablePlayerProfile} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnPlayerName} TEXT NOT NULL DEFAULT 'Bayanito',
      ${DatabaseConstants.columnAvatarSkin} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnAvatarHair} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnAvatarHairColor} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnAvatarOutfit} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnAvatarAccessory} INTEGER NOT NULL DEFAULT 0,
      ${DatabaseConstants.columnCoins} INTEGER NOT NULL DEFAULT 50,
      ${DatabaseConstants.columnTotalStars} INTEGER NOT NULL DEFAULT 0,
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
