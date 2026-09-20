import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/constants/database_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/errors/app_exceptions.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

void main() {
  setUpAll(() {
    // Initialize FFI for host machine testing
    sqfliteFfiInit();
  });

  group('AppDatabase Tests', () {
    late AppDatabase appDatabase;

    setUp(() {
      appDatabase = AppDatabase(databaseFactory: databaseFactoryFfi);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('throws DatabaseException when accessed before initialization', () {
      expect(() => appDatabase.database, throwsA(isA<DatabaseException>()));
    });

    test('initializes in-memory database and creates all tables', () async {
      final db = await appDatabase.initialize(inMemory: true);
      expect(appDatabase.isOpen, isTrue);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();

      expect(tableNames, contains(DatabaseConstants.tableRegions));
      expect(tableNames, contains(DatabaseConstants.tableWords));
      expect(tableNames, contains(DatabaseConstants.tableTrivia));
      expect(tableNames, contains(DatabaseConstants.tableUserProgress));
      expect(tableNames, contains(DatabaseConstants.tableAchievements));
    });

    test(
      'enforces foreign key constraints between words and regions',
      () async {
        final db = await appDatabase.initialize(inMemory: true);

        // Attempting to insert a word referencing a non-existent region_id should fail
        expect(
          () async => db.insert(DatabaseConstants.tableWords, {
            DatabaseConstants.columnRegionId: 999,
            DatabaseConstants.columnWord: 'MANILA',
            DatabaseConstants.columnCategory: 'Capital',
            DatabaseConstants.columnClue: 'Capital city',
          }),
          throwsException,
        );
      },
    );

    test('successfully inserts and queries regions', () async {
      final db = await appDatabase.initialize(inMemory: true);

      final id = await db.insert(DatabaseConstants.tableRegions, {
        DatabaseConstants.columnRegionCode: 'NCR',
        DatabaseConstants.columnRegionName: 'National Capital Region',
        DatabaseConstants.columnRegionDesignation: 'NCR',
        DatabaseConstants.columnIslandGroup: 'Luzon',
        DatabaseConstants.columnDescription: 'Metropolitan region',
        DatabaseConstants.columnIsUnlocked: 1,
        DatabaseConstants.columnStarsEarned: 0,
      });

      expect(id, isPositive);

      final queryResult = await db.query(
        DatabaseConstants.tableRegions,
        where: '${DatabaseConstants.columnRegionCode} = ?',
        whereArgs: ['NCR'],
      );

      expect(queryResult.length, 1);
      expect(
        queryResult.first[DatabaseConstants.columnRegionName],
        'National Capital Region',
      );
    });
  });
}
