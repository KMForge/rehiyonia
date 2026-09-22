import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../trivia/models/trivia_item.dart';

class RichTriviaDialog extends StatefulWidget {
  const RichTriviaDialog({
    super.key,
    required this.trivia,
    required this.regionName,
    required this.loc,
    required this.onCompleted,
  });

  final TriviaItem trivia;
  final String regionName;
  final AppLocalizations loc;
  final void Function({required bool isCorrect}) onCompleted;

  @override
  State<RichTriviaDialog> createState() => _RichTriviaDialogState();
}

class _RichTriviaDialogState extends State<RichTriviaDialog> {
  late List<String> _options;
  late int _correctIndex;
  int? _selectedIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _prepareOptions();
  }

  void _prepareOptions() {
    final correctAnswer = widget.trivia.answer.trim();

    // Check if distinct options already exist in trivia
    if (widget.trivia.optionB.trim().isNotEmpty &&
        widget.trivia.optionC.trim().isNotEmpty) {
      _options = [
        widget.trivia.optionA,
        widget.trivia.optionB,
        widget.trivia.optionC,
        widget.trivia.optionD,
      ];
      _correctIndex = widget.trivia.correctOption.clamp(0, _options.length - 1);
    } else {
      // Create high-quality plausible distractors for Grade 5 AP
      final distractors =
          <String>[
                'Intramuros',
                'Vigan',
                'Banaue Rice Terraces',
                'Bulkang Mayon',
                'Chocolate Hills',
                'Maria Cristina Falls',
                'Bundok Apo',
                'Balangay',
                'Dinagyang Festival',
                'Puerto Princesa Subterranean River',
              ]
              .where((d) => d.toLowerCase() != correctAnswer.toLowerCase())
              .toList()
            ..shuffle();

      final pickedDistractors = distractors.take(3).toList();
      _options = [correctAnswer, ...pickedDistractors]..shuffle();
      _correctIndex = _options.indexOf(correctAnswer);
    }
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = widget.loc;
    final isCorrect = _selectedIndex == _correctIndex;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Curriculum Tag & Region
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.triviaChallenge,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          widget.regionName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: Text(
                  widget.trivia.question,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                loc.selectAnswer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Options
              ...List.generate(_options.length, (index) {
                final optionText = _options[index];
                Color? backgroundColor;
                Color? textColor;
                BorderSide borderSide = BorderSide(
                  color: theme.colorScheme.outlineVariant,
                );

                if (_answered) {
                  if (index == _correctIndex) {
                    backgroundColor = const Color(0xFFE8F5E9);
                    textColor = const Color(0xFF1B5E20);
                    borderSide = const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 2,
                    );
                  } else if (index == _selectedIndex) {
                    backgroundColor = const Color(0xFFFFEBEE);
                    textColor = const Color(0xFFB71C1C);
                    borderSide = const BorderSide(
                      color: Color(0xFFE57373),
                      width: 2,
                    );
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    key: Key('trivia_option_$index'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      side: borderSide,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: _answered ? null : () => _selectOption(index),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _answered && index == _correctIndex
                              ? const Color(0xFF4CAF50)
                              : (_answered && index == _selectedIndex
                                    ? const Color(0xFFE57373)
                                    : theme.colorScheme.primaryContainer),
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  _answered &&
                                      (index == _correctIndex ||
                                          index == _selectedIndex)
                                  ? Colors.white
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor ?? theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (_answered && index == _correctIndex)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2E7D32),
                          ),
                        if (_answered &&
                            index == _selectedIndex &&
                            index != _correctIndex)
                          const Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFFC62828),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              // Feedback and Deep-Dive Educational Fact
              if (_answered) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFFF1F8E9)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFFAED581)
                          : const Color(0xFFFFD54F),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.verified_rounded
                                : Icons.info_outline_rounded,
                            color: isCorrect
                                ? const Color(0xFF2E7D32)
                                : Colors.amber.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isCorrect
                                  ? '${loc.correctAnswer} (${loc.triviaBonus})'
                                  : loc.incorrectAnswer,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? const Color(0xFF2E7D32)
                                    : Colors.brown.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 4),
                        Text(
                          _options[_correctIndex],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '💡 ${loc.funFactTitle}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCorrect
                              ? const Color(0xFF2E7D32)
                              : Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.trivia.funFact,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('button_trivia_continue'),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onCompleted(isCorrect: isCorrect);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    loc.continueButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
