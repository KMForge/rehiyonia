import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../features/trivia/data/repositories/trivia_repository.dart';
import '../../features/trivia/models/trivia_item.dart';
import '../../features/word_search/data/repositories/word_repository.dart';
import '../../features/word_search/models/regional_word.dart';
import '../constants/database_constants.dart';
import 'app_database.dart';

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

      final triviaJson = await rootBundle.loadString('assets/data/trivia.json');
      final List<dynamic> triviaList = json.decode(triviaJson) as List<dynamic>;
      final trivia = triviaList
          .map((item) => TriviaItem.fromMap(item as Map<String, dynamic>))
          .toList();

      final triviaCount = await triviaRepo.countTrivia();
      if (triviaCount == 0) {
        await triviaRepo.insertTrivia(trivia);
      } else if (triviaCount < trivia.length) {
        final db = appDatabase.database;
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
    } catch (_) {
      // Gracefully handle headless/pure unit tests where rootBundle is uninitialized
    }
  }
}
