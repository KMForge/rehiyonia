import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehiyonia/core/constants/database_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/database_tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('Database v2 Migration Tests', () {
    test(
      'creates v2 schema with localities, trivia_questions, and player_profile',
      () async {
        final appDb = AppDatabase(databaseFactory: databaseFactoryFfi);
        final db = await appDb.initialize(inMemory: true);

        // Verify all v2 tables exist
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        );
        final tableNames = tables.map((t) => t['name'] as String).toSet();

        expect(tableNames.contains(DatabaseConstants.tableRegions), isTrue);
        expect(tableNames.contains(DatabaseConstants.tableWords), isTrue);
        expect(tableNames.contains(DatabaseConstants.tableLocalities), isTrue);
        expect(tableNames.contains(DatabaseConstants.tableTrivia), isTrue);
        expect(
          tableNames.contains(DatabaseConstants.tableTriviaQuestions),
          isTrue,
        );
        expect(
          tableNames.contains(DatabaseConstants.tableUserProgress),
          isTrue,
        );
        expect(
          tableNames.contains(DatabaseConstants.tablePlayerProfile),
          isTrue,
        );
        expect(
          tableNames.contains(DatabaseConstants.tableAchievements),
          isTrue,
        );

        await appDb.close();
      },
    );

    test('upgrades from v1 to v2 safely preserving existing data', () async {
      final factory = databaseFactoryFfi;
      final tempDir = Directory.systemTemp.createTempSync(
        'rehiyonia_migration_',
      );
      final path = p.join(tempDir.path, 'test_migration.db');

      try {
        // 1. Create v1 database on disk
        final v1Db = await factory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute(DatabaseTables.createRegionsTable);
              await db.execute(DatabaseTables.createWordsTable);
              await db.execute(DatabaseTables.createTriviaTable);
              await db.execute(DatabaseTables.createUserProgressTable);
              await db.execute(DatabaseTables.createAchievementsTable);
            },
          ),
        );

        // 2. Insert test region into v1
        await v1Db.insert(DatabaseConstants.tableRegions, {
          DatabaseConstants.columnRegionCode: 'NCR',
          DatabaseConstants.columnRegionName: 'National Capital Region',
          DatabaseConstants.columnRegionDesignation: 'NCR',
          DatabaseConstants.columnIslandGroup: 'Luzon',
          DatabaseConstants.columnDescription: 'Metro Manila',
          DatabaseConstants.columnIsUnlocked: 1,
          DatabaseConstants.columnStarsEarned: 3,
        });
        await v1Db.close();

        // 3. Open through AppDatabase which triggers onUpgrade to version 2
        final appDb = AppDatabase(databaseFactory: factory);
        final v2Db = await appDb.initialize(databasePath: path);

        // 4. Verify upgraded tables exist
        final tables = await v2Db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        );
        final tableNames = tables.map((t) => t['name'] as String).toSet();

        expect(tableNames.contains(DatabaseConstants.tableLocalities), isTrue);
        expect(
          tableNames.contains(DatabaseConstants.tableTriviaQuestions),
          isTrue,
        );
        expect(
          tableNames.contains(DatabaseConstants.tablePlayerProfile),
          isTrue,
        );

        // 5. Verify v1 data was preserved
        final regions = await v2Db.query(DatabaseConstants.tableRegions);
        expect(regions.length, equals(1));
        expect(regions.first['code'], equals('NCR'));
        expect(regions.first['stars_earned'], equals(3));

        // 6. Verify default player profile was initialized
        final profile = await v2Db.query(DatabaseConstants.tablePlayerProfile);
        expect(profile.length, equals(1));
        expect(profile.first['player_name'], equals('Bayanito'));

        await appDb.close();
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });
  });
}
