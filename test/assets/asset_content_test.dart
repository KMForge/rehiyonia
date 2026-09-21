import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Asset Content & Educational Dataset Tests', () {
    test('regional_words.json has valid structure and 15 cities/localities for all 18 regions', () {
      final file = File('assets/data/regional_words.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'regional_words.json must exist',
      );

      final content = file.readAsStringSync();
      final List<dynamic> jsonList = json.decode(content) as List<dynamic>;

      expect(
        jsonList.length,
        equals(270),
        reason:
            'Expected exactly 270 entries (18 regions * 15 cities/localities)',
      );

      final regionWordCounts = <int, int>{};
      final validWordPattern = RegExp(r'^[A-Z]+$');

      for (final item in jsonList) {
        final map = item as Map<String, dynamic>;
        expect(map['region_id'], isA<int>());
        expect(map['word'], isA<String>());
        expect(map['category'], isA<String>());
        expect(map['clue'], isA<String>());

        final word = map['word'] as String;
        expect(
          validWordPattern.hasMatch(word),
          isTrue,
          reason: 'Word "$word" must only contain uppercase letters A-Z',
        );

        final rId = map['region_id'] as int;
        regionWordCounts[rId] = (regionWordCounts[rId] ?? 0) + 1;
      }

      // All 18 Philippine regions (including NIR) must have exactly 15 words
      for (var id = 1; id <= 18; id++) {
        expect(
          regionWordCounts[id],
          equals(15),
          reason:
              'Region ID $id must have exactly 15 cities and localities in regional_words.json',
        );
      }
    });

    test('trivia.json has valid AP Grade 5 questions for all 18 regions', () {
      final file = File('assets/data/trivia.json');
      expect(file.existsSync(), isTrue, reason: 'trivia.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> jsonList = json.decode(content) as List<dynamic>;

      expect(jsonList.length, greaterThanOrEqualTo(18));

      final regionIds = <int>{};
      for (final item in jsonList) {
        final map = item as Map<String, dynamic>;
        expect(map['region_id'], isA<int>());
        expect(map['question'], isNotEmpty);
        expect(map['answer'], isNotEmpty);
        expect(map['fun_fact'], isNotEmpty);

        regionIds.add(map['region_id'] as int);
      }

      for (var id = 1; id <= 18; id++) {
        expect(
          regionIds.contains(id),
          isTrue,
          reason: 'Region ID $id must have trivia in trivia.json',
        );
      }
    });

    test('Offline audio files exist and have non-zero size', () {
      final buttonClick = File('assets/audio/sound_effects/button_click.wav');
      final wordFound = File('assets/audio/sound_effects/word_found.wav');
      final puzzleComplete = File(
        'assets/audio/sound_effects/puzzle_complete.wav',
      );
      final mainTheme = File('assets/audio/music/main_theme.wav');

      expect(buttonClick.existsSync(), isTrue);
      expect(buttonClick.lengthSync(), greaterThan(100));

      expect(wordFound.existsSync(), isTrue);
      expect(wordFound.lengthSync(), greaterThan(100));

      expect(puzzleComplete.existsSync(), isTrue);
      expect(puzzleComplete.lengthSync(), greaterThan(100));

      expect(mainTheme.existsSync(), isTrue);
      expect(mainTheme.lengthSync(), greaterThan(100));
    });
  });
}
