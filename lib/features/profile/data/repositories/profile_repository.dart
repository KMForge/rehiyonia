import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../avatar/models/player_avatar.dart';
import '../../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this.appDb);
  final AppDatabase appDb;

  static const identityCreatedKey = 'identity_created_v1';

  Future<bool> needsNameCreation() async {
    final rows = await appDb.database.query(
      DatabaseConstants.tableUserProgress,
      where: '${DatabaseConstants.columnKey} IN (?, ?)',
      whereArgs: [identityCreatedKey, AppConstants.keyPlayerName],
    );
    for (final row in rows) {
      final key = row[DatabaseConstants.columnKey];
      final value = (row[DatabaseConstants.columnValue] as String? ?? '')
          .trim();
      if (key == identityCreatedKey && value == '1') return false;
      // Preserve identities created before onboarding was introduced.
      if (key == AppConstants.keyPlayerName &&
          value.isNotEmpty &&
          value != AppConstants.defaultPlayerName) {
        return false;
      }
    }
    return true;
  }

  Future<void> completeNameCreation(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Name cannot be empty');
    await appDb.database.transaction((txn) async {
      for (final entry in {
        AppConstants.keyPlayerName: trimmed,
        identityCreatedKey: '1',
      }.entries) {
        await txn.insert(DatabaseConstants.tableUserProgress, {
          DatabaseConstants.columnKey: entry.key,
          DatabaseConstants.columnValue: entry.value,
          'updated_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await txn.update(DatabaseConstants.tablePlayerProfile, {
        DatabaseConstants.columnPlayerName: trimmed,
      });
    });
  }

  Future<UserProfile> load() async {
    final db = appDb.database;
    final values = await db.query(DatabaseConstants.tableUserProgress);
    final saved = <String, String>{
      for (final row in values)
        row[DatabaseConstants.columnKey] as String:
            row[DatabaseConstants.columnValue] as String? ?? '',
    };
    final profiles = await db.query(
      DatabaseConstants.tablePlayerProfile,
      limit: 1,
    );
    final rows = await db.query(
      DatabaseConstants.tableRegions,
      columns: ['stars_earned'],
    );
    final regionStars = rows.fold(
      0,
      (sum, row) => sum + (row['stars_earned'] as int? ?? 0),
    );
    final stars = int.tryParse(saved[AppConstants.keyTotalStars] ?? '') ?? 0;
    return UserProfile(
      name: saved[AppConstants.keyPlayerName] ?? AppConstants.defaultPlayerName,
      coins:
          int.tryParse(saved[AppConstants.keyCoins] ?? '') ??
          AppConstants.startingCoins,
      totalStars: regionStars > stars ? regionStars : stars,
      avatar: profiles.isEmpty
          ? const PlayerAvatar()
          : PlayerAvatar.fromMap(profiles.first),
    );
  }

  Future<void> saveAvatar(PlayerAvatar avatar) async {
    // Opening is owned by the startup provider. An unavailable DB is an error,
    // not a successful in-memory save.
    final db = appDb.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        DatabaseConstants.tablePlayerProfile,
        limit: 1,
      );
      if (rows.isEmpty) {
        await txn.insert(DatabaseConstants.tablePlayerProfile, avatar.toMap());
      } else {
        await txn.update(
          DatabaseConstants.tablePlayerProfile,
          avatar.toMap(),
          where: 'id = ?',
          whereArgs: [rows.first['id']],
        );
      }
    });
  }

  Future<void> saveValue(String key, String value) async {
    await appDb.database.insert(DatabaseConstants.tableUserProgress, {
      DatabaseConstants.columnKey: key,
      DatabaseConstants.columnValue: value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveName(String name) async {
    await saveValue(AppConstants.keyPlayerName, name);
    await appDb.database.update(DatabaseConstants.tablePlayerProfile, {
      DatabaseConstants.columnPlayerName: name,
    });
  }
}
