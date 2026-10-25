import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Progress persistence: verifies stars and region unlocking persist in database',
    (tester) async {
      final dbService = AppDatabase();
      final directory = await Directory.systemTemp.createTemp(
        'rehiyonia_test_',
      );
      final path = '${directory.path}/progress.db';
      addTearDown(() async {
        await dbService.close();
        await directory.delete(recursive: true);
      });
      await dbService.initialize(databasePath: path);
      final repo = RegionRepository(appDatabase: dbService);
      await repo.insertRegions(defaultPhilippineRegions);
      final regions = await repo.getAllRegions();
      expect(regions.isNotEmpty, isTrue);

      // Initial check: first region (NCR) is unlocked by default
      final ncr = regions.first;
      expect(ncr.isUnlocked, isTrue);

      // Update progress: award 3 stars to first region and unlock second region
      await repo.updateStars(ncr.id, 3);
      final secondRegion = regions[1];
      await repo.unlockRegion(secondRegion.id);

      const avatar = PlayerAvatar(
        baseId: 'female',
        glassesId: 'round',
        necklaceId: 'chain',
        topId: 'jacket',
        bottomId: 'shorts',
      );
      await ProfileRepository(dbService).saveAvatar(avatar);
      await ProfileRepository(dbService).completeNameCreation('Tala');
      await dbService.close();
      await dbService.initialize(databasePath: path);
      expect((await ProfileRepository(dbService).load()).avatar, avatar);
      expect((await ProfileRepository(dbService).load()).name, 'Tala');
      expect(await ProfileRepository(dbService).needsNameCreation(), isFalse);

      // Query after closing and reopening the isolated database.
      final updatedRegions = await repo.getAllRegions();
      final updatedNcr = updatedRegions.firstWhere((r) => r.id == ncr.id);
      final updatedSecond = updatedRegions.firstWhere(
        (r) => r.id == secondRegion.id,
      );

      expect(updatedNcr.starsEarned, equals(3));
      expect(updatedSecond.isUnlocked, isTrue);
    },
  );
}
