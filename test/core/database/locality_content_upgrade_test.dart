import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/asset_seed_loader.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/word_search/data/repositories/word_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  final words = (jsonDecode(
    File('assets/data/regional_words.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();
  final reviewed = words
      .where((w) => w['content_revision'] == 'locality_learning_2026_11_v2')
      .toList();
  final references = (jsonDecode(
    File('assets/data/locality_content_sources.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();
  final pinned =
      (jsonDecode(
                File('tool/locality_psgc_reference.json').readAsStringSync(),
              )['records']
              as List)
          .cast<Map<String, dynamic>>();

  test('all 179 former census replacements have distinct bilingual local highlights', () {
    final additions = (jsonDecode(
      File('assets/data/locality_content_additions.json').readAsStringSync(),
    ) as List).cast<Map<String, dynamic>>();
    expect(additions, hasLength(179));
    expect(additions.map((h) => h['key']).toSet(), hasLength(179));
    expect(additions.map((h) => h['en']).toSet(), hasLength(179));
    expect(additions.map((h) => h['fil']).toSet(), hasLength(179));
    for (final highlight in additions) {
      final row = reviewed.singleWhere(
        (w) => '${w['region_id']}:${w['word']}' == highlight['key'],
      );
      expect(row['fact_en'], highlight['en']);
      expect(row['fact_fil'], highlight['fil']);
      expect(row['source_urls'], contains(highlight['url']));
    }
    final panglima = reviewed.singleWhere(
      (w) => w['region_id'] == 17 && w['word'] == 'PANGLIMA',
    );
    expect(panglima['fact_en'], contains('barter market'));
    final tandag = reviewed.singleWhere(
      (w) => w['region_id'] == 16 && w['word'] == 'TANDAG',
    );
    expect(tandag['fact_en'], contains('Sangka-an'));
  });

  test('234 replacements have bilingual copy, official claim references and honest review scope', () {
    expect(words, hasLength(270));
    expect(reviewed, hasLength(234));
    expect(references, hasLength(234));
    expect(pinned, hasLength(234));
    expect(pinned.map((r) => r['code']).toSet(), hasLength(234));
    expect(
      references.map((r) => '${r['region_id']}:${r['word']}').toSet(),
      reviewed.map((w) => '${w['region_id']}:${w['word']}').toSet(),
    );
    for (final w in words) {
      expect(w['description_en'], isNot(contains('prominent')));
      expect(w['fact_en'], isNot(contains('boasts unique local traditions')));
    }
    for (final w in reviewed) {
      for (final field in [
        'description_en',
        'description_fil',
        'fact_en',
        'fact_fil',
        'province_en',
        'province_fil',
      ]) {
        expect(
          (w[field] as String).trim(),
          isNotEmpty,
          reason: '${w['word']}: $field',
        );
      }
      final source = references.singleWhere(
        (r) => r['region_id'] == w['region_id'] && r['word'] == w['word'],
      );
      for (final url in [
        ...source['description_sources'],
        ...source['fact_sources'],
      ]) {
        final uri = Uri.parse(url as String);
        expect(uri.scheme, 'https');
        expect(
          uri.host.endsWith('.gov.ph') || uri.host == 'www.msumain.edu.ph',
          isTrue,
          reason: url,
        );
        expect(uri.host.contains('wikipedia'), isFalse);
      }
      expect(source['review_status'], 'source_checked');
      expect(
        source['fact_topic'],
        'local_history_culture_nature_or_livelihood',
      );
      expect(source.containsKey('follow_up'), isFalse);
      expect(w['fact_en'], isNot(contains('The 2024 census counted')));
      expect(w['fact_fil'], isNot(contains('Naitala sa senso noong 2024')));
    }
    Map<String, dynamic> entry(int region, String word) =>
        words.singleWhere((w) => w['region_id'] == region && w['word'] == word);
    expect(entry(9, 'WASHINGTON')['name_en'], 'New Washington');
    expect(entry(15, 'PIGCAWAYAN')['name_en'], 'Pigkawayan');
    expect(entry(7, 'SANJOSE')['province_en'], 'Occidental Mindoro');
    expect(entry(7, 'ROXAS')['province_en'], 'Palawan');
    expect(entry(10, 'DANAO')['province_en'], 'Cebu');
    expect(entry(12, 'ISABELA')['province_en'], 'Basilan');
    expect(entry(12, 'JOLO')['province_en'], 'Sulu');
    expect(entry(17, 'PANGLIMA')['name_en'], 'Panglima Sugala');
    expect(entry(15, 'TBOLI')['fact_en'], contains('Lake Holon'));
    expect(entry(6, 'LOSBANOS')['fact_en'], contains('remains a municipality'));
    for (var id = 1; id <= 18; id++) {
      expect(words.where((w) => w['region_id'] == id), hasLength(15));
    }
  });

  test('existing saves refresh all 234 cards and discovery facts without changing identity, targets or progress', () async {
    final folder = await Directory.systemTemp.createTemp('rehiyonia_content_');
    final db = AppDatabase(databaseFactory: databaseFactoryFfi);
    final path = '${folder.path}/existing.db';
    addTearDown(() async {
      await db.close();
      await folder.delete(recursive: true);
    });
    await db.initialize(databasePath: path);
    await RegionRepository(appDatabase: db)
        .insertRegions(defaultPhilippineRegions);
    await AssetSeedLoader(appDatabase: db).seedIfEmpty();
    await db.database.insert('user_progress', {
      'setting_key': 'region_2_found_words',
      'setting_value': '["BANGUED"]',
    });
    await db.database.update('regions', {
      'stars_earned': 3,
      'is_unlocked': 1,
    }, where: 'id IN (2,18)');
    await db.database.update('localities', {
      'name_en': 'Old name',
      'province_en': '',
      'description_en': 'Old generic description',
      'description_fil': 'Lumang paglalarawan',
      'fact_en': 'The 2024 census counted people. Old census-only content.',
      'fact_fil': 'Naitala sa senso noong 2024 ang mga tao.',
    }, where: 'region_id = 2 OR region_id BETWEEN 4 AND 18');
    final ids = await db.database.query(
      'localities',
      columns: [
        'id',
        'region_id',
        'word',
        'image_path',
        'is_word_search_target',
      ],
      orderBy: 'id',
    );
    final beforeRegions = await db.database.query('regions', orderBy: 'id');
    final profile = await db.database.query('player_profile');
    final progress = await db.database.query(
      'user_progress',
      orderBy: 'setting_key',
    );
    final version = await db.database.rawQuery('PRAGMA user_version');
    await db.close();
    await db.initialize(databasePath: path);
    final loader = AssetSeedLoader(appDatabase: db);
    await loader.seedIfEmpty();
    await loader.seedIfEmpty();
    expect(
      await db.database.query(
        'localities',
        columns: [
          'id',
          'region_id',
          'word',
          'image_path',
          'is_word_search_target',
        ],
        orderBy: 'id',
      ),
      ids,
    );
    expect(await db.database.query('regions', orderBy: 'id'), beforeRegions);
    expect(await db.database.query('player_profile'), profile);
    expect(
      await db.database.query('user_progress', orderBy: 'setting_key'),
      progress,
    );
    expect(await db.database.rawQuery('PRAGMA user_version'), version);
    final saved = await db.database.query('localities');
    for (final w in reviewed) {
      final row = saved.singleWhere(
        (r) => r['region_id'] == w['region_id'] && r['word'] == w['word'],
      );
      for (final field in [
        'name_en',
        'name_fil',
        'province_en',
        'province_fil',
        'description_en',
        'description_fil',
        'fact_en',
        'fact_fil',
      ]) {
        expect(
          row[field],
          w[field],
          reason: '${w['region_id']}:${w['word']} $field',
        );
      }
    }
    final discoveryWords = await WordRepository(appDatabase: db)
        .getWordsForRegion(2);
    expect(
      discoveryWords.singleWhere((w) => w.word == 'TUBA').displayFactEn,
      contains('BenCab'),
    );
    expect(
      discoveryWords.singleWhere((w) => w.word == 'BANGUED').displayClueEn,
      contains('Abra'),
    );
  });
}
