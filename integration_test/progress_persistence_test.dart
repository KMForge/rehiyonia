import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Progress persistence: verifies stars and region unlocking persist in database',
    (tester) async {
      final dbService = AppDatabase();
      final repo = RegionRepository(appDatabase: dbService);
      final regions = await repo.getAllRegions();
      expect(regions.isNotEmpty, isTrue);

      // Initial check: first region (NCR) is unlocked by default
      final ncr = regions.first;
      expect(ncr.isUnlocked, isTrue);

      // Update progress: award 3 stars to first region and unlock second region
      await repo.updateStars(ncr.id, 3);
      final secondRegion = regions[1];
      await repo.unlockRegion(secondRegion.id);

      // Query back from fresh database query
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
