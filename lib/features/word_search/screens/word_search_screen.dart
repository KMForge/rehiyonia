import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../mascot/widgets/bayanito_mascot_widget.dart';
import '../models/regional_word.dart';
import '../providers/gameplay_provider.dart';
import '../widgets/word_list_bar.dart';
import '../widgets/word_search_grid_widget.dart';

class WordSearchScreen extends ConsumerStatefulWidget {
  const WordSearchScreen({super.key, required this.regionId});

  final int regionId;

  @override
  ConsumerState<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends ConsumerState<WordSearchScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameplayProvider.notifier).initGame(widget.regionId);
    });
  }

  void _showClueModal(RegionalWord word) {
    final loc = ref.read(localizationsProvider);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.babyBlue.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      loc.categoryLabel(word.category),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: loc.closeButton,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                word.displayNameEn,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.isEnglish ? word.displayClueEn : word.displayClueFil,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textNavy,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCompletionDialog(GameplayState state) {
    final loc = ref.read(localizationsProvider);
    final regionName = loc.isEnglish
        ? (state.region?.designation ?? state.region?.name ?? 'Region')
        : (state.region?.name ?? 'Rehiyon');
    final hasNext = ref.read(gameplayProvider.notifier).hasNextLevel;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Center(
            child: Text(
              loc.congratulations,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textNavy,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BayanitoMascotWidget(
                size: 90,
                expression: MascotExpression.celebrating,
                animated: false,
              ),
              const SizedBox(height: 12),
              Text(
                loc.completedMessage(regionName),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textNavy),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < state.starsEarned
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFFFB300),
                    size: 42,
                  );
                }),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFFFFB300),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.rewardCoins(20, state.coins),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              key: const Key('button_return_regions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.deepBlue,
                side: const BorderSide(color: AppColors.deepBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                Navigator.pop(context); // Return to Region Selection
              },
              child: Text(loc.continueButton),
            ),
            if (hasNext)
              FilledButton.icon(
                key: const Key('button_next_level'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deepBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  final nextRegion =
                      ref.read(gameplayProvider.notifier).getNextRegion();
                  if (nextRegion != null) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.triviaChallenge,
                      arguments: nextRegion.id,
                    );
                  }
                },
                label: Text(loc.nextLevelButton),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameplayProvider);
    final loc = ref.watch(localizationsProvider);

    ref.listen<GameplayState>(gameplayProvider, (prev, next) {
      if (prev?.status != GameStatus.completed &&
          next.status == GameStatus.completed) {
        _showCompletionDialog(next);
      }
    });

    if (gameState.status == GameStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.deepBlue),
        ),
      );
    }

    if (gameState.status == GameStatus.error) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.errorTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(gameState.errorMessage ?? loc.errorLoadingRegions),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deepBlue,
                  ),
                  onPressed: () => ref
                      .read(gameplayProvider.notifier)
                      .initGame(widget.regionId),
                  child: Text(loc.retryButton),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final puzzle = gameState.puzzle;
    if (puzzle == null) {
      return Scaffold(body: Center(child: Text(loc.noPuzzleError)));
    }

    final primaryTitle = loc.isEnglish
        ? (gameState.region?.designation ??
              gameState.region?.name ??
              'Word Search')
        : (gameState.region?.name ?? 'Word Search');
    final secondaryTitle = loc.isEnglish
        ? (gameState.region?.name ?? '')
        : (gameState.region?.designation ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              primaryTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textNavy,
              ),
            ),
            if (secondaryTitle.isNotEmpty)
              Text(
                secondaryTitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedSlate,
                ),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.babyBlue),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFFFB300),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gameState.coins}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textNavy,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textNavy),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar (Grid size, Found count, Hint button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.babyBlue.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.grid_4x4_rounded,
                          size: 16,
                          color: AppColors.deepBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${puzzle.rows}x${puzzle.cols}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.deepBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    loc.foundCount(
                      gameState.foundWords.length,
                      puzzle.placedWords.length,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textNavy,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF8E1),
                      foregroundColor: const Color(0xFFE65100),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFFD54F)),
                      ),
                    ),
                    onPressed: gameState.coins >= 10
                        ? () => ref.read(gameplayProvider.notifier).useHint()
                        : null,
                    icon: const Icon(
                      Icons.lightbulb_rounded,
                      size: 16,
                      color: Color(0xFFFFA000),
                    ),
                    label: Text(
                      loc.hintButton,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Word search grid
            Expanded(
              child: WordSearchGridWidget(
                puzzle: puzzle,
                activeSelection: gameState.activeSelection,
                revealedHints: gameState.revealedHints,
                onSelectionUpdate: (from, to) {
                  ref
                      .read(gameplayProvider.notifier)
                      .updateDragSelection(from, to);
                },
                onSelectionEnd: () {
                  ref.read(gameplayProvider.notifier).finalizeSelection();
                },
              ),
            ),

            // Target word list
            WordListBar(
              words: gameState.targetWords,
              foundWords: gameState.foundWords,
              onWordClueTap: _showClueModal,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
