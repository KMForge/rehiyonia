import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/database_constants.dart';
import '../../../shared/providers/app_initialization_provider.dart';
import '../../avatar/models/player_avatar.dart';
import '../../regions/providers/region_provider.dart';
import '../models/user_profile.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    Future.microtask(() => loadProfile());
    return const UserProfile();
  }

  Future<void> loadProfile() async {
    try {
      final appDb = ref.read(appDatabaseProvider);
      if (!appDb.isOpen) return;

      final db = appDb.database;
      final rows = await db.query(DatabaseConstants.tableUserProgress);

      String name = AppConstants.defaultPlayerName;
      int coins = AppConstants.startingCoins;
      int totalStars = 0;

      for (final row in rows) {
        final key = row[DatabaseConstants.columnKey] as String?;
        final val = row[DatabaseConstants.columnValue] as String?;
        if (key == AppConstants.keyPlayerName &&
            val != null &&
            val.trim().isNotEmpty) {
          name = val.trim();
        } else if (key == AppConstants.keyCoins && val != null) {
          coins = int.tryParse(val) ?? coins;
        } else if (key == AppConstants.keyTotalStars && val != null) {
          totalStars = int.tryParse(val) ?? totalStars;
        }
      }

      // Also calculate total stars from regions table if available
      try {
        final regionRepo = ref.read(regionRepositoryProvider);
        final regions = await regionRepo.getAllRegions();
        final starSum = regions.fold<int>(0, (sum, r) => sum + r.starsEarned);
        if (starSum > totalStars) {
          totalStars = starSum;
        }
      } catch (_) {}

      // Load avatar from player_profile table
      PlayerAvatar avatar = const PlayerAvatar();
      try {
        final profileRows = await db.query(
          DatabaseConstants.tablePlayerProfile,
        );
        if (profileRows.isNotEmpty) {
          avatar = PlayerAvatar.fromMap(profileRows.first);
        }
      } catch (_) {}

      state = UserProfile(
        name: name,
        coins: coins,
        totalStars: totalStars,
        avatar: avatar,
      );
    } catch (_) {}
  }

  Future<void> setPlayerName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(name: trimmed);
    await _persistValue(AppConstants.keyPlayerName, trimmed);
    try {
      final appDb = ref.read(appDatabaseProvider);
      if (appDb.isOpen) {
        await appDb.database.update(DatabaseConstants.tablePlayerProfile, {
          DatabaseConstants.columnPlayerName: trimmed,
        });
      }
    } catch (_) {}
  }

  Future<void> setAvatar(PlayerAvatar newAvatar) async {
    state = state.copyWith(avatar: newAvatar);
    try {
      final appDb = ref.read(appDatabaseProvider);
      if (appDb.isOpen) {
        final db = appDb.database;
        final rows = await db.query(DatabaseConstants.tablePlayerProfile);
        if (rows.isEmpty) {
          await db.insert(
            DatabaseConstants.tablePlayerProfile,
            newAvatar.toMap(),
          );
        } else {
          await db.update(
            DatabaseConstants.tablePlayerProfile,
            newAvatar.toMap(),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> setCoins(int amount) async {
    final clamped = amount < 0 ? 0 : amount;
    state = state.copyWith(coins: clamped);
    await _persistValue(AppConstants.keyCoins, clamped.toString());
  }

  Future<void> addCoins(int amount) async {
    await setCoins(state.coins + amount);
  }

  Future<void> addStars(int amount) async {
    final total = state.totalStars + amount;
    state = state.copyWith(totalStars: total);
    await _persistValue(AppConstants.keyTotalStars, total.toString());
  }

  Future<void> _persistValue(String key, String value) async {
    try {
      final appDb = ref.read(appDatabaseProvider);
      if (appDb.isOpen) {
        final db = appDb.database;
        await db.insert(DatabaseConstants.tableUserProgress, {
          DatabaseConstants.columnKey: key,
          DatabaseConstants.columnValue: value,
          DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (_) {}
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
