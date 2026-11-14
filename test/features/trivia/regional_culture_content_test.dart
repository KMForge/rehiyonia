import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'all 18 regions have two sourced culture questions and offline photos',
    () {
      final regions = (jsonDecode(
        File('assets/data/regional_culture.json').readAsStringSync(),
      ) as List).cast<Map<String, dynamic>>();
      final credits = (jsonDecode(
        File('assets/data/culture_image_credits.json').readAsStringSync(),
      ) as List).cast<Map<String, dynamic>>();
      expect(regions.map((r) => r['region_id']).toSet(), {
        for (var id = 1; id <= 18; id++) id,
      });
      expect(credits, hasLength(18));
      for (final region in regions) {
        final questions = region['questions'] as List;
        expect(questions, hasLength(2));
        expect(Uri.parse(region['source_url'] as String).scheme, 'https');
        for (final question in questions.cast<Map<String, dynamic>>()) {
          final choices = (question['options'] as List).cast<String>();
          expect(choices.toSet(), hasLength(4));
          expect(choices.every((c) => c.trim().isNotEmpty), isTrue);
          expect(question['correct_option'], inInclusiveRange(0, 3));
          expect(question['explanation'], isNotEmpty);
        }
        final photo = File(region['image_path'] as String);
        expect(photo.existsSync(), isTrue, reason: photo.path);
        final bytes = photo.readAsBytesSync();
        expect(bytes.length, greaterThan(1000));
        expect(bytes.take(2), [
          0xff,
          0xd8,
        ], reason: 'Photo must be a real JPEG');
        final credit = credits.singleWhere(
          (c) => c['region_id'] == region['region_id'],
        );
        expect(credit['asset_path'], region['image_path']);
        expect(credit['author'], isNotEmpty);
        expect(credit['license'], isNotEmpty);
        expect(
          credit['source_url'],
          startsWith('https://commons.wikimedia.org/'),
        );
      }
    },
  );
}
