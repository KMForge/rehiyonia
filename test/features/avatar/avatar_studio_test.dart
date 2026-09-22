import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/avatar/screens/avatar_studio_screen.dart';
import 'package:rehiyonia/features/avatar/widgets/player_avatar_widget.dart';

void main() {
  group('Avatar Studio & Player Avatar Tests', () {
    test('PlayerAvatar model copyWith and serialization work correctly', () {
      const avatar = PlayerAvatar();
      expect(avatar.skinIndex, 0);
      expect(avatar.hairStyleIndex, 0);

      final updated = avatar.copyWith(
        skinIndex: 2,
        hairStyleIndex: 3,
        outfitColorIndex: 1,
      );
      expect(updated.skinIndex, 2);
      expect(updated.hairStyleIndex, 3);
      expect(updated.outfitColorIndex, 1);

      final map = updated.toMap();
      final fromMap = PlayerAvatar.fromMap(map);
      expect(fromMap.skinIndex, 2);
      expect(fromMap.hairStyleIndex, 3);
      expect(fromMap.outfitColorIndex, 1);
    });

    testWidgets('PlayerAvatarWidget renders without error across sizes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAvatarWidget(
              avatar: PlayerAvatar(skinIndex: 1, hairStyleIndex: 2),
              size: 100,
            ),
          ),
        ),
      );

      expect(find.byType(PlayerAvatarWidget), findsOneWidget);
    });

    testWidgets('AvatarStudioScreen displays categories and save button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AvatarStudioScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.text('Avatar Studio'), findsOneWidget);
      expect(find.text('Skin Tone'), findsOneWidget);
      expect(find.text('Hair Style'), findsOneWidget);
      expect(find.byKey(const Key('button_save_avatar')), findsOneWidget);

      // Tap Hair Style category chip
      await tester.tap(find.text('Hair Style'));
      await tester.pumpAndSettle();

      expect(find.text('Short'), findsOneWidget);
      expect(find.text('Curly'), findsOneWidget);

      // Tap Save Avatar button
      await tester.tap(find.byKey(const Key('button_save_avatar')));
      await tester.pumpAndSettle();

      expect(find.text('Avatar updated successfully!'), findsOneWidget);
    });
  });
}
