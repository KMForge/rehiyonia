import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/avatar/data/avatar_catalog.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);
  late AppDatabase database;
  late ProfileRepository repo;
  setUp(() async {
    database = AppDatabase(databaseFactory: databaseFactoryFfi);
    await database.initialize(inMemory: true);
    repo = ProfileRepository(database);
    await repo.saveValue(AppConstants.keyCoins, '250');
  });
  tearDown(() => database.close());

  test('separate collections retain shared starters and accessories', () {
    expect(AvatarCatalog.itemsFor('top', 'male'), contains('varsity'));
    expect(AvatarCatalog.itemsFor('top', 'male'), isNot(contains('blouse')));
    expect(AvatarCatalog.itemsFor('top', 'female'), contains('blouse'));
    expect(AvatarCatalog.itemsFor('top', 'female'), isNot(contains('varsity')));
    expect(AvatarCatalog.itemsFor('shoes', 'female'), contains('heels'));
    expect(AvatarCatalog.item('top', 'explorer').price, 0);
    for (final base in AvatarCatalog.bases) {
      expect(PlayerAvatar.starter(base).canEquip({}), isTrue);
      expect(AvatarCatalog.itemsFor('earrings', base), contains('star_drops'));
    }
  });

  test(
    'double purchase charges once and shared ownership works on both bases',
    () async {
      final results = await Future.wait([
        repo.buyWardrobeItem('necklace', 'pearls', 'male'),
        repo.buyWardrobeItem('necklace', 'pearls', 'female'),
      ]);
      expect(results.where((r) => !r.alreadyOwned).length, 1);
      final profile = await repo.load();
      expect(profile.coins, 180);
      expect(profile.ownedWardrobeItems, {'necklace/pearls'});
    },
  );

  test(
    'concurrent purchases and earned coins preserve the authoritative balance',
    () async {
      await Future.wait<Object?>([
        repo.buyWardrobeItem('headwear', 'beret', 'male'),
        repo.buyWardrobeItem('bracelet', 'gem_cuff', 'female'),
        repo.addCoins(5),
      ]);
      final profile = await repo.load();
      expect(profile.coins, 85);
      expect(profile.ownedWardrobeItems, {
        'headwear/beret',
        'bracelet/gem_cuff',
      });
    },
  );

  test(
    'insufficient balance, incompatible base and unknown IDs never spend coins',
    () async {
      await repo.saveValue(AppConstants.keyCoins, '50');
      await expectLater(
        repo.buyWardrobeItem('shoes', 'heels', 'female'),
        throwsA(isA<InsufficientWardrobeCoins>()),
      );
      await expectLater(
        repo.buyWardrobeItem('shoes', 'heels', 'male'),
        throwsArgumentError,
      );
      await expectLater(
        repo.buyWardrobeItem('top', 'unknown', 'male'),
        throwsArgumentError,
      );
      expect((await repo.load()).coins, 50);
      expect((await repo.load()).ownedWardrobeItems, isEmpty);
    },
  );

  test('ownership write failure rolls back the coin debit', () async {
    await database.database.execute("""
      CREATE TRIGGER reject_purchase BEFORE INSERT ON user_progress
      WHEN NEW.setting_key = 'wardrobe_owned_v1'
      BEGIN SELECT RAISE(ABORT, 'simulated disk write failure'); END
    """);
    await expectLater(
      repo.buyWardrobeItem('headwear', 'beret', 'male'),
      throwsA(isA<Exception>()),
    );
    expect((await repo.load()).coins, 250);
    expect((await repo.load()).ownedWardrobeItems, isEmpty);
  });

  test(
    'locked or incompatible outfits cannot be saved through the repository',
    () async {
      const locked = PlayerAvatar(topId: 'varsity');
      await expectLater(repo.saveAvatar(locked), throwsStateError);
      expect((await repo.load()).avatar.topId, 'tee');
      await repo.buyWardrobeItem('top', 'varsity', 'male');
      await repo.saveAvatar(locked);
      expect((await repo.load()).avatar.topId, 'varsity');
      await expectLater(
        repo.saveAvatar(locked.copyWith(baseId: 'female')),
        throwsStateError,
      );
    },
  );

  test(
    'separate outfits, jewelry, purchases and balance survive database reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rehiyonia_wardrobe_',
      );
      final disk = AppDatabase(databaseFactory: databaseFactoryFfi);
      try {
        final path = '${directory.path}/wardrobe.db';
        await disk.initialize(databasePath: path);
        final storage = ProfileRepository(disk);
        await storage.saveValue(AppConstants.keyCoins, '400');
        await storage.buyWardrobeItem('shoes', 'heels', 'female');
        await storage.buyWardrobeItem('earrings', 'hoops', 'female');
        const male = PlayerAvatar(
          topId: 'striped_tee',
          bottomId: 'chinos',
          braceletId: 'woven',
        );
        final female = PlayerAvatar.starter('female')
            .copyWith(shoesId: 'heels', earringsId: 'hoops');
        await storage.saveAvatar(
          female,
          presets: {'male': male, 'female': female},
        );
        await disk.close();
        await disk.initialize(databasePath: path);
        final profile = await storage.load();
        expect(profile.coins, 200);
        expect(profile.ownedWardrobeItems, {'shoes/heels', 'earrings/hoops'});
        expect(profile.avatar, female);
        expect(profile.avatarPresets, {'male': male, 'female': female});
        await storage.saveAvatar(male);
        expect((await storage.load()).avatarPresets['female'], female);
      } finally {
        await disk.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
