import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../mascot/widgets/bayanito_mascot_widget.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/trivia_item.dart';
import '../providers/trivia_provider.dart';

class PreGameTriviaScreen extends ConsumerStatefulWidget {
  const PreGameTriviaScreen({super.key, required this.regionId});

  final int regionId;

  @override
  ConsumerState<PreGameTriviaScreen> createState() =>
      _PreGameTriviaScreenState();
}

class _PreGameTriviaScreenState extends ConsumerState<PreGameTriviaScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _bonusCoinsEarned = 0;

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationsProvider);
    final triviaAsync = ref.watch(triviaForRegionProvider(widget.regionId));

    return Scaffold(
      appBar: AppBar(title: Text(loc.triviaChallenge)),
      body: triviaAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.deepBlue),
        ),
        error: (err, stack) => Center(child: Text(loc.noTriviaAvailable)),
        data: (triviaList) {
          if (triviaList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.noTriviaAvailable),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.game,
                        arguments: widget.regionId,
                      );
                    },
                    child: Text(loc.startWordSearchButton),
                  ),
                ],
              ),
            );
          }

          final currentItem = triviaList[_currentQuestionIndex];
          final totalQuestions = triviaList.length;
          final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;

          final options = [
            currentItem.getOptionA(loc.isEnglish),
            currentItem.getOptionB(loc.isEnglish),
            currentItem.getOptionC(loc.isEnglish),
            currentItem.getOptionD(loc.isEnglish),
          ];

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card with Coins Bonus & Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.questionProgress(
                          _currentQuestionIndex + 1,
                          totalQuestions,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textNavy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD54F)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFFFFB300),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+$_bonusCoinsEarned 🪙',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Question Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withValues(alpha: 0.1),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.babyBlue, width: 2),
                    ),
                    child: Column(
                      children: [
                        BayanitoMascotWidget(
                          size: 80,
                          expression: _answered
                              ? (_selectedOption == currentItem.correctOption
                                    ? MascotExpression.cheering
                                    : MascotExpression.thinking)
                              : MascotExpression.thinking,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentItem.getQuestion(loc.isEnglish),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            color: AppColors.textNavy,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Option Buttons
                  ...List.generate(4, (index) {
                    final optionText = options[index];
                    if (optionText.isEmpty) return const SizedBox.shrink();

                    Color cardColor = Colors.white;
                    Color borderColor = AppColors.babyBlue;
                    Widget? trailingIcon;

                    if (_answered) {
                      if (index == currentItem.correctOption) {
                        cardColor = AppColors.successMint.withValues(
                          alpha: 0.6,
                        );
                        borderColor = const Color(0xFF2E7D32);
                        trailingIcon = const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        );
                      } else if (index == _selectedOption) {
                        cardColor = AppColors.warningPeach.withValues(
                          alpha: 0.6,
                        );
                        borderColor = const Color(0xFFE65100);
                        trailingIcon = const Icon(
                          Icons.cancel_rounded,
                          color: Color(0xFFE65100),
                          size: 24,
                        );
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: _answered
                              ? null
                              : () => _handleAnswer(index, currentItem),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 56),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: borderColor,
                                width:
                                    (_answered &&
                                        (index == currentItem.correctOption ||
                                            index == _selectedOption))
                                    ? 2.5
                                    : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.babyBlue.withValues(
                                      alpha: 0.4,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    String.fromCharCode(
                                      65 + index,
                                    ), // A, B, C, D
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textNavy,
                                    ),
                                  ),
                                ),
                                ?trailingIcon,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Explanation Box when answered
                  if (_answered) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.softLavender,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedOption == currentItem.correctOption
                                    ? Icons.thumb_up_rounded
                                    : Icons.info_outline_rounded,
                                color:
                                    _selectedOption == currentItem.correctOption
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.deepBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedOption == currentItem.correctOption
                                    ? loc.correctAnswer
                                    : loc.incorrectAnswer,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color:
                                      _selectedOption ==
                                          currentItem.correctOption
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentItem.getExplanation(loc.isEnglish),
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.textNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Next Question or Start Word Search Button
                    FilledButton(
                      key: const Key('button_trivia_continue_or_start'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.deepBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if (isLastQuestion) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.game,
                            arguments: widget.regionId,
                          );
                        } else {
                          setState(() {
                            _currentQuestionIndex++;
                            _answered = false;
                            _selectedOption = null;
                          });
                        }
                      },
                      child: Text(
                        isLastQuestion
                            ? loc.startWordSearchButton
                            : loc.continueButton,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAnswer(int optionIndex, TriviaItem item) {
    setState(() {
      _selectedOption = optionIndex;
      _answered = true;
      if (optionIndex == item.correctOption) {
        _bonusCoinsEarned += 10;
        ref.read(profileProvider.notifier).addCoins(10);
      }
    });
  }
}
