import '../../../../core/constants/database_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../models/region.dart';

class RegionRepository {
  const RegionRepository({required this.appDatabase});

  final AppDatabase appDatabase;

  Future<List<Region>> getAllRegions() async {
    final db = appDatabase.database;
    final maps = await db.query(
      DatabaseConstants.tableRegions,
      orderBy: '${DatabaseConstants.columnId} ASC',
    );
    return maps.map(Region.fromMap).toList();
  }

  Future<Region?> getRegionByCode(String code) async {
    final db = appDatabase.database;
    final maps = await db.query(
      DatabaseConstants.tableRegions,
      where: '${DatabaseConstants.columnRegionCode} = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Region.fromMap(maps.first);
  }

  Future<void> unlockRegion(int id) async {
    final db = appDatabase.database;
    await db.update(
      DatabaseConstants.tableRegions,
      {
        DatabaseConstants.columnIsUnlocked: 1,
        DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateStars(int id, int stars) async {
    final db = appDatabase.database;
    await db.update(
      DatabaseConstants.tableRegions,
      {
        DatabaseConstants.columnStarsEarned: stars,
        DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertRegions(List<Region> regions) async {
    final db = appDatabase.database;
    final batch = db.batch();
    for (final region in regions) {
      batch.insert(
        DatabaseConstants.tableRegions,
        region.toMap(),
      );
    }
    await batch.commit(noResult: true);
  }
}
