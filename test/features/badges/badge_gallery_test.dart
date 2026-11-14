import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/badges/regional_badges.dart';
import 'package:rehiyonia/features/badges/region_landmark.dart';
import 'package:rehiyonia/features/badges/screens/badge_gallery_screen.dart';
import 'package:rehiyonia/features/badges/widgets/regional_badge_stamp.dart';
import 'package:rehiyonia/features/badges/widgets/travel_badge_card.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';

class _FakeRegions extends RegionsNotifier {
  _FakeRegions(this.records);
  final List<Region> records;
  @override
  Future<List<Region>> build() async => records;
  void setSavedRegion(Region region) => state = AsyncData([
    for (final saved in state.requireValue)
      saved.id == region.id ? region : saved,
  ]);
}

void main() {
  final photos = parseRegionLandmarks(
    File('assets/data/region_landmarks.json').readAsStringSync(),
  );
  test(
    'exactly 18 existing IDs, including NIR, with no duplicate or extra badge',
    () {
      final nir = defaultPhilippineRegions.singleWhere(
        (region) => region.code == 'NIR',
      );
      final badges = regionalBadgeRegions([
        ...defaultPhilippineRegions,
        nir,
        nir,
        const Region(
          id: 19,
          code: 'EXTRA',
          name: 'Extra',
          designation: 'Extra',
          islandGroup: 'Visayas',
          description: '',
        ),
      ]);
      expect(regionalBadgeTotal, 18);
      expect(badges.length, 18);
      expect(
        badges.map((region) => region.id),
        List.generate(18, (index) => index + 1),
      );
      expect(badges.singleWhere((region) => region.code == 'NIR'), same(nir));
      expect(nir.id, 18);
      expect(
        badges
            .map((region) => regionalBadgeTitle(region, english: true))
            .toSet()
            .length,
        18,
      );
      expect(
        regionalBadgeTitle(nir, english: true),
        'Negros Island Region (NIR)',
      );
      expect(regionalBadgeTitle(nir, english: false), nir.name);
    },
  );

  testWidgets(
    '18 stamps and NIR only earned after unlocking and completing its region',
    (tester) async {
      tester.view.physicalSize = const Size(600, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final records = [
        for (final region in defaultPhilippineRegions)
          region.copyWith(
            isUnlocked: region.id == 1 || region.id == 18,
            starsEarned: region.id == 1 ? 3 : 0,
          ),
      ];
      final container = ProviderContainer(
        overrides: [
          regionsProvider.overrideWith(() => _FakeRegions(records)),
          regionLandmarksProvider.overrideWith((ref) async => photos),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BadgeGalleryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RegionalBadgeStamp), findsNWidgets(18));
      expect(find.byType(TravelBadgeCard), findsNWidgets(18));
      expect(find.byKey(const Key('travel_passport_gallery')), findsOneWidget);
      final firstCard = tester.getRect(
        find.byKey(const ValueKey('regional_badge_1')),
      );
      final secondCard = tester.getRect(
        find.byKey(const ValueKey('regional_badge_2')),
      );
      expect(firstCard.top, closeTo(secondCard.top, .01));
      expect(firstCard.right, lessThan(secondCard.left));
      expect(find.text('Badges Earned: 1 / 18'), findsOneWidget);
      expect(find.text('Negros Island Region (NIR)'), findsOneWidget);
      RegionalBadgeStamp nirStamp() =>
          tester.widget(find.byKey(const ValueKey('regional_stamp_18')));
      expect(nirStamp().regionCode, 'NIR');
      expect(nirStamp().earned, isFalse);
      final notifier = container.read(regionsProvider.notifier) as _FakeRegions;
      final nir = records.singleWhere((region) => region.id == 18);
      notifier.setSavedRegion(nir.copyWith(isUnlocked: false, starsEarned: 2));
      await tester.pumpAndSettle();
      expect(nirStamp().earned, isFalse);
      expect(find.text('Badges Earned: 1 / 18'), findsOneWidget);
      notifier.setSavedRegion(nir.copyWith(isUnlocked: true, starsEarned: 2));
      await tester.pumpAndSettle();
      expect(nirStamp().earned, isTrue);
      expect(find.text('Badges Earned: 2 / 18'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        closeTo(2 / 18, .0001),
      );
      expect(find.byType(RegionalBadgeStamp), findsNWidgets(18));
      await tester.tap(find.byKey(const ValueKey('regional_badge_18')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('regional_badge_details')), findsOneWidget);
      expect(find.text('Badge Earned!'), findsWidgets);
      expect(find.textContaining(photos[18]!.author), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
      expect(find.text('Badges Earned: 2 / 18'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all badges complete at 18 of 18', (tester) async {
    final records = [
      for (final region in defaultPhilippineRegions)
        region.copyWith(isUnlocked: true, starsEarned: 1),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          regionsProvider.overrideWith(() => _FakeRegions(records)),
          regionLandmarksProvider.overrideWith((ref) async => photos),
        ],
        child: const MaterialApp(home: BadgeGalleryScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Badges Earned: 18 / 18'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1,
    );
  });

  testWidgets('NIR remains reachable on a small phone with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final records = [
      for (final region in defaultPhilippineRegions)
        region.copyWith(
          isUnlocked: region.id == 18,
          starsEarned: region.id == 18 ? 3 : 0,
        ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          regionsProvider.overrideWith(() => _FakeRegions(records)),
          regionLandmarksProvider.overrideWith((ref) async => photos),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const BadgeGalleryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('regional_badge_18')),
      350,
    );
    expect(find.text('Negros Island Region (NIR)'), findsOneWidget);
    expect(
      tester
          .widget<RegionalBadgeStamp>(
            find.byKey(const ValueKey('regional_stamp_18')),
          )
          .earned,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
