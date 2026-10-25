import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/constants/database_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/database_tables.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';

void main() {
  setUpAll(sqfliteFfiInit);
  test('v2 upgrade preserves legacy avatars and progress; new slots survive reopening', () async {
    final temp = await Directory.systemTemp.createTemp('rehiyonia_avatar_');
    final path = '${temp.path}/avatar.db';
    AppDatabase? app;
    try {
      final legacy = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, _) async {
            await db.execute(DatabaseTables.createRegionsTable);
            await db.execute(DatabaseTables.createUserProgressTable);
            await db.execute(
              DatabaseTables.createPlayerProfileTable.replaceAll(
                'avatar_json TEXT,',
                '',
              ),
            );
          },
        ),
      );
      for (var i = 0; i < 4; i++) {
        await legacy.insert('player_profile', {
          'player_name': 'Explorer $i',
          'avatar_skin': 2,
          'avatar_hair': i,
          'avatar_accessory': i,
          'coins': 137,
          'total_stars': 6,
        });
      }
      await legacy.insert('user_progress', {
        DatabaseConstants.columnKey: AppConstants.keyCoins,
        DatabaseConstants.columnValue: '137',
      });
      await legacy.insert('regions', {
        'code': 'NCR',
        'name': 'NCR',
        'designation': 'NCR',
        'island_group': 'Luzon',
        'description': 'Saved region',
        'is_unlocked': 1,
        'stars_earned': 3,
      });
      await legacy.close();
      app = AppDatabase(databaseFactory: databaseFactoryFfi);
      final db = await app.initialize(databasePath: path);
      expect(await db.getVersion(), 3);
      final rows = await db.query('player_profile', orderBy: 'id');
      expect(rows.length, 4);
      expect(
        rows.every((r) => r['coins'] == 137 && r['total_stars'] == 6),
        isTrue,
      );
      expect(PlayerAvatar.fromMap(rows[1]).headwearId, 'cap');
      expect(PlayerAvatar.fromMap(rows[2]).headwearId, 'flower');
      expect(PlayerAvatar.fromMap(rows[3]).glassesId, 'round');
      final repository = ProfileRepository(app);
      expect((await repository.load()).coins, 137);
      final avatar = PlayerAvatar.fromMap(rows.first).copyWith(
        baseId: 'female',
        glassesId: 'square',
        headwearId: 'cap',
        necklaceId: 'pendant',
        topId: 'jacket',
        bottomId: 'shorts',
        shoesId: 'sandals',
      );
      await repository.saveAvatar(avatar);
      await app.close();
      await app.initialize(databasePath: path);
      final loaded = await repository.load();
      expect(loaded.avatar, avatar);
      expect(loaded.coins, 137);
      expect(loaded.totalStars, 3);
      expect((await app.database.query('regions')).first['is_unlocked'], 1);
    } finally {
      await app?.close();
      await temp.delete(recursive: true);
    }
  });
}
