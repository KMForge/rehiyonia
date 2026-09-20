import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('RegionRepository Tests', () {
    late AppDatabase appDatabase;
    late RegionRepository repository;

    setUp(() async {
      appDatabase = AppDatabase(databaseFactory: databaseFactoryFfi);
      await appDatabase.initialize(inMemory: true);
      repository = RegionRepository(appDatabase: appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('inserts and retrieves regions correctly', () async {
      final initial = await repository.getAllRegions();
      expect(initial, isEmpty);

      const testRegion = Region(
        id: 1,
        code: 'NCR',
        name: 'Pambansang Punong Rehiyon',
        designation: 'NCR',
        islandGroup: 'Luzon',
        description: 'Metropolitan Manila',
        isUnlocked: true,
      );

      await repository.insertRegions([testRegion]);

      final loaded = await repository.getAllRegions();
      expect(loaded.length, 1);
      expect(loaded.first.code, 'NCR');
      expect(loaded.first.isUnlocked, isTrue);
    });

    test('unlocks locked region', () async {
      const lockedRegion = Region(
        id: 2,
        code: 'CAR',
        name: 'Cordillera',
        designation: 'CAR',
        islandGroup: 'Luzon',
        description: 'Mountain region',
        isUnlocked: false,
      );

      await repository.insertRegions([lockedRegion]);
      await repository.unlockRegion(2);

      final updated = await repository.getRegionByCode('CAR');
      expect(updated, isNotNull);
      expect(updated!.isUnlocked, isTrue);
    });

    test('updates stars earned for a region', () async {
      const region = Region(
        id: 3,
        code: 'REGION_I',
        name: 'Ilocos',
        designation: 'Region I',
        islandGroup: 'Luzon',
        description: 'Ilocos region',
        starsEarned: 0,
      );

      await repository.insertRegions([region]);
      await repository.updateStars(3, 3);

      final updated = await repository.getRegionByCode('REGION_I');
      expect(updated, isNotNull);
      expect(updated!.starsEarned, 3);
    });
  });
}
