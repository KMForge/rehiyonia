import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/badges/regional_badges.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';

void main() {
  setUpAll(sqfliteFfiInit);
  test('17-region installation gains NIR once without resetting progress; badge survives reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rehiyonia_badges_',
    );
    final path = '${directory.path}/badges.db';
    final database = AppDatabase(databaseFactory: databaseFactoryFfi);
    ProviderContainer? session;
    try {
      await database.initialize(databasePath: path);
      final regions = RegionRepository(appDatabase: database);
      await regions.insertRegions([
        for (final region in defaultPhilippineRegions.where(
          (region) => region.code != 'NIR',
        ))
          region.copyWith(starsEarned: region.id == 1 ? 3 : 0),
      ]);
      final profile = ProfileRepository(database);
      const avatar = PlayerAvatar(
        skinIndex: 2,
        hairStyleIndex: 3,
        outfitColorIndex: 1,
      );
      await profile.saveName('Maya');
      await profile.saveValue(AppConstants.keyCoins, '137');
      await profile.saveAvatar(avatar);
      final savedRegions = await database.database.query(
        'regions',
        orderBy: 'id',
      );
      final savedProgress = await database.database.query('user_progress');
      final savedProfile = await database.database.query('player_profile');

      session = ProviderContainer(
        overrides: [regionRepositoryProvider.overrideWithValue(regions)],
      );
      final loaded = await session.read(regionsProvider.future);
      expect(loaded.length, 18);
      final nir = loaded.singleWhere((region) => region.code == 'NIR');
      expect(nir.id, 18);
      expect(nir.isUnlocked, isFalse);
      expect(nir.starsEarned, 0);
      expect(
        await database.database.query(
          'regions',
          where: 'id != ?',
          whereArgs: [18],
          orderBy: 'id',
        ),
        savedRegions,
      );
      expect(await database.database.query('user_progress'), savedProgress);
      expect(await database.database.query('player_profile'), savedProfile);
      session.invalidate(regionsProvider);
      expect((await session.read(regionsProvider.future)).length, 18);

      await regions.unlockRegion(nir.id);
      await regions.updateStars(nir.id, 2);
      session.dispose();
      session = null;
      await database.close();
      await database.initialize(databasePath: path);
      session = ProviderContainer(
        overrides: [regionRepositoryProvider.overrideWithValue(regions)],
      );
      final restored = regionalBadgeRegions(
        await session.read(regionsProvider.future),
      );
      expect(restored.length, 18);
      expect(restored.map((region) => region.id).toSet().length, 18);
      expect(
        restored
            .where((region) => region.isUnlocked && region.starsEarned > 0)
            .length,
        2,
      );
      final earnedNir = restored.singleWhere((region) => region.id == 18);
      expect(earnedNir.code, 'NIR');
      expect(earnedNir.isUnlocked, isTrue);
      expect(earnedNir.starsEarned, 2);
      final restoredProfile = await profile.load();
      expect(restoredProfile.name, 'Maya');
      expect(restoredProfile.coins, 137);
      expect(restoredProfile.avatar, avatar);
      expect(await database.database.query('user_progress'), savedProgress);
    } finally {
      session?.dispose();
      await database.close();
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        final file = File('$path$suffix');
        if (await file.exists()) await file.delete();
      }
      await directory.delete();
    }
  });
}
