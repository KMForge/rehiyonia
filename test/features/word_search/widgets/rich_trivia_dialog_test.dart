import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/localization/app_localizations.dart';
import 'package:rehiyonia/features/settings/models/app_language.dart';
import 'package:rehiyonia/features/trivia/models/trivia_item.dart';
import 'package:rehiyonia/features/word_search/widgets/rich_trivia_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testTrivia = const TriviaItem(
    id: 1,
    regionId: 1,
    question: 'Alin ang tinaguriang Intramuros sa Maynila?',
    optionA: 'Walled City',
    optionB: 'Rizal Park',
    optionC: 'Binondo',
    optionD: 'Malacañang',
    correctOption: 0,
    explanation: 'Ang Intramuros ang pinakamatandang distrito sa Maynila na itinayo ng mga Espanyol.',
  );

  testWidgets(
    'RichTriviaDialog displays question and options, and awards bonus on correct answer',
    (WidgetTester tester) async {
      bool? callbackResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => RichTriviaDialog(
                        trivia: testTrivia,
                        regionName: 'National Capital Region',
                        loc: const AppLocalizations(AppLanguage.english),
                        onCompleted: ({required bool isCorrect}) {
                          callbackResult = isCorrect;
                        },
                      ),
                    );
                  },
                  child: const Text('Open Trivia'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Trivia'));
      await tester.pumpAndSettle();

      // Verify Title and Question
      expect(find.textContaining('Regional Trivia Challenge'), findsOneWidget);
      expect(find.text('National Capital Region'), findsOneWidget);
      expect(
        find.text('Alin ang tinaguriang Intramuros sa Maynila?'),
        findsOneWidget,
      );

      // Verify 4 options
      expect(find.text('Walled City'), findsOneWidget);
      expect(find.text('Rizal Park'), findsOneWidget);
      expect(find.text('Binondo'), findsOneWidget);
      expect(find.text('Malacañang'), findsOneWidget);

      // Continue button is not shown yet before answering
      expect(find.byKey(const Key('button_trivia_continue')), findsNothing);

      // Tap the correct answer (Option A)
      await tester.tap(find.byKey(const Key('trivia_option_0')));
      await tester.pumpAndSettle();

      // Feedback and Educational Fact
      expect(find.textContaining('Correct!'), findsOneWidget);
      expect(find.textContaining('+10 Bonus Coins'), findsOneWidget);
      expect(
        find.text(
          'Ang Intramuros ang pinakamatandang distrito sa Maynila na itinayo ng mga Espanyol.',
        ),
        findsOneWidget,
      );

      // Tap Continue
      final continueBtn = find.byKey(const Key('button_trivia_continue'));
      expect(continueBtn, findsOneWidget);
      await tester.ensureVisible(continueBtn);
      await tester.pumpAndSettle();
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Verify dialog closed and callback was true
      expect(find.textContaining('Regional Trivia Challenge'), findsNothing);
      expect(callbackResult, isTrue);
    },
  );

  testWidgets(
    'RichTriviaDialog handles incorrect answer with feedback and correct answer hint',
    (WidgetTester tester) async {
      bool? callbackResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => RichTriviaDialog(
                        trivia: testTrivia,
                        regionName: 'NCR',
                        loc: const AppLocalizations(AppLanguage.tagalog),
                        onCompleted: ({required bool isCorrect}) {
                          callbackResult = isCorrect;
                        },
                      ),
                    );
                  },
                  child: const Text('Open Trivia TL'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Trivia TL'));
      await tester.pumpAndSettle();

      // Tap incorrect answer (Option B)
      await tester.tap(find.byKey(const Key('trivia_option_1')));
      await tester.pumpAndSettle();

      // Feedback shows incorrect message in Tagalog
      expect(find.textContaining('Muntik na'), findsOneWidget);

      // Tap Continue
      final continueBtn = find.byKey(const Key('button_trivia_continue'));
      await tester.ensureVisible(continueBtn);
      await tester.pumpAndSettle();
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      expect(callbackResult, isFalse);
    },
  );
}
