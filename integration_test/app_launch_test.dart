import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'App boots up, displays main menu and navigates to region selection',
    (tester) async {
      await launchTestApp(tester);

      expect(find.text('Rehiyonia'), findsOneWidget);
      expect(find.byKey(const Key('menu_play_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('menu_play_button')));
      await tester.pumpAndSettle();

      expect(find.text('Select Region'), findsOneWidget);
      expect(find.text('Luzon'), findsWidgets);
    },
  );
}
