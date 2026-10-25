import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/shared/providers/app_initialization_provider.dart';

/// Real startup and SQLite, without reading or changing the player's save.
Future<void> launchTestApp(WidgetTester tester) async {
  final database = AppDatabase();
  await database.initialize(inMemory: true);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const RehiyoniaApp(),
    ),
  );
  await tester.pumpAndSettle();
  // A fresh installation now creates its explorer identity before Home.
  expect(find.byKey(const Key('first_launch_name')), findsOneWidget);
  await tester.enterText(
    find.byKey(const Key('first_launch_name')),
    'Test Explorer',
  );
  await tester.tap(find.byKey(const Key('create_explorer_button')));
  await tester.pumpAndSettle();
}
