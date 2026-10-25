import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/avatar/widgets/avatar_stage.dart';
import 'package:rehiyonia/features/avatar/widgets/player_avatar_widget.dart';

void main() {
  testWidgets('both explorer bases and independent layered accessories', (
    tester,
  ) async {
    const avatars = [
      PlayerAvatar(
        topId: 'explorer',
        bottomId: 'cargo',
        shoesId: 'boots',
        headwearId: 'bucket',
        glassesId: 'sunglasses',
        necklaceId: 'chain',
      ),
      PlayerAvatar(
        baseId: 'female',
        hairStyleIndex: 5,
        topId: 'hoodie',
        outfitColorIndex: 1,
        bottomId: 'shorts',
        shoesId: 'boots',
        headwearId: 'flower',
        glassesId: 'round',
        necklaceId: 'pendant',
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: const Key('wardrobe_preview'),
              child: SizedBox(
                width: 540,
                child: Row(
                  children: [
                    for (final avatar in avatars)
                      Expanded(
                        child: AvatarStage(
                          height: 350,
                          child: PlayerAvatarWidget(
                            avatar: avatar,
                            size: 215,
                            fullBody: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('wardrobe_preview')),
      matchesGoldenFile('goldens/explorer_wardrobe.png'),
    );
  });
}
