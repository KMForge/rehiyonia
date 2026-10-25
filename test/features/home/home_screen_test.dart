import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/app.dart';
import 'package:rehiyonia/app/app_startup_provider.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';

import '../../support/explorer_fakes.dart';

void main() {
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
      expect(find.text('Rehiyonia'), findsOneWidget);
      expect(find.text('Start exploring'), findsOneWidget);
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
        find.byKey(const Key('menu_avatar_button')),
        200,
      );
      expect(find.byKey(const Key('menu_avatar_button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
