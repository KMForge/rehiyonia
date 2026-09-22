import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../features/trivia/data/repositories/trivia_repository.dart';
import '../../features/trivia/models/trivia_item.dart';
import '../../features/word_search/data/repositories/word_repository.dart';
import '../../features/word_search/models/regional_word.dart';
import '../constants/database_constants.dart';
import 'app_database.dart';
import 'database_tables.dart';

class AssetSeedLoader {
  const AssetSeedLoader({
    required this.appDatabase,
    this.wordRepository,
    this.triviaRepository,
  });

  final AppDatabase appDatabase;
  final WordRepository? wordRepository;
  final TriviaRepository? triviaRepository;

  Future<void> seedIfEmpty() async {
    final wordRepo = wordRepository ?? WordRepository(appDatabase: appDatabase);
    final triviaRepo =
        triviaRepository ?? TriviaRepository(appDatabase: appDatabase);

    try {
      final wordsJson = await rootBundle.loadString(
        'assets/data/regional_words.json',
      );
      final List<dynamic> wordsList = json.decode(wordsJson) as List<dynamic>;
      final words = wordsList
          .map((item) => RegionalWord.fromMap(item as Map<String, dynamic>))
          .toList();

      final wordCount = await wordRepo.countWords();
      if (wordCount == 0) {
        await wordRepo.insertWords(words);
      } else if (wordCount != words.length) {
        final db = appDatabase.database;
        await db.delete(DatabaseConstants.tableWords);
        await wordRepo.insertWords(words);
      }

      // Seed localities table (Database v2)
      final db = appDatabase.database;
      final localitiesCountRes = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableLocalities}',
      );
      final localitiesCount = (localitiesCountRes.first['count'] as int?) ?? 0;
      final sampleLocality = localitiesCount > 0
          ? await db.query(DatabaseConstants.tableLocalities, limit: 1)
          : null;
      final hasImagePath = sampleLocality != null &&
          sampleLocality.isNotEmpty &&
          sampleLocality.first.containsKey(DatabaseConstants.columnImagePath) &&
          sampleLocality.first[DatabaseConstants.columnImagePath] != null;

      if (localitiesCount == 0 || localitiesCount != words.length || !hasImagePath) {
        await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.tableLocalities}');
        await db.execute(DatabaseTables.createLocalitiesTable);
        final batch = db.batch();
        for (var i = 0; i < words.length; i++) {
          final w = words[i];
          // Top 10 per region are word search targets, remaining 5 are locality cards
          final isTarget = (i % 15) < 10;
          batch.insert(DatabaseConstants.tableLocalities, {
            DatabaseConstants.columnRegionId: w.regionId,
            DatabaseConstants.columnWord: w.word,
            DatabaseConstants.columnNameEn: w.displayNameEn,
            DatabaseConstants.columnNameFil: w.displayNameFil,
            DatabaseConstants.columnProvinceEn: w.provinceEn ?? '',
            DatabaseConstants.columnProvinceFil: w.provinceFil ?? '',
            DatabaseConstants.columnCategory: w.category,
            DatabaseConstants.columnDescriptionEn: w.displayClueEn,
            DatabaseConstants.columnDescriptionFil: w.displayClueFil,
            DatabaseConstants.columnFactEn: w.displayFactEn,
            DatabaseConstants.columnFactFil: w.displayFactFil,
            DatabaseConstants.columnImagePath: w.resolvedImagePath,
            DatabaseConstants.columnIsWordSearchTarget: isTarget ? 1 : 0,
          });
        }
        await batch.commit(noResult: true);
      }

      final triviaJson = await rootBundle.loadString('assets/data/trivia.json');
      final List<dynamic> triviaList = json.decode(triviaJson) as List<dynamic>;
      final trivia = triviaList
          .map((item) => TriviaItem.fromMap(item as Map<String, dynamic>))
          .toList();

      final triviaCount = await triviaRepo.countTrivia();
      if (triviaCount == 0) {
        await triviaRepo.insertTrivia(trivia);
      } else if (triviaCount < trivia.length) {
        final existingTrivia = await db.query(
          DatabaseConstants.tableTrivia,
          columns: [DatabaseConstants.columnRegionId],
        );
        final existingRegionIds = existingTrivia
            .map((t) => t['region_id'] as int)
            .toSet();
        final missingTrivia = trivia
            .where((t) => !existingRegionIds.contains(t.regionId))
            .toList();
        if (missingTrivia.isNotEmpty) {
          await triviaRepo.insertTrivia(missingTrivia);
        }
      }

      // Seed trivia_questions table (Database v2)
      final triviaQCountRes = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableTriviaQuestions}',
      );
      final triviaQCount = (triviaQCountRes.first['count'] as int?) ?? 0;
      if (triviaQCount == 0 || triviaQCount < trivia.length) {
        await db.delete(DatabaseConstants.tableTriviaQuestions);
        final batch = db.batch();
        for (final t in trivia) {
          batch.insert(DatabaseConstants.tableTriviaQuestions, {
            DatabaseConstants.columnRegionId: t.regionId,
            DatabaseConstants.columnQuestionEn: t.getQuestion(true),
            DatabaseConstants.columnQuestionFil: t.getQuestion(false),
            DatabaseConstants.columnOptionAEn: t.getOptionA(true),
            DatabaseConstants.columnOptionAFil: t.getOptionA(false),
            DatabaseConstants.columnOptionBEn: t.getOptionB(true),
            DatabaseConstants.columnOptionBFil: t.getOptionB(false),
            DatabaseConstants.columnOptionCEn: t.getOptionC(true),
            DatabaseConstants.columnOptionCFil: t.getOptionC(false),
            DatabaseConstants.columnOptionDEn: t.getOptionD(true),
            DatabaseConstants.columnOptionDFil: t.getOptionD(false),
            DatabaseConstants.columnCorrectOption: t.correctOption,
            DatabaseConstants.columnExplanationEn: t.getExplanation(true),
            DatabaseConstants.columnExplanationFil: t.getExplanation(false),
          });
        }
        await batch.commit(noResult: true);
      }
    } catch (_) {
      // Gracefully handle headless/pure unit tests where rootBundle is uninitialized
    }
  }
}
