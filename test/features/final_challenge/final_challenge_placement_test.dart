import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/regions/screens/island_group_selection_screen.dart';

class _Journey extends RegionsNotifier {
  @override
  Future<List<Region>> build() async => [
    for (final region in defaultPhilippineRegions)
      region.copyWith(isUnlocked: true, starsEarned: region.id == 18 ? 0 : 1),
  ];

  void finishNir() {
    state = AsyncData([
      for (final region in state.requireValue) region.copyWith(starsEarned: 1),
    ]);
  }
}

void main() {
  testWidgets(
    'final card sits below Mindanao and only opens after all 18 regions are complete',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer(
        overrides: [regionsProvider.overrideWith(_Journey.new)],
      );
      addTearDown(container.dispose);
      String? destination;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const IslandGroupSelectionScreen(),
            onGenerateRoute: (settings) {
              destination = settings.name;
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Final challenge')),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final entry = find.byKey(const Key('final_challenge_entry'));
      await tester.scrollUntilVisible(entry, 180);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(entry).top,
        greaterThan(
          tester
              .getRect(find.byKey(const ValueKey('island_group_Mindanao')))
              .bottom,
        ),
      );
      expect(find.textContaining('17 / 18 regions'), findsOneWidget);
      expect(tester.widget<ListTile>(entry).onTap, isNull);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(destination, isNull);
      (container.read(regionsProvider.notifier) as _Journey).finishNir();
      await tester.pumpAndSettle();
      expect(tester.widget<ListTile>(entry).onTap, isNotNull);
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(destination, AppRouter.finalChallenge);
      expect(tester.takeException(), isNull);
    },
  );
}
