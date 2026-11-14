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
      final hasImagePath =
          sampleLocality != null &&
          sampleLocality.isNotEmpty &&
          sampleLocality.first.containsKey(DatabaseConstants.columnImagePath) &&
          sampleLocality.first[DatabaseConstants.columnImagePath] != null;

      if (localitiesCount == 0 ||
          localitiesCount != words.length ||
          !hasImagePath) {
        await db.execute(
          'DROP TABLE IF EXISTS ${DatabaseConstants.tableLocalities}',
        );
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
      final englishJson = await rootBundle.loadString(
        'assets/data/trivia_en.json',
      );
      final englishRegions = (json.decode(englishJson) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final englishByRegion = {
        for (final region in englishRegions) region['region_id'] as int: region,
      };
      for (final item in triviaList.cast<Map<String, dynamic>>()) {
        final translation =
            englishByRegion[item['region_id']]!['base'] as Map<String, dynamic>;
        final options = (translation['options'] as List<dynamic>)
            .cast<String>();
        item.addAll({
          'question_en': translation['question'],
          'option_a_en': options[0],
          'option_b_en': options[1],
          'option_c_en': options[2],
          'option_d_en': options[3],
          'explanation_en': translation['explanation'],
        });
      }
      final cultureJson = await rootBundle.loadString(
        'assets/data/regional_culture.json',
      );
      final cultureRegions = json.decode(cultureJson) as List<dynamic>;
      for (final region in cultureRegions.cast<Map<String, dynamic>>()) {
        final englishRegion = englishByRegion[region['region_id']]!;
        final englishQuestions = (englishRegion['culture'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        var questionIndex = 0;
        for (final question
            in (region['questions'] as List<dynamic>)
                .cast<Map<String, dynamic>>()) {
          final options = (question['options'] as List<dynamic>).cast<String>();
          final translation = englishQuestions[questionIndex++];
          final optionsEn = (translation['options'] as List<dynamic>)
              .cast<String>();
          triviaList.add({
            'region_id': region['region_id'],
            'question': question['question'],
            'option_a': options[0],
            'option_b': options[1],
            'option_c': options[2],
            'option_d': options[3],
            'correct_option': question['correct_option'],
            'explanation': question['explanation'],
            'question_en': translation['question'],
            'option_a_en': optionsEn[0],
            'option_b_en': optionsEn[1],
            'option_c_en': optionsEn[2],
            'option_d_en': optionsEn[3],
            'explanation_en': translation['explanation'],
            'image_path': region['image_path'],
            'image_caption': region['image_caption'],
            'image_caption_en': englishRegion['image_caption'],
            'image_credit': region['image_credit'],
          });
        }
      }
      final trivia = triviaList
          .map((item) => TriviaItem.fromMap(item as Map<String, dynamic>))
          .toList();

      // Repair installed single-answer datasets, including when row counts match.
      const contentKey = 'trivia_culture_traditions_v2';
      final contentVersion = await db.query(
        DatabaseConstants.tableUserProgress,
        where: '${DatabaseConstants.columnKey} = ?',
        whereArgs: [contentKey],
      );
      if (contentVersion.isEmpty) {
        for (final item in trivia) {
          final options = [
            item.optionA,
            item.optionB,
            item.optionC,
            item.optionD,
          ];
          if (options.any((s) => s.trim().isEmpty) ||
              options.toSet().length != 4 ||
              item.correctOption < 0 ||
              item.correctOption > 3) {
            throw FormatException('Trivia must have four unique choices');
          }
        }
        await db.transaction((txn) async {
          await txn.delete(DatabaseConstants.tableTrivia);
          await txn.delete(DatabaseConstants.tableTriviaQuestions);
          for (final item in trivia) {
            await txn.insert(DatabaseConstants.tableTrivia, item.toMap());
            await txn.insert(
              DatabaseConstants.tableTriviaQuestions,
              item.toTriviaQuestionMap(),
            );
          }
          await txn.insert(DatabaseConstants.tableUserProgress, {
            DatabaseConstants.columnKey: contentKey,
            DatabaseConstants.columnValue: '1',
          });
        });
      }

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
            ...t.toTriviaQuestionMap(),
          });
        }
        await batch.commit(noResult: true);
      }
      // Fill English fields in-place for installations already on culture v2.
      // No legacy question IDs, answers, player records, or progress are replaced.
      const englishContentKey = 'trivia_english_content_v1';
      final englishVersion = await db.query(
        DatabaseConstants.tableUserProgress,
        where: '${DatabaseConstants.columnKey} = ?',
        whereArgs: [englishContentKey],
      );
      if (englishVersion.isEmpty) {
        for (final item in trivia) {
          final englishFields = [
            item.questionEn,
            item.optionAEn,
            item.optionBEn,
            item.optionCEn,
            item.optionDEn,
            item.explanationEn,
          ];
          if (englishFields.any(
                (text) => text == null || text.trim().isEmpty,
              ) ||
              (item.imagePath != null &&
                  (item.imageCaptionEn?.trim().isEmpty ?? true))) {
            throw const FormatException(
              'Every bundled trivia item needs complete English content',
            );
          }
        }
        await db.transaction((txn) async {
          for (final item in trivia) {
            final english = item.toTriviaQuestionMap();
            await txn.update(
              DatabaseConstants.tableTriviaQuestions,
              {
                for (final field in [
                  'question_en',
                  'option_a_en',
                  'option_b_en',
                  'option_c_en',
                  'option_d_en',
                  'explanation_en',
                  'image_caption',
                ])
                  field: english[field],
              },
              where: 'region_id = ? AND question_fil = ?',
              whereArgs: [item.regionId, item.question],
            );
          }
          await txn.insert(DatabaseConstants.tableUserProgress, {
            DatabaseConstants.columnKey: englishContentKey,
            DatabaseConstants.columnValue: '1',
          });
        });
      }
    } catch (_) {
      // Gracefully handle headless/pure unit tests where rootBundle is uninitialized
    }
  }
}
