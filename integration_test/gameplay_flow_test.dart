import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehiyonia/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Gameplay flow: selects region, views word clues, and triggers hint',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: RehiyoniaApp()));
      await tester.pumpAndSettle();

      // 1. Enter Region Selection
      await tester.tap(find.text('MAGLARO (Play)'));
      await tester.pumpAndSettle();

      // 2. Tap NCR to open gameplay
      expect(find.text('Pambansang Punong Rehiyon'), findsOneWidget);
      await tester.tap(find.text('Pambansang Punong Rehiyon'));
      await tester.pumpAndSettle();

      // 3. Verify gameplay elements loaded
      expect(find.textContaining('Pambansang Punong Rehi'), findsOneWidget);
      expect(find.textContaining('Hint (-10'), findsOneWidget);

      // Initial coins: 50
      expect(find.text('50'), findsOneWidget);

      // 4. Tap Hint button: coins should become 40
      await tester.tap(find.textContaining('Hint (-10'));
      await tester.pumpAndSettle();
      expect(find.text('40'), findsOneWidget);

      // 5. Tap target word chip to open educational clue sheet
      expect(find.text('MANILA'), findsOneWidget);
      await tester.tap(find.text('MANILA'));
      await tester.pumpAndSettle();

      // Verify clue contents
      expect(find.text('Lungsod'), findsOneWidget);
      expect(find.text('Kabisera ng Republika ng Pilipinas.'), findsOneWidget);

      // 6. Close bottom sheet
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
    },
  );
}
