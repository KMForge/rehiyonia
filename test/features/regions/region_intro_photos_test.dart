import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/avatar/widgets/player_avatar_widget.dart';
import 'package:rehiyonia/features/badges/region_landmark.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/regions/region_descriptions.dart';
import 'package:rehiyonia/features/regions/screens/region_intro_screen.dart';
import 'package:rehiyonia/features/regions/widgets/region_landmark_scene.dart';
import 'package:rehiyonia/features/settings/models/app_language.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';

import '../../support/explorer_fakes.dart';

void main() {
  test('English descriptions cover all 18 existing region codes without changing saved copy', () {
    expect(
      regionDescriptionsEnglish.keys.toSet(),
      defaultPhilippineRegions.map((r) => r.code).toSet(),
    );
    for (final region in defaultPhilippineRegions) {
      expect(regionDescription(region, english: true), isNotEmpty);
      expect(regionDescription(region, english: false), region.description);
    }
  });

  testWidgets(
    'Cultural Highlights follows the selected language and keeps saved descriptions',
    (tester) async {
      final session = ProviderContainer(
        overrides: [regionsProvider.overrideWith(TestRegions.new)],
      );
      addTearDown(session.dispose);
      final ncr = defaultPhilippineRegions.singleWhere((r) => r.code == 'NCR');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: session,
          child: const MaterialApp(home: RegionIntroScreen(regionId: 1)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(regionDescriptionsEnglish['NCR']!), findsOneWidget);
      expect(find.text(ncr.description), findsNothing);
      session.read(settingsProvider.notifier).setLanguage(AppLanguage.tagalog);
      await tester.pumpAndSettle();
      expect(find.text(ncr.description), findsOneWidget);
      expect(find.text(regionDescriptionsEnglish['NCR']!), findsNothing);
      expect(
        session
            .read(regionsProvider)
            .requireValue
            .singleWhere((r) => r.id == 1)
            .description,
        ncr.description,
      );
      session.read(settingsProvider.notifier).setLanguage(AppLanguage.english);
      await tester.pumpAndSettle();
      expect(find.text(regionDescriptionsEnglish['NCR']!), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  final photos = parseRegionLandmarks(
    File('assets/data/region_landmarks.json').readAsStringSync(),
  );

  testWidgets(
    'all 18 regional photos retain the saved avatar, credits, and learning routes',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MemoryProfileRepository();
      final session = ProviderContainer(
        overrides: [
          regionsProvider.overrideWith(TestRegions.new),
          regionLandmarksProvider.overrideWith((ref) async => photos),
          profileRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(session.dispose);
      const avatar = PlayerAvatar(
        baseId: 'female',
        hairStyleIndex: 5,
        topId: 'explorer',
        bottomId: 'cargo',
        headwearId: 'flower',
      );
      await session.read(profileProvider.notifier).setAvatar(avatar);
      Object? openedRegion;
      Future<void> show(int id) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: session,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              onGenerateRoute: (settings) {
                expect(settings.name, AppRouter.localityCards);
                openedRegion = settings.arguments;
                return MaterialPageRoute<void>(
                  builder: (_) =>
                      const Scaffold(body: Text('Localities destination')),
                );
              },
              home: RegionIntroScreen(key: ValueKey(id), regionId: id),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      for (final region in defaultPhilippineRegions) {
        await show(region.id);
        final scene = tester.widget<RegionLandmarkScene>(
          find.byType(RegionLandmarkScene),
        );
        expect(scene.landmark!.assetPath, photos[region.id]!.assetPath);
        final image = tester.widget<Image>(
          find.byKey(ValueKey('region_landmark_photo_${region.id}')),
        );
        expect(
          ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
          photos[region.id]!.assetPath,
        );
        final explorer = tester.widget<PlayerAvatarWidget>(
          find.byKey(const Key('region_explorer_avatar')),
        );
        expect(explorer.avatar, avatar);
        expect(explorer.fullBody, isTrue);
        expect(tester.takeException(), isNull);
      }

      await show(18);
      await tester.tap(find.byKey(const Key('region_photo_credits')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining(photos[18]!.author), findsOneWidget);
      expect(find.text(photos[18]!.sourceUrl), findsOneWidget);
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
      await tester.pumpAndSettle();
      final updated = avatar.copyWith(headwearId: 'bucket');
      await session.read(profileProvider.notifier).setAvatar(updated);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PlayerAvatarWidget>(
              find.byKey(const Key('region_explorer_avatar')),
            )
            .avatar,
        updated,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('button_start_learning')),
        200,
      );
      final nir = defaultPhilippineRegions.singleWhere((r) => r.id == 18);
      expect(
        tester
                .widget<FilledButton>(
                  find.byKey(const Key('button_start_learning')),
                )
                .onPressed ==
            null,
        !nir.isUnlocked,
      );
      await show(1);
      await tester.scrollUntilVisible(
        find.byKey(const Key('button_start_learning')).hitTestable(),
        200,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('button_start_learning')));
      await tester.pumpAndSettle();
      expect(openedRegion, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'photo metadata failure keeps the avatar and learning action available',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            regionsProvider.overrideWith(TestRegions.new),
            regionLandmarksProvider.overrideWith(
              (ref) async => throw StateError('Missing photo metadata'),
            ),
          ],
          child: const MaterialApp(home: RegionIntroScreen(regionId: 1)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('region_explorer_avatar')), findsOneWidget);
      expect(find.byTooltip('Retry photo'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('button_start_learning')),
        200,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('button_start_learning')),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
