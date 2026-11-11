import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_startup_provider.dart';
import 'package:rehiyonia/app/app_router.dart';
import 'package:rehiyonia/features/home/screens/home_screen.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';

import '../../support/explorer_fakes.dart';

import 'package:rehiyonia/features/splash/screens/splash_screen.dart';

class _NewExplorer extends StartupProgressNotifier {
  @override
  StartupProgress build() => const StartupProgress(step: 4, needsName: true);
}

void main() {
  for (final reduceMotion in [false, true]) {
    testWidgets(
      'logo and loading finish before home (reduce motion: $reduceMotion)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [appStartupProvider.overrideWith((_) async {})],
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: reduceMotion),
                child: child!,
              ),
              initialRoute: '/splash',
              routes: {
                '/splash': (_) => const SplashScreen(),
                '/': (_) => const Scaffold(body: Text('Ready home')),
              },
            ),
          ),
        );
        await tester.pump();
        expect(find.byKey(const Key('logo_intro')), findsOneWidget);
        expect(find.byKey(const Key('startup_progress')), findsNothing);
        await tester.pump(const Duration(milliseconds: 6900));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Ready home').hitTestable(), findsNothing);
        if (reduceMotion) {
          final transform = tester.widget<Transform>(
            find.byKey(const Key('splash_scene_motion')),
          );
          expect(transform.transform.getMaxScaleOnAxis(), 1);
        }
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle();
        expect(find.byType(SplashScreen), findsNothing);
        expect(find.text('Ready home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'slow startup stays beyond the presentation and enters when ready',
    (tester) async {
      final pending = Completer<void>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appStartupProvider.overrideWith((_) => pending.future)],
          child: MaterialApp(
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/': (_) => const Scaffold(body: Text('Ready home')),
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 8));
      expect(find.byType(SplashScreen), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Ready home'), findsOneWidget);
    },
  );
  testWidgets(
    'first startup prompts only after splash is removed and home transition finishes',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appStartupProvider.overrideWith((_) async {}),
            startupProgressProvider.overrideWith(_NewExplorer.new),
            regionsProvider.overrideWith(TestRegions.new),
          ],
          child: MaterialApp(
            initialRoute: AppRouter.splash,
            onGenerateInitialRoutes: (_) => [
              AppRouter.onGenerateRoute(
                const RouteSettings(name: AppRouter.splash),
              )!,
            ],
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 6900));
      expect(find.byKey(const Key('first_launch_name')), findsNothing);
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(const Key('first_launch_name')), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('first_launch_name')), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('small splash supports enlarged text and reduced motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pending = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStartupProvider.overrideWith((_) => pending.future)],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              disableAnimations: true,
              textScaler: TextScaler.linear(1.5),
            ),
            child: SplashScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('startup_progress')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    pending.complete();
  });
  testWidgets('failed startup stays on splash and retry reaches home', (
    tester,
  ) async {
    var tries = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStartupProvider.overrideWith((_) async {
            if (tries++ == 0) throw StateError('Cannot open database');
          }),
        ],
        child: MaterialApp(
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/': (_) => const Scaffold(body: Text('Ready home')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready home'), findsNothing);
    expect(find.byKey(const Key('startup_retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('startup_retry')));
    await tester.pumpAndSettle();
    expect(find.text('Ready home'), findsOneWidget);
  });
  testWidgets('pending initialization cannot enter Home', (tester) async {
    final pending = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStartupProvider.overrideWith((_) => pending.future)],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0,
    );
    await tester.pumpWidget(const SizedBox());
    pending.complete();
  });
}
