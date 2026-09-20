import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../core/constants/database_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/asset_seed_loader.dart';
import '../../models/trivia_item.dart';

class TriviaRepository {
  const TriviaRepository({required this.appDatabase});

  final AppDatabase appDatabase;

  Future<sqflite.Database> _getDb() async {
    if (!appDatabase.isOpen) {
      return appDatabase.initialize();
    }
    return appDatabase.database;
  }

  Future<List<TriviaItem>> getTriviaForRegion(int regionId) async {
    final db = await _getDb();
    var maps = await db.query(
      DatabaseConstants.tableTrivia,
      where: '${DatabaseConstants.columnRegionId} = ?',
      whereArgs: [regionId],
      orderBy: '${DatabaseConstants.columnId} ASC',
    );

    if (maps.isEmpty) {
      final seedLoader = AssetSeedLoader(
        appDatabase: appDatabase,
        triviaRepository: this,
      );
      await seedLoader.seedIfEmpty();
      maps = await db.query(
        DatabaseConstants.tableTrivia,
        where: '${DatabaseConstants.columnRegionId} = ?',
        whereArgs: [regionId],
        orderBy: '${DatabaseConstants.columnId} ASC',
      );
    }

    return maps.map(TriviaItem.fromMap).toList();
  }

  Future<void> insertTrivia(List<TriviaItem> items) async {
    final db = await _getDb();
    final batch = db.batch();
    for (final item in items) {
      batch.insert(DatabaseConstants.tableTrivia, item.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> countTrivia() async {
    final db = await _getDb();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableTrivia}',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
