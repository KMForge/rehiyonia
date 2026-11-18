import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/app/app_theme.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';
import 'package:rehiyonia/features/regions/data/repositories/region_repository.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/shared/providers/app_initialization_provider.dart';

/// Runs the actual final puzzle with disposable sample progress. The player's
/// real database is never opened, and the normal 18-region gate stays intact.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final previewDatabase = AppDatabase();
  await previewDatabase.initialize(inMemory: true);
  await RegionRepository(appDatabase: previewDatabase).insertRegions([
    for (final region in defaultPhilippineRegions)
      region.copyWith(isUnlocked: true, starsEarned: 3),
  ]);
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(previewDatabase)],
  );
  await container.read(profileProvider.notifier).loadProfile();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        title: 'Rehiyonia — Final Mixed Puzzle Preview',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (_, child) => Banner(
          message: 'PREVIEW',
          location: BannerLocation.topStart,
          color: const Color(0xFFA67C96),
          child: child!,
        ),
        initialRoute: AppRouter.finalGame,
        onGenerateInitialRoutes: (_) => [
          AppRouter.onGenerateRoute(
            const RouteSettings(name: AppRouter.finalChallenge),
          )!,
          AppRouter.onGenerateRoute(
            const RouteSettings(name: AppRouter.finalGame),
          )!,
        ],
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ),
  );
}
