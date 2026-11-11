import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/avatar/data/avatar_catalog.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/avatar/widgets/wardrobe_purchase_dialog.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/profile/models/user_profile.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';

import '../../support/explorer_fakes.dart';

class ShopRepository extends MemoryProfileRepository {
  int balance = 200;
  int calls = 0;
  final pending = Completer<WardrobePurchase>();
  @override
  Future<UserProfile> load() async => UserProfile(coins: balance);
  @override
  Future<WardrobePurchase> buyWardrobeItem(
    String slot,
    String id,
    String base,
  ) {
    calls++;
    return pending.future;
  }
}

void main() {
  Future<ProviderContainer> open(
    WidgetTester tester,
    ShopRepository repo,
  ) async {
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(profileProvider.notifier).loadProfile();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => WardrobePurchaseDialog(
                      item: AvatarCatalog.item('headwear', 'beret'),
                      preview: const PlayerAvatar(headwearId: 'beret'),
                    ),
                  ),
                  child: const Text('Preview'),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'preview and cancel spend nothing; insufficient balance disables buy',
    (tester) async {
      final repo = ShopRepository()..balance = 50;
      final container = await open(tester, repo);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('buy_wardrobe_item')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('cancel_wardrobe_purchase')));
      await tester.pumpAndSettle();
      expect(repo.calls, 0);
      expect(container.read(profileProvider).coins, 50);
      expect(container.read(profileProvider).avatar.headwearId, 'none');
    },
  );

  testWidgets(
    'pending purchase blocks repeated taps and publishes ownership on success',
    (tester) async {
      final repo = ShopRepository();
      final container = await open(tester, repo);
      final buy = find.byKey(const Key('buy_wardrobe_item'));
      await tester.tap(buy);
      await tester.tap(buy);
      await tester.pump();
      expect(repo.calls, 1);
      expect(tester.widget<FilledButton>(buy).onPressed, isNull);
      repo.pending.complete(WardrobePurchase(140, {'headwear/beret'}));
      await tester.pumpAndSettle();
      expect(find.byType(WardrobePurchaseDialog), findsNothing);
      expect(container.read(profileProvider).coins, 140);
      expect(container.read(profileProvider).ownedWardrobeItems, {
        'headwear/beret',
      });
    },
  );

  testWidgets('failed purchase preserves balance and allows cancel or retry', (
    tester,
  ) async {
    final repo = ShopRepository();
    final container = await open(tester, repo);
    await tester.tap(find.byKey(const Key('buy_wardrobe_item')));
    repo.pending.completeError(StateError('disk unavailable'));
    await tester.pumpAndSettle();
    expect(find.byType(WardrobePurchaseDialog), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('buy_wardrobe_item')))
          .onPressed,
      isNotNull,
    );
    expect(container.read(profileProvider).coins, 200);
    expect(container.read(profileProvider).ownedWardrobeItems, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
