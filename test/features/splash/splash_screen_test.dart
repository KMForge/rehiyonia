import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app_startup_provider.dart';
import 'package:rehiyonia/features/splash/screens/splash_screen.dart';

class _NewExplorer extends StartupProgressNotifier {
  @override
  StartupProgress build() => const StartupProgress(step: 4, needsName: true);
}

void main() {
  testWidgets('first startup automatically prompts before entering Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStartupProvider.overrideWith((_) async {}),
          startupProgressProvider.overrideWith(_NewExplorer.new),
        ],
        child: MaterialApp(
          home: const SplashScreen(),
          routes: {'/home': (_) => const Scaffold(body: Text('Home'))},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('first_launch_name')), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(tester.takeException(), isNull);
  });

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
