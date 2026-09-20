import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../core/constants/database_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/asset_seed_loader.dart';
import '../../models/regional_word.dart';

class WordRepository {
  const WordRepository({required this.appDatabase});

  final AppDatabase appDatabase;

  Future<sqflite.Database> _getDb() async {
    if (!appDatabase.isOpen) {
      return appDatabase.initialize();
    }
    return appDatabase.database;
  }

  Future<List<RegionalWord>> getWordsForRegion(int regionId) async {
    final db = await _getDb();
    var maps = await db.query(
      DatabaseConstants.tableWords,
      where: '${DatabaseConstants.columnRegionId} = ?',
      whereArgs: [regionId],
      orderBy: '${DatabaseConstants.columnId} ASC',
    );

    if (maps.isEmpty) {
      final seedLoader = AssetSeedLoader(
        appDatabase: appDatabase,
        wordRepository: this,
      );
      await seedLoader.seedIfEmpty();
      maps = await db.query(
        DatabaseConstants.tableWords,
        where: '${DatabaseConstants.columnRegionId} = ?',
        whereArgs: [regionId],
        orderBy: '${DatabaseConstants.columnId} ASC',
      );
    }

    return maps.map(RegionalWord.fromMap).toList();
  }

  Future<void> insertWords(List<RegionalWord> words) async {
    final db = await _getDb();
    final batch = db.batch();
    for (final word in words) {
      batch.insert(DatabaseConstants.tableWords, word.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> countWords() async {
    final db = await _getDb();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableWords}',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
