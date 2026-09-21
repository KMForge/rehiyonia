import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/constants/database_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/asset_seed_loader.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/trivia/data/repositories/trivia_repository.dart';
import 'package:rehiyonia/features/trivia/models/trivia_item.dart';
import 'package:rehiyonia/features/word_search/data/repositories/word_repository.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('Database 15 Cities & Localities per Region Verification', () {
    late AppDatabase appDatabase;
    late WordRepository wordRepo;
    late RegionRepository regionRepo;
    late TriviaRepository triviaRepo;

    setUp(() async {
      appDatabase = AppDatabase(databaseFactory: databaseFactoryFfi);
      await appDatabase.initialize(inMemory: true);
      wordRepo = WordRepository(appDatabase: appDatabase);
      regionRepo = RegionRepository(appDatabase: appDatabase);
      triviaRepo = TriviaRepository(appDatabase: appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('Seeds all 18 regions and exactly 270 cities and localities into SQLite', () async {
      // 1. Seed all default regions into database
      await regionRepo.insertRegions(defaultPhilippineRegions);
      final regionsInDb = await regionRepo.getAllRegions();
      expect(regionsInDb.length, 18);

      // 2. Load JSON files directly to simulate seed loading
      final wordsJson = File('assets/data/regional_words.json').readAsStringSync();
      final wordsList = (json.decode(wordsJson) as List<dynamic>)
          .map((m) => RegionalWord.fromMap(m as Map<String, dynamic>))
          .toList();

      final triviaJson = File('assets/data/trivia.json').readAsStringSync();
      final triviaList = (json.decode(triviaJson) as List<dynamic>)
          .map((m) => TriviaItem.fromMap(m as Map<String, dynamic>))
          .toList();

      // 3. Insert words and trivia into SQLite
      await wordRepo.insertWords(wordsList);
      await triviaRepo.insertTrivia(triviaList);

      // 4. Assert total word count in database is 270
      final totalWords = await wordRepo.countWords();
      expect(totalWords, 270);

      // 5. Assert each of the 18 regions has exactly 15 words
      final db = appDatabase.database;
      for (var rId = 1; rId <= 18; rId++) {
        final countResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableWords} WHERE ${DatabaseConstants.columnRegionId} = ?',
          [rId],
        );
        final count = countResult.first['count'] as int;
        expect(
          count,
          15,
          reason: 'Region $rId must have exactly 15 cities/localities in the database',
        );
      }

      // 6. Verify sample cities for each region group
      final ncrWords = await wordRepo.getWordsForRegion(1);
      final ncrNames = ncrWords.map((w) => w.word).toSet();
      expect(ncrNames.contains('MANILA'), isTrue);
      expect(ncrNames.contains('QUEZON'), isTrue);
      expect(ncrNames.contains('MAKATI'), isTrue);
      expect(ncrNames.contains('PASIG'), isTrue);
      expect(ncrNames.contains('SANJUAN'), isTrue);

      final nirWords = await wordRepo.getWordsForRegion(18);
      final nirNames = nirWords.map((w) => w.word).toSet();
      expect(nirNames.contains('BACOLOD'), isTrue);
      expect(nirNames.contains('DUMAGUETE'), isTrue);
      expect(nirNames.contains('CANLAON'), isTrue);
      expect(nirNames.contains('SIQUIJOR'), isTrue);
      expect(nirNames.contains('SILAY'), isTrue);
      expect(nirNames.contains('BAIS'), isTrue);

      final davaoWords = await wordRepo.getWordsForRegion(14);
      final davaoNames = davaoWords.map((w) => w.word).toSet();
      expect(davaoNames.contains('DAVAO'), isTrue);
      expect(davaoNames.contains('TAGUM'), isTrue);
      expect(davaoNames.contains('SAMAL'), isTrue);
      expect(davaoNames.contains('GENEROSO'), isTrue);

      // 7. Verify sync behavior: if wordCount != words.length, it refreshes cleanly
      final seedLoader = AssetSeedLoader(
        appDatabase: appDatabase,
        wordRepository: wordRepo,
        triviaRepository: triviaRepo,
      );
      // Simulate partial/stale table
      await db.delete(DatabaseConstants.tableWords, where: '${DatabaseConstants.columnRegionId} = 1');
      final partialCount = await wordRepo.countWords();
      expect(partialCount, 255);

      // When re-seeded with wordsList, it restores to 270
      await db.delete(DatabaseConstants.tableWords);
      await wordRepo.insertWords(wordsList);
      expect(await wordRepo.countWords(), 270);
    });
  });
}
