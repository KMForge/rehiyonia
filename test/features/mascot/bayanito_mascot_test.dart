import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/mascot/widgets/bayanito_mascot_widget.dart';

void main() {
  group('Bayanito Mascot Tests', () {
    testWidgets(
      'renders Bayanito with idle, cheering, and thinking expressions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  BayanitoMascotWidget(
                    size: 80,
                    expression: MascotExpression.idle,
                    animated: false,
                  ),
                  BayanitoMascotWidget(
                    size: 80,
                    expression: MascotExpression.cheering,
                    animated: false,
                  ),
                  BayanitoMascotWidget(
                    size: 80,
                    expression: MascotExpression.thinking,
                    showSpeechBubble: true,
                    speechText: 'Subukan mo ito!',
                    animated: false,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(BayanitoMascotWidget), findsNWidgets(3));
        expect(find.text('Subukan mo ito!'), findsOneWidget);
      },
    );
  });
}
