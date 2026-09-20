import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/shared/providers/app_initialization_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('AppInitializationProvider Tests', () {
    test('initializes database and transitions to AsyncData', () async {
      final testDb = AppDatabase(databaseFactory: databaseFactoryFfi);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(testDb)],
      );
      addTearDown(() async {
        container.dispose();
        await testDb.close();
      });

      // Initially loading
      expect(
        container.read(appInitializationProvider),
        isA<AsyncLoading<void>>(),
      );

      // Wait for initialization
      await container.read(appInitializationProvider.future);

      expect(container.read(appInitializationProvider), isA<AsyncData<void>>());
      expect(testDb.isOpen, isTrue);
    });
  });
}
