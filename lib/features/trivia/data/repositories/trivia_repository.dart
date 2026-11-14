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

    // Keep legacy IDs, answer order, and Filipino content as the source of truth;
    // read the translations from the existing bilingual table.
    final translations = await db.query(
      DatabaseConstants.tableTriviaQuestions,
      where: '${DatabaseConstants.columnRegionId} = ?',
      whereArgs: [regionId],
    );
    final byQuestion = {
      for (final row in translations) row['question_fil']: row,
    };
    return maps.map((row) {
      final translation = byQuestion[row['question']];
      return TriviaItem.fromMap({
        ...row,
        if (translation != null) ...{
          for (final field in [
            'question_en',
            'option_a_en',
            'option_b_en',
            'option_c_en',
            'option_d_en',
            'explanation_en',
          ])
            field: translation[field],
          'image_caption_en': translation['image_caption'],
        },
      });
    }).toList();
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
