import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final appDb = AppDatabase();
  ref.onDispose(() {
    appDb.close();
  });
  return appDb;
});

class AppInitializationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    await _initialize();
  }

  Future<void> _initialize() async {
    final db = ref.read(appDatabaseProvider);
    await db.initialize();
  }

  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _initialize());
  }
}

final appInitializationProvider =
    AsyncNotifierProvider<AppInitializationNotifier, void>(
      AppInitializationNotifier.new,
    );
