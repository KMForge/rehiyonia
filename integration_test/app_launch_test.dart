import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehiyonia/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'App boots up, displays main menu and navigates to region selection',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: RehiyoniaApp()));
      await tester.pumpAndSettle();

      expect(find.text('Rehiyonia'), findsOneWidget);
      expect(find.text('MAGLARO (Play)'), findsOneWidget);

      await tester.tap(find.text('MAGLARO (Play)'));
      await tester.pumpAndSettle();

      expect(find.text('Pumili ng Rehiyon (Regions)'), findsOneWidget);
      expect(find.text('Pangkat ng Luzon'), findsOneWidget);
    },
  );
}
