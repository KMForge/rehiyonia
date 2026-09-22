import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/badges/screens/badge_gallery_screen.dart';
import 'package:rehiyonia/features/regions/models/region.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';

class _FakeRegionsNotifier extends RegionsNotifier {
  _FakeRegionsNotifier(this._regions);
  final List<Region> _regions;

  @override
  Future<List<Region>> build() async => _regions;
}

void main() {
  group('Badge Gallery Tests', () {
    testWidgets(
      'BadgeGalleryScreen displays earned count and regional badges',
      (WidgetTester tester) async {
        final mockRegions = [
          const Region(
            id: 1,
            code: 'NCR',
            name: 'National Capital Region',
            designation: 'NCR',
            islandGroup: 'Luzon',
            description: 'Metro Manila',
            isUnlocked: true,
            starsEarned: 3,
          ),
          const Region(
            id: 2,
            code: 'CAR',
            name: 'Cordillera Administrative Region',
            designation: 'CAR',
            islandGroup: 'Luzon',
            description: 'Cordillera',
            isUnlocked: false,
            starsEarned: 0,
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              regionsProvider.overrideWith(
                () => _FakeRegionsNotifier(mockRegions),
              ),
            ],
            child: const MaterialApp(home: BadgeGalleryScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Badge Gallery'), findsOneWidget);
        expect(find.text('Badges Earned: 1 / 2'), findsOneWidget);
        expect(find.text('NCR'), findsNWidgets(2));
        expect(find.text('CAR'), findsNWidgets(2));
        expect(find.text('Locked'), findsOneWidget);
      },
    );
  });
}
