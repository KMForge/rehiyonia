import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/asset_seed_loader.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:rehiyonia/shared/models/locality_photo_credit.dart';
import 'package:rehiyonia/shared/widgets/locality_photo.dart';
import 'package:rehiyonia/shared/widgets/word_discovery_content.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  final creditsSource = File('assets/data/locality_photo_credits.json')
      .readAsStringSync();
  final credits = parseLocalityPhotoCredits(creditsSource);
  final words = (jsonDecode(
    File('assets/data/regional_words.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();

  test(
    '50 reviewed offline photographs decode; all 270 localities have assets',
    () async {
      expect(credits, hasLength(50));
      final manifest = (jsonDecode(creditsSource) as List)
          .cast<Map<String, dynamic>>();
      expect(manifest.map((p) => p['asset_sha256']).toSet(), hasLength(50));
      for (final photo in manifest) {
        final file = File(photo['asset_path'] as String);
        final bytes = file.readAsBytesSync();
        expect(bytes.take(2), [0xff, 0xd8]);
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        expect(frame.image.width, photo['width']);
        expect(frame.image.height, photo['height']);
        expect(frame.image.width, lessThanOrEqualTo(960));
        expect(frame.image.height, lessThanOrEqualTo(960));
        expect(
          photo['license'],
          matches(RegExp(r'^(CC BY|CC0|Public domain)')),
        );
        expect((photo['author'] as String).trim(), isNotEmpty);
        expect(photo['modifications'], isNotEmpty);
        frame.image.dispose();
        codec.dispose();
      }
      final missing = words.where(
        (w) => !File(w['image_path'] as String).existsSync(),
      );
      expect(words, hasLength(270));
      expect(missing, isEmpty);
      for (final key in [
        '13:DONCARLOS',
        '14:MONKAYO',
        '14:SANTAMARIA',
        '16:LINGIG',
      ]) {
        final photo = credits[key]!;
        expect(photo.captionEn, isNotEmpty);
        expect(photo.captionFil, isNotEmpty);
        expect(photo.licenseUrl, startsWith('https://'));
        expect(
          words.singleWhere(
            (w) => '${w['region_id']}:${w['word']}' == key,
          )['image_path'],
          photo.assetPath,
        );
      }
      expect(
        credits['3:SANFERNANDO']!.assetPath,
        isNot(credits['5:SANFERNANDO']!.assetPath),
      );
      expect(
        credits['3:SANCARLOS']!.assetPath,
        isNot(credits['18:SANCARLOS']!.assetPath),
      );
    },
  );

  test('content upgrade keeps saved identity, rewards, progress and locality IDs after reopening', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rehiyonia_photo_upgrade_',
    );
    final path = '${directory.path}/saved_game.db';
    final app = AppDatabase(databaseFactory: databaseFactoryFfi);
    addTearDown(() async {
      await app.close();
      await directory.delete(recursive: true);
    });
    await app.initialize(databasePath: path);
    await RegionRepository(appDatabase: app)
        .insertRegions(defaultPhilippineRegions);
    await AssetSeedLoader(appDatabase: app).seedIfEmpty();
    final profile = ProfileRepository(app);
    await profile.saveName('Maya');
    await profile.saveAvatar(
      const PlayerAvatar(
        baseId: 'female',
        topId: 'explorer',
        headwearId: 'cap',
      ),
    );
    await profile.saveValue(AppConstants.keyCoins, '375');
    await profile.saveValue('region_1_found_words', '["MANILA","LASPINAS"]');
    await app.database.update('regions', {
      'is_unlocked': 1,
      'stars_earned': 3,
    }, where: 'id IN (1,18)');
    for (final photo in credits.values) {
      await app.database.update(
        'localities',
        {
          'image_path':
              'assets/images/localities/${photo.word.toLowerCase()}.jpg',
        },
        where: 'region_id = ? AND word = ?',
        whereArgs: [photo.regionId, photo.word],
      );
    }
    await app.database.update('localities', {
      'province_en': 'La Union',
    }, where: "region_id = 5 AND word = 'SANFERNANDO'");
    await app.database.update('localities', {
      'province_en': 'Pangasinan',
    }, where: "region_id = 18 AND word = 'SANCARLOS'");
    final beforeIds = (await app.database.query(
      'localities',
      columns: ['id', 'region_id', 'word'],
      orderBy: 'id',
    ));
    final beforeProfile = await app.database.query('player_profile');
    final beforeProgress = await app.database.query(
      'user_progress',
      orderBy: 'setting_key',
    );
    final beforeRegions = await app.database.query('regions', orderBy: 'id');
    await app.close();
    await app.initialize(databasePath: path);
    await AssetSeedLoader(appDatabase: app).seedIfEmpty();
    await AssetSeedLoader(appDatabase: app).seedIfEmpty();
    expect(
      await app.database.query(
        'localities',
        columns: ['id', 'region_id', 'word'],
        orderBy: 'id',
      ),
      beforeIds,
    );
    expect(await app.database.query('player_profile'), beforeProfile);
    expect(
      await app.database.query('user_progress', orderBy: 'setting_key'),
      beforeProgress,
    );
    expect(await app.database.query('regions', orderBy: 'id'), beforeRegions);
    for (final photo in credits.values) {
      final saved = (await app.database.query(
        'localities',
        where: 'region_id = ? AND word = ?',
        whereArgs: [photo.regionId, photo.word],
      )).single;
      expect(saved['image_path'], photo.assetPath);
    }
    final saved = await app.database.query('localities');
    expect(saved, hasLength(270));
    expect(
      saved.singleWhere(
        (w) => w['region_id'] == 5 && w['word'] == 'SANFERNANDO',
      )['province_en'],
      'Pampanga',
    );
    expect(
      saved.singleWhere(
        (w) => w['region_id'] == 18 && w['word'] == 'SANCARLOS',
      )['province_en'],
      'Negros Occidental',
    );
  });

  testWidgets(
    'old saved image paths resolve to new local photos with accessible credits',
    (tester) async {
      final oldWord = RegionalWord.fromMap({
        ...words.singleWhere(
          (w) => w['region_id'] == 1 && w['word'] == 'LASPINAS',
        ),
        'image_path': 'assets/images/localities/laspinas.jpg',
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localityPhotoCreditsProvider.overrideWith((ref) async => credits),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 160,
                  child: LocalityPhoto(locality: oldWord),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<Image>(find.byType(Image))
            .map((w) => (w.image as AssetImage).assetName),
        contains(credits['1:LASPINAS']!.assetPath),
      );
      await tester.tap(find.byTooltip('Photo credits'));
      await tester.pumpAndSettle();
      expect(find.text(credits['1:LASPINAS']!.title), findsOneWidget);
      expect(find.text(credits['1:LASPINAS']!.sourceUrl), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'word-found popup uses region-specific new photo and its source credit',
    (tester) async {
      final word = RegionalWord.fromMap(
        words.singleWhere(
          (w) => w['region_id'] == 5 && w['word'] == 'SANFERNANDO',
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localityPhotoCreditsProvider.overrideWith((ref) async => credits),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: WordDiscoveryContent(word: word, english: true),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(
        find.byKey(const ValueKey('final_discovery_photo_5')),
      );
      expect(
        (image.image as ResizeImage).imageProvider,
        isA<AssetImage>().having(
          (p) => p.assetName,
          'path',
          credits['5:SANFERNANDO']!.assetPath,
        ),
      );
      await tester.tap(find.text('Photo credits'));
      await tester.pumpAndSettle();
      expect(find.text(credits['5:SANFERNANDO']!.sourceUrl), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
