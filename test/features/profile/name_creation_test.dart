import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';
import 'package:rehiyonia/features/profile/models/user_profile.dart';
import 'package:rehiyonia/features/profile/widgets/create_explorer_dialog.dart';

class _Names extends ProfileRepository {
  _Names() : super(AppDatabase());
  bool fail = true;
  String name = 'Bayanito';
  @override
  Future<void> completeNameCreation(String value) async {
    if (fail) throw StateError('Disk unavailable');
    name = value.trim();
  }

  @override
  Future<UserProfile> load() async => UserProfile(name: name);
}

void main() {
  setUpAll(sqfliteFfiInit);
  test(
    'first launch requires a name; completion and legacy names skip it',
    () async {
      final db = AppDatabase(databaseFactory: databaseFactoryFfi);
      await db.initialize(inMemory: true);
      addTearDown(db.close);
      final repo = ProfileRepository(db);
      expect(await repo.needsNameCreation(), isTrue);
      await repo.saveValue(AppConstants.keyPlayerName, 'Luna');
      expect(await repo.needsNameCreation(), isFalse);
      await repo.saveValue(
        AppConstants.keyPlayerName,
        AppConstants.defaultPlayerName,
      );
      expect(await repo.needsNameCreation(), isTrue);
      // Even deliberately choosing the default nickname counts as completion.
      await repo.completeNameCreation(AppConstants.defaultPlayerName);
      expect(await repo.needsNameCreation(), isFalse);
      expect((await repo.load()).name, AppConstants.defaultPlayerName);
    },
  );

  testWidgets('name validation, failed save and retry retain the dialog', (
    tester,
  ) async {
    final repo = _Names();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const CreateExplorerDialog(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_explorer_button')));
    await tester.pumpAndSettle();
    expect(find.text('Use 2–20 characters.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('first_launch_name')),
      '  Tala  ',
    );
    await tester.tap(find.byKey(const Key('create_explorer_button')));
    await tester.pumpAndSettle();
    expect(find.text('Could not save. Please try again.'), findsOneWidget);
    repo.fail = false;
    await tester.tap(find.byKey(const Key('create_explorer_button')));
    await tester.pumpAndSettle();
    expect(find.byType(CreateExplorerDialog), findsNothing);
    expect(repo.name, 'Tala');
  });
}
