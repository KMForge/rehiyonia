import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/word_search/data/repositories/word_repository.dart';
import 'package:rehiyonia/features/word_search/models/regional_word.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('WordRepository Tests', () {
    late AppDatabase appDatabase;
    late RegionRepository regionRepository;
    late WordRepository wordRepository;

    setUp(() async {
      appDatabase = AppDatabase(databaseFactory: databaseFactoryFfi);
      await appDatabase.initialize(inMemory: true);
      regionRepository = RegionRepository(appDatabase: appDatabase);
      wordRepository = WordRepository(appDatabase: appDatabase);

      // Insert parent region first (for foreign key constraint)
      await regionRepository.insertRegions([
        const Region(
          id: 1,
          code: 'NCR',
          name: 'National Capital Region',
          designation: 'NCR',
          islandGroup: 'Luzon',
          description: 'Capital region',
        ),
      ]);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('inserts and queries words for a specific region', () async {
      final initial = await wordRepository.getWordsForRegion(1);
      expect(initial, isEmpty);

      const words = [
        RegionalWord(
          regionId: 1,
          word: 'MANILA',
          category: 'Lungsod',
          clue: 'Kabisera ng Pilipinas',
        ),
        RegionalWord(
          regionId: 1,
          word: 'PASIG',
          category: 'Lungsod',
          clue: 'Ilog at Lungsod',
        ),
      ];

      await wordRepository.insertWords(words);

      final retrieved = await wordRepository.getWordsForRegion(1);
      expect(retrieved.length, 2);
      expect(retrieved.first.word, 'MANILA');
      expect(retrieved.last.word, 'PASIG');

      final count = await wordRepository.countWords();
      expect(count, 2);
    });
  });
}
