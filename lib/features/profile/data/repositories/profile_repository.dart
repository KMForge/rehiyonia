import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../avatar/models/player_avatar.dart';
import '../../../avatar/data/avatar_catalog.dart';
import '../../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this.appDb);
  final AppDatabase appDb;

  static const identityCreatedKey = 'identity_created_v1';
  static const wardrobeOwnedKey = 'wardrobe_owned_v1';
  static const wardrobePresetsKey = 'wardrobe_presets_v1';

  static Set<String> _owned(String? value) {
    if (value == null) return {};
    try {
      final decoded = jsonDecode(value);
      return decoded is List ? decoded.whereType<String>().toSet() : {};
    } on FormatException {
      return {};
    }
  }

  static Map<String, PlayerAvatar> _presets(String? value) {
    if (value == null) return {};
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return {};
      return {
        for (final base in AvatarCatalog.bases)
          if (decoded[base] is Map)
            base: PlayerAvatar.fromMap({
              'avatar_json': jsonEncode(decoded[base]),
            }).copyWith(baseId: base),
      };
    } on FormatException {
      return {};
    }
  }

  Future<String?> _value(DatabaseExecutor db, String key) async {
    final rows = await db.query(
      DatabaseConstants.tableUserProgress,
      where: '${DatabaseConstants.columnKey} = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : rows.first[DatabaseConstants.columnValue] as String?;
  }

  Future<void> _put(DatabaseExecutor db, String key, String value) async {
    await db.insert(DatabaseConstants.tableUserProgress, {
      DatabaseConstants.columnKey: key,
      DatabaseConstants.columnValue: value,
      DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Price, ownership and balance are all checked inside the same transaction.
  /// Repeated or concurrent purchase requests can only charge once.
  Future<WardrobePurchase> buyWardrobeItem(
    String slot,
    String id,
    String base,
  ) async {
    final item = AvatarCatalog.item(slot, id);
    if (!item.supports(base)) {
      throw ArgumentError('Item does not fit this base');
    }
    return appDb.database.transaction((txn) async {
      final owned = _owned(await _value(txn, wardrobeOwnedKey));
      final coins =
          int.tryParse(await _value(txn, AppConstants.keyCoins) ?? '') ??
          AppConstants.startingCoins;
      if (item.isOwned(owned)) {
        return WardrobePurchase(coins, owned, alreadyOwned: true);
      }
      if (coins < item.price) {
        throw InsufficientWardrobeCoins(item.price, coins);
      }
      final balance = coins - item.price;
      owned.add(item.key);
      await _put(txn, AppConstants.keyCoins, '$balance');
      await _put(txn, wardrobeOwnedKey, jsonEncode(owned.toList()..sort()));
      await txn.update(DatabaseConstants.tablePlayerProfile, {
        DatabaseConstants.columnCoins: balance,
      });
      return WardrobePurchase(balance, owned);
    });
  }

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
    final avatar = profiles.isEmpty
        ? const PlayerAvatar()
        : PlayerAvatar.fromMap(profiles.first);
    final presets = _presets(saved[wardrobePresetsKey])
      ..[avatar.baseId] = avatar;
    return UserProfile(
      name: saved[AppConstants.keyPlayerName] ?? AppConstants.defaultPlayerName,
      coins:
          int.tryParse(saved[AppConstants.keyCoins] ?? '') ??
          AppConstants.startingCoins,
      totalStars: regionStars > stars ? regionStars : stars,
      avatar: avatar,
      ownedWardrobeItems: Set.unmodifiable(_owned(saved[wardrobeOwnedKey])),
      avatarPresets: Map.unmodifiable(presets),
    );
  }

  Future<void> saveAvatar(
    PlayerAvatar avatar, {
    Map<String, PlayerAvatar>? presets,
  }) async {
    // Opening is owned by the startup provider. An unavailable DB is an error,
    // not a successful in-memory save.
    final db = appDb.database;
    await db.transaction((txn) async {
      final owned = _owned(await _value(txn, wardrobeOwnedKey));
      final merged = _presets(await _value(txn, wardrobePresetsKey))
        ..addAll(presets ?? {})
        ..[avatar.baseId] = avatar;
      for (final entry in merged.entries) {
        if (!AvatarCatalog.bases.contains(entry.key) ||
            entry.key != entry.value.baseId ||
            !entry.value.canEquip(owned)) {
          throw StateError('Unlock this item before saving the outfit');
        }
      }
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
      await _put(
        txn,
        wardrobePresetsKey,
        jsonEncode(merged.map((key, value) => MapEntry(key, value.toJson()))),
      );
    });
  }

  Future<void> saveValue(String key, String value) async {
    await appDb.database.insert(DatabaseConstants.tableUserProgress, {
      DatabaseConstants.columnKey: key,
      DatabaseConstants.columnValue: value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Earned coins and wardrobe spending share SQLite's transaction boundary.
  Future<int> addCoins(int amount) => appDb.database.transaction((txn) async {
    final old =
        int.tryParse(await _value(txn, AppConstants.keyCoins) ?? '') ??
        AppConstants.startingCoins;
    final updated = old + amount < 0 ? 0 : old + amount;
    await _put(txn, AppConstants.keyCoins, '$updated');
    await txn.update(DatabaseConstants.tablePlayerProfile, {
      DatabaseConstants.columnCoins: updated,
    });
    return updated;
  });

  Future<void> saveName(String name) async {
    await saveValue(AppConstants.keyPlayerName, name);
    await appDb.database.update(DatabaseConstants.tablePlayerProfile, {
      DatabaseConstants.columnPlayerName: name,
    });
  }
}

class WardrobePurchase {
  WardrobePurchase(this.coins, Set<String> owned, {this.alreadyOwned = false})
    : owned = Set.unmodifiable(owned);
  final int coins;
  final Set<String> owned;
  final bool alreadyOwned;
}

class InsufficientWardrobeCoins implements Exception {
  const InsufficientWardrobeCoins(this.price, this.balance);
  final int price, balance;
}
