import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rehiyonia_adventure_background.dart';
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
    final loadedItems = triviaAsync.asData?.value;
    final displayedItem =
        loadedItems != null && _currentQuestionIndex < loadedItems.length
        ? loadedItems[_currentQuestionIndex]
        : null;

    return Scaffold(
      backgroundColor: RehiyoniaAdventureBackground.cream,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: RehiyoniaAdventureBackground.sky,
        surfaceTintColor: Colors.transparent,
        foregroundColor: RehiyoniaAdventureBackground.ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.triviaChallenge,
          maxLines: 2,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_answered && displayedItem?.imageCredit != null)
            IconButton(
              key: const Key('trivia_photo_credits'),
              tooltip: loc.isEnglish ? 'Photo credits' : 'Pagkilala sa larawan',
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => _showPhotoCredits(displayedItem!, loc.isEnglish),
            ),
        ],
      ),
      body: RehiyoniaAdventureBackground(
        child: SizedBox.expand(
          child: triviaAsync.when(
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
              final isLastQuestion =
                  _currentQuestionIndex == totalQuestions - 1;
              final imageCaption = currentItem.getImageCaption(loc.isEnglish);

              final options = [
                currentItem.getOptionA(loc.isEnglish),
                currentItem.getOptionB(loc.isEnglish),
                currentItem.getOptionC(loc.isEnglish),
                currentItem.getOptionD(loc.isEnglish),
              ];

              return SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Card with Coins Bonus & Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
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
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFD54F),
                                  ),
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
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: RehiyoniaAdventureBackground.cream,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x0A5B3B27),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFE1C5A8),
                              ),
                            ),
                            child: Column(
                              children: [
                                BayanitoMascotWidget(
                                  size: 60,
                                  expression: _answered
                                      ? (_selectedOption ==
                                                currentItem.correctOption
                                            ? MascotExpression.cheering
                                            : MascotExpression.thinking)
                                      : MascotExpression.thinking,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentItem.getQuestion(loc.isEnglish),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.35,
                                    color: RehiyoniaAdventureBackground.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Option Buttons
                          ...List.generate(4, (index) {
                            final optionText = options[index];
                            if (optionText.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            Color cardColor =
                                RehiyoniaAdventureBackground.cream;
                            Color borderColor = const Color(0xFFE1C5A8);
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
                                  size: 20,
                                );
                              } else if (index == _selectedOption) {
                                cardColor = AppColors.warningPeach.withValues(
                                  alpha: 0.6,
                                );
                                borderColor = const Color(0xFFE65100);
                                trailingIcon = const Icon(
                                  Icons.cancel_rounded,
                                  color: Color(0xFFE65100),
                                  size: 20,
                                );
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  key: Key('trivia_option_$index'),
                                  onTap: _answered
                                      ? null
                                      : () => _handleAnswer(index, currentItem),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 48,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: borderColor,
                                        width:
                                            (_answered &&
                                                (index ==
                                                        currentItem
                                                            .correctOption ||
                                                    index == _selectedOption))
                                            ? 2.5
                                            : 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF4E8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            String.fromCharCode(
                                              65 + index,
                                            ), // A, B, C, D
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF7A563B),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
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
                            const SizedBox(height: 8),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 440,
                                ),
                                child: Container(
                                  key: const Key('trivia_explanation_card'),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5E7D7),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFE1C5A8),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _selectedOption ==
                                                    currentItem.correctOption
                                                ? Icons.thumb_up_rounded
                                                : Icons.info_outline_rounded,
                                            color:
                                                _selectedOption ==
                                                    currentItem.correctOption
                                                ? const Color(0xFF2E7D32)
                                                : AppColors.deepBlue,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedOption ==
                                                      currentItem.correctOption
                                                  ? loc.correctAnswer
                                                  : loc.incorrectAnswer,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                    _selectedOption ==
                                                        currentItem
                                                            .correctOption
                                                    ? const Color(0xFF2E7D32)
                                                    : const Color(0xFFE65100),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildExplanationContent(
                                        currentItem,
                                        loc.isEnglish,
                                        imageCaption,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Next Question or Start Word Search Button
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                child: FilledButton(
                                  key: const Key(
                                    'button_trivia_continue_or_start',
                                  ),
                                  style:
                                      FilledButton.styleFrom(
                                        backgroundColor:
                                            RehiyoniaAdventureBackground.mauve,
                                        foregroundColor:
                                            RehiyoniaAdventureBackground.ink,
                                        minimumSize: const Size(0, 48),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ).copyWith(
                                        backgroundBuilder:
                                            RehiyoniaAdventureBackground
                                                .glossyMauve,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationContent(
    TriviaItem item,
    bool english,
    String? caption,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final text = Column(
        key: const Key('trivia_explanation_text'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.getExplanation(english),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textNavy,
            ),
          ),
          if (item.imagePath != null && caption != null) ...[
            const SizedBox(height: 6),
            Text(caption, style: const TextStyle(fontSize: 12, height: 1.4)),
          ],
        ],
      );
      if (item.imagePath == null) return text;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: text),
          const SizedBox(width: 10),
          Container(
            key: const Key('trivia_photo_frame'),
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth < 320 ? 72 : 112,
            ),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1C5A8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100),
                child: Image.asset(
                  item.imagePath!,
                  key: const Key('trivia_culture_image'),
                  fit: BoxFit.contain,
                  semanticLabel: caption,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

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

  void _showPhotoCredits(TriviaItem item, bool english) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF4E8),
        scrollable: true,
        title: Text(english ? 'Photo credits' : 'Pagkilala sa larawan'),
        content: FutureBuilder<List<dynamic>>(
          future: rootBundle
              .loadString('assets/data/culture_image_credits.json')
              .then((source) => jsonDecode(source) as List<dynamic>),
          builder: (context, snapshot) {
            final credit = (snapshot.data ?? const <dynamic>[])
                .cast<Map<String, dynamic>>()
                .where((row) => row['asset_path'] == item.imagePath)
                .firstOrNull;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.imageCredit ?? ''),
                if (credit != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(credit['source_url'] as String),
                  const SizedBox(height: 12),
                  SelectableText(credit['license_url'] as String),
                  const SizedBox(height: 12),
                  Text(credit['modifications'] as String),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(english ? 'Close' : 'Isara'),
          ),
        ],
      ),
    );
  }
}
