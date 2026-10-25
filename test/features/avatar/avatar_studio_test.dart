import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/avatar/providers/avatar_editor_provider.dart';
import 'package:rehiyonia/features/avatar/screens/avatar_studio_screen.dart';
import 'package:rehiyonia/features/avatar/widgets/player_avatar_widget.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';

import '../../support/explorer_fakes.dart';

void main() {
  test('new wardrobe IDs survive serialization for either base', () {
    for (final base in ['male', 'female']) {
      for (final top in ['hoodie', 'explorer']) {
        final avatar = PlayerAvatar(
          baseId: base,
          topId: top,
          bottomId: 'cargo',
          shoesId: 'boots',
          headwearId: 'bucket',
          glassesId: 'sunglasses',
        );
        expect(PlayerAvatar.fromMap(avatar.toMap()), avatar);
      }
    }
  });
  test('legacy fields and independent slots round-trip', () {
    final old = PlayerAvatar.fromMap({
      'avatar_skin': 2,
      'avatar_hair': 3,
      'avatar_outfit': 1,
      'avatar_accessory': 3,
    });
    final updated = old.copyWith(
      baseId: 'female',
      headwearId: 'cap',
      necklaceId: 'chain',
      bottomId: 'shorts',
    );
    final loaded = PlayerAvatar.fromMap(updated.toMap());
    expect(loaded, updated);
    expect(loaded.glassesId, 'round');
    expect(loaded.headwearId, 'cap');
    expect(loaded.bottomId, 'shorts');
    expect(loaded.skinIndex, 2);
    expect(loaded.copyWith(shoesId: 'sandals'), isNot(loaded));
  });

  test('draft edits stay isolated and failed save remains retryable', () async {
    final repo = MemoryProfileRepository();
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(avatarEditorProvider, (_, _) {});
    addTearDown(subscription.close);
    final editor = container.read(avatarEditorProvider.notifier);
    editor.change(const PlayerAvatar(baseId: 'female', necklaceId: 'pendant'));
    expect(container.read(profileProvider).avatar.baseId, 'male');
    repo.failSave = true;
    expect(await editor.save(), isFalse);
    expect(container.read(avatarEditorProvider).isDirty, isTrue);
    expect(container.read(avatarEditorProvider).failed, isTrue);
    repo.failSave = false;
    expect(await editor.save(), isTrue);
    expect(container.read(profileProvider).avatar.baseId, 'female');
    expect(container.read(avatarEditorProvider).isDirty, isFalse);
    editor.change(const PlayerAvatar());
    editor.reset();
    expect(container.read(avatarEditorProvider).draft, repo.avatar);
  });

  testWidgets('studio previews both bases and saves through repository', (
    tester,
  ) async {
    final repo = MemoryProfileRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: AvatarStudioScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Avatar Studio'), findsOneWidget);
    expect(find.byType(PlayerAvatarWidget), findsWidgets);
    await tester.tap(find.text('Female'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('button_save_avatar')));
    await tester.pumpAndSettle();
    expect(repo.avatar.baseId, 'female');
    expect(find.text('Avatar updated successfully!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small studio with enlarged text has no layout exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: AvatarStudioScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
