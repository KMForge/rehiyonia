import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/database/asset_seed_loader.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/trivia/data/repositories/trivia_repository.dart';
import 'package:rehiyonia/features/trivia/models/trivia_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  test('existing single-answer content upgrades without resetting coins or progress', () async {
    final database = AppDatabase(databaseFactory: databaseFactoryFfi);
    await database.initialize(inMemory: true);
    addTearDown(database.close);
    await RegionRepository(appDatabase: database)
        .insertRegions(defaultPhilippineRegions);
    final repo = TriviaRepository(appDatabase: database);
    await repo.insertTrivia([
      for (var id = 1; id <= 18; id++)
        TriviaItem(
          regionId: id,
          question: 'Old question',
          optionA: 'Answer',
          optionB: '',
          optionC: '',
          optionD: '',
          correctOption: 0,
          explanation: 'Fact',
        ),
    ]);
    await database.database.insert('user_progress', {
      'setting_key': 'player_coins',
      'setting_value': '210',
    });
    await database.database.insert('user_progress', {
      'setting_key': 'trivia_four_choices_v1',
      'setting_value': '1',
    });
    await database.database.update('regions', {
      'stars_earned': 3,
    }, where: 'id = 1');
    final loader = AssetSeedLoader(appDatabase: database);
    await loader.seedIfEmpty();
    await loader.seedIfEmpty();
    expect(await repo.countTrivia(), 54);
    for (var id = 1; id <= 18; id++) {
      final questions = await repo.getTriviaForRegion(id);
      expect(questions, hasLength(3));
      expect(questions.map((q) => q.question).toSet(), hasLength(3));
      for (final question in questions) {
        expect(
          [
            question.optionA,
            question.optionB,
            question.optionC,
            question.optionD,
          ].every((s) => s.isNotEmpty),
          isTrue,
        );
      }
      for (final question in questions.skip(1)) {
        expect(question.imagePath, 'assets/images/trivia/region_$id.jpg');
        expect(question.imageCaption, isNotEmpty);
        expect(question.imageCredit, isNotEmpty);
      }
    }
    final mirroredQuestions = await database.database.query('trivia_questions');
    expect(mirroredQuestions, hasLength(54));
    expect(
      mirroredQuestions.where((q) => q['image_path'] != null),
      hasLength(36),
    );
    final coins = await database.database.query(
      'user_progress',
      where: 'setting_key = ?',
      whereArgs: ['player_coins'],
    );
    expect(coins.single['setting_value'], '210');
    expect(
      (await database.database.query(
        'regions',
        where: 'id = 1',
      )).single['stars_earned'],
      3,
    );
  });
}
