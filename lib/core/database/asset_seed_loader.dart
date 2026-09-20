import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../features/trivia/data/repositories/trivia_repository.dart';
import '../../features/trivia/models/trivia_item.dart';
import '../../features/word_search/data/repositories/word_repository.dart';
import '../../features/word_search/models/regional_word.dart';
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
      final wordCount = await wordRepo.countWords();
      if (wordCount == 0) {
        final wordsJson = await rootBundle.loadString(
          'assets/data/regional_words.json',
        );
        final List<dynamic> wordsList = json.decode(wordsJson) as List<dynamic>;
        final words = wordsList
            .map((item) => RegionalWord.fromMap(item as Map<String, dynamic>))
            .toList();
        await wordRepo.insertWords(words);
      }

      final triviaCount = await triviaRepo.countTrivia();
      if (triviaCount == 0) {
        final triviaJson = await rootBundle.loadString(
          'assets/data/trivia.json',
        );
        final List<dynamic> triviaList =
            json.decode(triviaJson) as List<dynamic>;
        final trivia = triviaList
            .map((item) => TriviaItem.fromMap(item as Map<String, dynamic>))
            .toList();
        await triviaRepo.insertTrivia(trivia);
      }
    } catch (_) {
      // Gracefully handle headless/pure unit tests where rootBundle is uninitialized
    }
  }
}
