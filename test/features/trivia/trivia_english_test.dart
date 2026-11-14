import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/asset_seed_loader.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/settings/models/app_language.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/trivia/data/repositories/trivia_repository.dart';
import 'package:rehiyonia/features/trivia/models/trivia_item.dart';
import 'package:rehiyonia/features/trivia/providers/trivia_provider.dart';
import 'package:rehiyonia/features/trivia/screens/pre_game_trivia_screen.dart';

List<Map<String, dynamic>> readRows(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  final translations = readRows('assets/data/trivia_en.json');
  final culture = readRows('assets/data/regional_culture.json');

  test('all 54 trivia questions and 18 photo captions have complete English content', () {
    expect(translations.map((r) => r['region_id']).toSet(), {
      for (var id = 1; id <= 18; id++) id,
    });
    expect(translations, hasLength(18));
    var total = 0;
    for (final region in translations) {
      expect(region['image_caption'], isNotEmpty);
      expect(region['culture'], hasLength(2));
      final questions = [region['base'], ...region['culture'] as List];
      for (final question in questions.cast<Map<String, dynamic>>()) {
        expect(question['question'], isNotEmpty);
        expect(question['explanation'], isNotEmpty);
        final options = (question['options'] as List).cast<String>();
        expect(options, hasLength(4));
        expect(options.toSet(), hasLength(4));
        expect(options.every((o) => o.trim().isNotEmpty), isTrue);
        total++;
      }
    }
    expect(total, 54);
  });

  test('installed Filipino-only trivia gains English without changing IDs, answers, avatar, coins, or progress', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rehiyonia_trivia_english_',
    );
    final path = '${directory.path}/saved.db';
    var database = AppDatabase(databaseFactory: databaseFactoryFfi);
    try {
      await database.initialize(databasePath: path);
      await RegionRepository(appDatabase: database)
          .insertRegions(defaultPhilippineRegions);
      final profile = ProfileRepository(database);
      await profile.saveName('Maya');
      await profile.saveAvatar(
        const PlayerAvatar(
          baseId: 'female',
          topId: 'explorer',
          headwearId: 'flower',
        ),
      );
      await database.database.insert('user_progress', {
        'setting_key': 'player_coins',
        'setting_value': '210',
      });
      await database.database.update('regions', {
        'is_unlocked': 1,
        'stars_earned': 2,
      }, where: 'id = 18');
      var loader = AssetSeedLoader(appDatabase: database);
      await loader.seedIfEmpty();
      final db = database.database;
      expect(await TriviaRepository(appDatabase: database).countTrivia(), 54);
      // Recreate an already-installed culture-v2 dataset with Filipino text in
      // its English columns, while retaining the existing culture-version flag.
      await db.execute('''UPDATE trivia_questions SET
        question_en = question_fil, option_a_en = option_a_fil,
        option_b_en = option_b_fil, option_c_en = option_c_fil,
        option_d_en = option_d_fil, explanation_en = explanation_fil,
        image_caption = (SELECT image_caption FROM trivia
          WHERE trivia.region_id = trivia_questions.region_id
          AND trivia.question = trivia_questions.question_fil LIMIT 1)''');
      await db.delete(
        'user_progress',
        where: 'setting_key = ?',
        whereArgs: ['trivia_english_content_v1'],
      );
      final legacyBefore = await db.query('trivia', orderBy: 'id');
      final regionsBefore = await db.query('regions', orderBy: 'id');
      final profileBefore = await db.query('player_profile', orderBy: 'id');
      final progressBefore = await db.query(
        'user_progress',
        orderBy: 'setting_key',
      );
      const stableColumns = [
        'id',
        'region_id',
        'question_fil',
        'option_a_fil',
        'option_b_fil',
        'option_c_fil',
        'option_d_fil',
        'correct_option',
        'explanation_fil',
        'image_path',
        'image_credit',
      ];
      final bilingualBefore = await db.query(
        'trivia_questions',
        columns: stableColumns,
        orderBy: 'id',
      );
      await loader.seedIfEmpty();
      await loader.seedIfEmpty();
      expect(await db.query('trivia', orderBy: 'id'), legacyBefore);
      expect(await db.query('regions', orderBy: 'id'), regionsBefore);
      expect(await db.query('player_profile', orderBy: 'id'), profileBefore);
      expect(
        await db.query(
          'user_progress',
          where: 'setting_key != ?',
          whereArgs: ['trivia_english_content_v1'],
          orderBy: 'setting_key',
        ),
        progressBefore,
      );
      expect(
        await db.query(
          'trivia_questions',
          columns: stableColumns,
          orderBy: 'id',
        ),
        bilingualBefore,
      );
      final repository = TriviaRepository(appDatabase: database);
      for (final region in translations) {
        final id = region['region_id'] as int;
        final expected = [
          region['base'],
          ...region['culture'] as List,
        ].cast<Map<String, dynamic>>();
        final loaded = await repository.getTriviaForRegion(id);
        expect(loaded, hasLength(3));
        for (var i = 0; i < loaded.length; i++) {
          final item = loaded[i];
          expect(item.getQuestion(true), expected[i]['question']);
          expect(item.getExplanation(true), expected[i]['explanation']);
          expect([
            item.getOptionA(true),
            item.getOptionB(true),
            item.getOptionC(true),
            item.getOptionD(true),
          ], expected[i]['options']);
          expect(
            item.getAnswer(true),
            (expected[i]['options'] as List)[item.correctOption],
          );
          expect(
            item.getQuestion(false),
            legacyBefore.singleWhere((r) => r['id'] == item.id)['question'],
          );
          if (i > 0) {
            expect(item.getImageCaption(true), region['image_caption']);
            expect(
              item.getImageCaption(false),
              culture.singleWhere((r) => r['region_id'] == id)['image_caption'],
            );
          }
        }
      }
      await database.close();
      database = AppDatabase(databaseFactory: databaseFactoryFfi);
      await database.initialize(databasePath: path);
      final reopened = await TriviaRepository(appDatabase: database)
          .getTriviaForRegion(1);
      expect(
        reopened[1].getImageCaption(true),
        translations.first['image_caption'],
      );
      expect(
        reopened[1].getExplanation(true),
        (translations.first['culture'] as List).first['explanation'],
      );
    } finally {
      await database.close();
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        final file = File('$path$suffix');
        if (await file.exists()) await file.delete();
      }
      await directory.delete();
    }
  });

  testWidgets(
    'English trivia and small photo caption switch reactively to Filipino',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final filipino =
          (culture.first['questions'] as List).first as Map<String, dynamic>;
      final english =
          (translations.first['culture'] as List).first as Map<String, dynamic>;
      final optionsFil = (filipino['options'] as List).cast<String>();
      final optionsEn = (english['options'] as List).cast<String>();
      final item = TriviaItem(
        regionId: 1,
        question: filipino['question'],
        optionA: optionsFil[0],
        optionB: optionsFil[1],
        optionC: optionsFil[2],
        optionD: optionsFil[3],
        correctOption: filipino['correct_option'],
        explanation: filipino['explanation'],
        questionEn: english['question'],
        optionAEn: optionsEn[0],
        optionBEn: optionsEn[1],
        optionCEn: optionsEn[2],
        optionDEn: optionsEn[3],
        explanationEn: english['explanation'],
        imagePath: culture.first['image_path'],
        imageCaption: culture.first['image_caption'],
        imageCaptionEn: translations.first['image_caption'],
        imageCredit: culture.first['image_credit'],
      );
      final session = ProviderContainer(
        overrides: [
          triviaForRegionProvider(1).overrideWith((_) async => [item]),
        ],
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: session,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const PreGameTriviaScreen(regionId: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(english['question']), findsOneWidget);
      final wrong = find.byKey(const Key('trivia_option_1'));
      await tester.ensureVisible(wrong);
      await tester.tap(wrong);
      await tester.pumpAndSettle();
      expect(find.text(english['explanation']), findsOneWidget);
      expect(find.text(translations.first['image_caption']), findsOneWidget);
      expect(find.text(filipino['explanation']), findsNothing);
      final imageFinder = find.byKey(const Key('trivia_culture_image'));
      final image = tester.widget<Image>(imageFinder);
      await tester.runAsync(() async {
        await precacheImage(image.image, tester.element(imageFinder));
        await rootBundle.loadString('assets/data/culture_image_credits.json');
      });
      await tester.pumpAndSettle();
      final imageSize = tester.getSize(imageFinder);
      final frameSize = tester.getSize(
        find.byKey(const Key('trivia_photo_frame')),
      );
      final textBounds = tester.getRect(
        find.byKey(const Key('trivia_explanation_text')),
      );
      final photoBounds = tester.getRect(
        find.byKey(const Key('trivia_photo_frame')),
      );
      expect(textBounds.right, lessThan(photoBounds.left));
      expect(textBounds.top, closeTo(photoBounds.top, .1));
      expect(imageSize.height, greaterThan(0));
      expect(imageSize.height, lessThanOrEqualTo(100));
      expect(frameSize.width, closeTo(imageSize.width + 12, .1));
      expect(frameSize.height, closeTo(imageSize.height + 12, .1));
      expect(
        tester.getSize(find.byKey(const Key('trivia_explanation_card'))).width,
        lessThanOrEqualTo(440),
      );
      expect(find.text(item.imageCredit!), findsNothing);
      await tester.tap(find.byKey(const Key('trivia_photo_credits')));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {});
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(item.imageCredit!), findsOneWidget);
      final credit = readRows('assets/data/culture_image_credits.json').first;
      expect(find.text(credit['source_url']), findsOneWidget);
      expect(find.text(credit['license_url']), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
      session.read(settingsProvider.notifier).setLanguage(AppLanguage.tagalog);
      await tester.pumpAndSettle();
      expect(find.text(filipino['question']), findsOneWidget);
      expect(find.text(filipino['explanation']), findsOneWidget);
      expect(find.text(culture.first['image_caption']), findsOneWidget);
      expect(find.text(english['explanation']), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
