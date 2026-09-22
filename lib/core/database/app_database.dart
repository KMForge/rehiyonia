import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

import '../constants/database_constants.dart';
import '../errors/app_exceptions.dart';
import 'database_tables.dart';

class AppDatabase {
  AppDatabase({this.databaseFactory});

  final sqflite.DatabaseFactory? databaseFactory;
  sqflite.Database? _db;

  sqflite.Database get database {
    final db = _db;
    if (db == null || !db.isOpen) {
      throw const DatabaseException(
        'Database is not initialized. Call initialize() before accessing.',
      );
    }
    return db;
  }

  bool get isOpen => _db != null && _db!.isOpen;

  Future<sqflite.Database> initialize({
    String? databasePath,
    bool inMemory = false,
  }) async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }

    try {
      final factory = databaseFactory ?? sqflite.databaseFactory;

      String path;
      if (inMemory) {
        path = sqflite.inMemoryDatabasePath;
      } else if (databasePath != null) {
        path = databasePath;
      } else {
        final databasesDir = await factory.getDatabasesPath();
        path = p.join(databasesDir, DatabaseConstants.databaseName);
      }

      final db = await factory.openDatabase(
        path,
        options: sqflite.OpenDatabaseOptions(
          version: DatabaseConstants.databaseVersion,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );

      _db = db;
      return db;
    } on Exception catch (e) {
      throw DatabaseException('Failed to initialize local database.', e);
    }
  }

  Future<void> _onConfigure(sqflite.Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    final batch = db.batch();
    batch.execute(DatabaseTables.createRegionsTable);
    batch.execute(DatabaseTables.createWordsTable);
    batch.execute(DatabaseTables.createLocalitiesTable);
    batch.execute(DatabaseTables.createTriviaTable);
    batch.execute(DatabaseTables.createTriviaQuestionsTable);
    batch.execute(DatabaseTables.createUserProgressTable);
    batch.execute(DatabaseTables.createPlayerProfileTable);
    batch.execute(DatabaseTables.createAchievementsTable);
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(DatabaseTables.createLocalitiesTable);
      await db.execute(DatabaseTables.createTriviaQuestionsTable);
      await db.execute(DatabaseTables.createPlayerProfileTable);

      await db.insert(DatabaseConstants.tablePlayerProfile, {
        DatabaseConstants.columnPlayerName: 'Bayanito',
        DatabaseConstants.columnCoins: 50,
        DatabaseConstants.columnTotalStars: 0,
      });
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
      _db = null;
    }
  }
}
