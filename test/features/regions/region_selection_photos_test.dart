import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/features/badges/region_landmark.dart';
import 'package:rehiyonia/features/badges/widgets/regional_badge_stamp.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/regions/screens/region_selection_screen.dart';

class _SavedRegions extends RegionsNotifier {
  @override
  Future<List<Region>> build() async => [
    for (final region in defaultPhilippineRegions)
      region.copyWith(isUnlocked: region.id == 1, starsEarned: 0),
  ];
}

void main() {
  final photos = parseRegionLandmarks(
    File('assets/data/region_landmarks.json').readAsStringSync(),
  );

  for (final width in [320.0, 390.0]) {
    testWidgets('all 18 region cards reuse passport photos at ${width}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Object? openedRegion;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            regionsProvider.overrideWith(_SavedRegions.new),
            regionLandmarksProvider.overrideWith((ref) async => photos),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(width == 320 ? 1.5 : 1)),
              child: child!,
            ),
            onGenerateRoute: (settings) {
              expect(settings.name, AppRouter.regionIntro);
              openedRegion = settings.arguments;
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Region intro')),
              );
            },
            home: const RegionSelectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('region_card_1')));
      await tester.pumpAndSettle();
      expect(openedRegion, 1);
      Navigator.of(tester.element(find.text('Region intro'))).pop();
      await tester.pumpAndSettle();
      openedRegion = null;

      for (final region in defaultPhilippineRegions) {
        final card = find.byKey(ValueKey('region_card_${region.id}'));
        await tester.scrollUntilVisible(
          card,
          250,
          scrollable: find.byType(Scrollable).last,
        );
        final photo = tester.widget<LandmarkPhoto>(
          find.descendant(of: card, matching: find.byType(LandmarkPhoto)),
        );
        expect(photo.landmark.assetPath, photos[region.id]!.assetPath);
        expect(photo.earned, region.id == 1);
        expect(tester.takeException(), isNull);
      }

      final visayasFilter = find.widgetWithText(ChoiceChip, 'Visayas');
      await tester.ensureVisible(visayasFilter);
      await tester.tap(visayasFilter);
      await tester.pumpAndSettle();
      final nir = find.byKey(const ValueKey('region_card_18'));
      await tester.ensureVisible(nir);
      await tester.tap(nir);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(openedRegion, isNull);
      expect(find.byKey(const ValueKey('region_card_1')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
