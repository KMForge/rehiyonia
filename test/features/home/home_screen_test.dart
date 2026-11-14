import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app.dart';
import 'package:rehiyonia/app/app_startup_provider.dart';
import 'package:rehiyonia/app/app_theme.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/features/home/screens/home_screen.dart';
import 'package:rehiyonia/features/home/widgets/home_player_header.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/avatar/providers/avatar_editor_provider.dart';
import 'package:rehiyonia/features/avatar/screens/avatar_studio_screen.dart';
import 'package:rehiyonia/features/avatar/widgets/player_avatar_widget.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';
import 'package:rehiyonia/features/regions/screens/region_intro_screen.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';

import '../../support/explorer_fakes.dart';

class _HomeRegions extends TestRegions {
  void recordJourney() {
    state = AsyncData([
      for (final region in state.requireValue)
        region.copyWith(
          isUnlocked: region.id <= 2,
          starsEarned: region.id == 1 ? 3 : 0,
        ),
    ]);
  }
}

void main() {
  testWidgets('profile hugs short text and grows when the saved name changes', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [regionsProvider.overrideWith(TestRegions.new)],
    );
    addTearDown(container.dispose);
    final profile = container.read(profileProvider.notifier);
    await profile.setPlayerName('Li');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final pillFinder = find.byKey(const Key('home_profile_pill'));
    final shortPill = tester.getRect(pillFinder);
    final greeting = tester.getRect(
      find.byKey(const Key('home_profile_greeting')),
    );
    final name = tester.getRect(find.byKey(const Key('home_profile_username')));
    final textRight = greeting.right > name.right ? greeting.right : name.right;
    expect(shortPill.right - textRight, lessThanOrEqualTo(12));
    expect(
      tester.getRect(find.byKey(const Key('menu_settings_button'))).right,
      closeTo(tester.getRect(find.byType(HomePlayerHeader)).right, .01),
    );
    await profile.setPlayerName('Maria Isabel dela Cruz');
    await tester.pumpAndSettle();
    expect(tester.getSize(pillFinder).width, greaterThan(shortPill.width));
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(430, 932),
  ]) {
    for (final scale in [1.0, 1.6]) {
      testWidgets('large profile fits ${size.width}px at text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer(
          overrides: [regionsProvider.overrideWith(TestRegions.new)],
        );
        addTearDown(container.dispose);
        await container
            .read(profileProvider.notifier)
            .setPlayerName('Maria Isabel dela Cruz');
        await container.read(profileProvider.notifier).setCoins(123456);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 34),
                ),
                child: child!,
              ),
              home: const HomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final pill = tester.getRect(find.byKey(const Key('home_profile_pill')));
        final portrait = tester.getRect(
          find.byKey(const Key('home_profile_avatar_frame')),
        );
        final username = tester.getRect(
          find.byKey(const Key('home_profile_username')),
        );
        final settings = tester.getRect(
          find.byKey(const Key('menu_settings_button')),
        );
        final logo = tester.getRect(
          find.byKey(const Key('home_existing_logo')),
        );
        expect(portrait.size, const Size(60, 60));
        expect(pill.top, greaterThanOrEqualTo(24));
        expect(pill.bottom, lessThan(logo.top));
        expect(pill.overlaps(settings), isFalse);
        expect(
          settings.right,
          closeTo(tester.getRect(find.byType(HomePlayerHeader)).right, .01),
        );
        expect(username.right, lessThanOrEqualTo(pill.right));
        expect(username.bottom, lessThanOrEqualTo(pill.bottom));
        expect(find.text('Maria Isabel dela Cruz'), findsOneWidget);
        expect(find.text('123456'), findsOneWidget);
        await tester.tap(find.byKey(const Key('button_player_profile')));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'home refreshes saved identity and rewards and counts only completed regions',
    (tester) async {
      final container = ProviderContainer(
        overrides: [regionsProvider.overrideWith(_HomeRegions.new)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HomeScreen(),
            routes: {
              AppRouter.settings: (_) =>
                  const Scaffold(body: Text('Settings destination')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_settings_button')));
      await tester.pumpAndSettle();
      final profile = container.read(profileProvider.notifier);
      await profile.setPlayerName('Mayumi');
      await profile.setCoins(125);
      await profile.addStars(3);
      (container.read(regionsProvider.notifier) as _HomeRegions)
          .recordJourney();
      Navigator.of(tester.element(find.text('Settings destination'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Mayumi'), findsOneWidget);
      expect(find.text('125'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Completed: 1 / 18'), 150);
      expect(find.text('Completed: 1 / 18'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      final help = find.byKey(const Key('menu_about_button'));
      await tester.scrollUntilVisible(help, 100);
      await tester.pumpAndSettle();
      await tester.tap(help);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'saved explorer updates home and travels into regions after reload',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MemoryProfileRepository();
      ProviderContainer newSession() {
        final container = ProviderContainer(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repo),
            regionsProvider.overrideWith(TestRegions.new),
          ],
        );
        addTearDown(container.dispose);
        return container;
      }

      Widget app(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(),
          routes: {
            AppRouter.avatarStudio: (_) => const AvatarStudioScreen(),
            AppRouter.islandGroups: (_) => const RegionIntroScreen(regionId: 1),
          },
        ),
      );
      final first = newSession();
      await tester.pumpWidget(app(first));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adventure_customize_avatar')));
      await tester.pumpAndSettle();
      const customized = PlayerAvatar(
        skinIndex: 2,
        hairStyleIndex: 3,
        hairColorIndex: 1,
        outfitColorIndex: 2,
        topId: 'striped_tee',
        bottomId: 'chinos',
        braceletId: 'woven',
      );
      first.read(avatarEditorProvider.notifier).change(customized);
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('button_save_avatar'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(AvatarStudioScreen))).pop();
      await tester.pumpAndSettle();
      PlayerAvatarWidget hero() => tester.widget<PlayerAvatarWidget>(
        find.byKey(const Key('adventure_player_avatar')),
      );
      expect(hero().avatar, customized);
      expect(
        tester
            .widget<PlayerAvatarWidget>(
              find.byKey(const Key('home_profile_avatar')),
            )
            .avatar,
        customized,
      );
      expect(hero().fullBody, isTrue);
      expect(repo.avatar, customized);
      await tester.tap(find.byKey(const Key('adventure_explore_map')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PlayerAvatarWidget>(find.byType(PlayerAvatarWidget).last)
            .avatar,
        customized,
      );
      // Recreate provider state, as startup does after closing the app.
      await tester.pumpWidget(const SizedBox.shrink());
      final second = newSession();
      await second.read(profileProvider.notifier).loadProfile();
      await tester.pumpWidget(app(second));
      await tester.pumpAndSettle();
      expect(hero().avatar, customized);
      expect(
        tester
            .widget<PlayerAvatarWidget>(
              find.byKey(const Key('home_profile_avatar')),
            )
            .avatar,
        customized,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reference menu opens play, passport, dress and region screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? destination;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [regionsProvider.overrideWith(TestRegions.new)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(),
          onGenerateRoute: (settings) {
            destination = settings.name;
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Menu destination')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final entry in {
      'menu_settings_button': AppRouter.settings,
      'menu_play_button': AppRouter.regions,
      'menu_badge_gallery_button': AppRouter.badges,
      'menu_avatar_button': AppRouter.avatarStudio,
      'menu_explore_regions_button': AppRouter.islandGroups,
    }.entries) {
      final target = find.byKey(Key(entry.key));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(destination, entry.value);
      Navigator.of(tester.element(find.text('Menu destination'))).pop();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(1024, 900),
  ]) {
    testWidgets('home navigation fits ${size.width}px with enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? selectedRoute;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [regionsProvider.overrideWith(TestRegions.new)],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.4)),
              child: child!,
            ),
            home: const HomeScreen(),
            onGenerateRoute: (settings) {
              selectedRoute = settings.name;
              return MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(body: Text('Region destination')),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('menu_play_button')),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('menu_play_button')), findsOneWidget);
      expect(tester.takeException(), isNull);
      final explore = find.byKey(const Key('menu_explore_regions_button'));
      await tester.ensureVisible(explore);
      await tester.pumpAndSettle();
      await tester.tap(explore);
      await tester.pumpAndSettle();
      expect(selectedRoute, AppRouter.islandGroups);
      expect(find.text('Region destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Explorer home opens profile, saves name and exposes journey actions',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appStartupProvider.overrideWith((_) async {}),
            regionsProvider.overrideWith(TestRegions.new),
          ],
          child: const RehiyoniaApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_existing_logo')), findsOneWidget);
      expect(find.text('Bayani'), findsOneWidget);
      await tester.tap(find.byKey(const Key('button_player_profile')));
      await tester.pumpAndSettle();
      expect(find.text('Explorer profile'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Gabriela');
      await tester.tap(find.byKey(const Key('button_save_player_name')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Gabriela'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('menu_play_button')),
        160,
      );
      expect(find.text('Start Exploring'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('menu_avatar_button')),
        200,
      );
      expect(find.byKey(const Key('menu_avatar_button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
