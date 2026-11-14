import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/database_tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('v3 database gains photo columns without losing saved data', () async {
    final directory = await Directory.systemTemp.createTemp('trivia_upgrade_');
    final path = '${directory.path}/saved.db';
    final legacy = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, _) async {
          await db.execute(DatabaseTables.createUserProgressTable);
          for (final schema in [
            DatabaseTables.createTriviaTable,
            DatabaseTables.createTriviaQuestionsTable,
          ]) {
            await db.execute(
              schema.replaceAll(
                RegExp(r'\s*image_(path|caption|credit) TEXT,'),
                '',
              ),
            );
          }
          await db.insert('user_progress', {
            'setting_key': 'player_coins',
            'setting_value': '125',
          });
        },
      ),
    );
    await legacy.close();
    final upgraded = AppDatabase(databaseFactory: databaseFactoryFfi);
    try {
      final db = await upgraded.initialize(databasePath: path);
      for (final table in ['trivia', 'trivia_questions']) {
        final columns = await db.rawQuery('PRAGMA table_info($table)');
        expect(
          columns.map((c) => c['name']),
          containsAll(['image_path', 'image_caption', 'image_credit']),
        );
      }
      expect((await db.query('user_progress')).single['setting_value'], '125');
    } finally {
      await upgraded.close();
      await directory.delete(recursive: true);
    }
  });
}
