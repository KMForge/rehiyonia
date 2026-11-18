import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../../shared/widgets/how_to_play_dialog.dart';
import '../../../shared/widgets/rehiyonia_adventure_background.dart';
import '../../mascot/widgets/bayanito_mascot_widget.dart';
import '../../final_challenge/final_challenge_provider.dart';
import '../../../shared/widgets/word_discovery_content.dart';
import '../../regions/providers/region_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/regional_word.dart';
import '../providers/gameplay_provider.dart';
import '../widgets/word_list_bar.dart';
import '../widgets/word_search_grid_widget.dart';

class WordSearchScreen extends ConsumerStatefulWidget {
  const WordSearchScreen({
    super.key,
    required this.regionId,
    this.previewCompletion = false,
    this.isFinalChallenge = false,
    this.replayFinal = false,
  });

  final int regionId;
  final bool isFinalChallenge, replayFinal;

  /// Used only by the standalone debug preview; never completes a real game.
  final bool previewCompletion;

  @override
  ConsumerState<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends ConsumerState<WordSearchScreen> {
  final List<RegionalWord> _pendingWordPhotos = [];
  bool _wordPhotoOpen = false;
  GameplayState? _pendingCompletion;
  bool get _isCompletionPreview => kDebugMode && widget.previewCompletion;

  void _showPreview() {
    _showCompletionDialog(
      GameplayState(
        status: GameStatus.completed,
        region: defaultPhilippineRegions.first,
        starsEarned: 3,
        coins: 275,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_isCompletionPreview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showPreview();
      });
      return;
    }
    Future.microtask(() {
      if (widget.isFinalChallenge) {
        ref
            .read(gameplayProvider.notifier)
            .initFinalChallenge(replay: widget.replayFinal);
      } else {
        ref.read(gameplayProvider.notifier).initGame(widget.regionId);
      }
    });
  }

  void _showClueModal(RegionalWord word) {
    final loc = ref.read(localizationsProvider);
    if (ref.read(gameplayProvider).foundWords.contains(word.word)) {
      _showWordPhoto(word);
      return;
    }
    if (widget.isFinalChallenge) return;
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

  Future<void> _showWordPhoto(RegionalWord word) => showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: RehiyoniaAdventureBackground.cream,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: RehiyoniaAdventureBackground.champagne),
      ),
      child: ConstrainedBox(
        key: const Key('final_discovery_box'),
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(dialogContext).height * .8,
        ),
        child: WordDiscoveryContent(
          word: word,
          english: ref.read(localizationsProvider).isEnglish,
          isFinalChallenge: widget.isFinalChallenge,
        ),
      ),
    ),
  );

  Future<void> _drainWordPhotos() async {
    if (_wordPhotoOpen || !mounted) return;
    _wordPhotoOpen = true;
    try {
      while (mounted && _pendingWordPhotos.isNotEmpty) {
        await _showWordPhoto(_pendingWordPhotos.removeAt(0));
      }
      if (mounted && _pendingCompletion != null) {
        final completion = _pendingCompletion!;
        _pendingCompletion = null;
        _showCompletionDialog(completion);
      }
    } finally {
      _wordPhotoOpen = false;
    }
  }

  void _showCompletionDialog(GameplayState state) {
    final loc = ref.read(localizationsProvider);
    final regionName = loc.isEnglish
        ? (state.region?.designation ?? state.region?.name ?? 'Region')
        : (state.region?.name ?? 'Rehiyon');
    final hasNext =
        _isCompletionPreview ||
        ref.read(gameplayProvider.notifier).hasNextLevel;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Color(0xFFF0BDD5)),
          ),
          content: DecoratedBox(
            key: const Key('completion_pastel_background'),
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -.3),
                radius: 1.1,
                colors: [
                  Color(0xFFFFF8ED),
                  Color(0xFFDDF3FF),
                  Color(0xFFFFDDEB),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      state.isFinalChallenge
                          ? loc.isEnglish
                                ? 'Final Challenge Complete!'
                                : 'Tapos na ang Panghuling Hamon!'
                          : loc.congratulations,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textNavy,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BayanitoMascotWidget(
                        size: 90,
                        expression: MascotExpression.celebrating,
                        animated: false,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.isFinalChallenge
                            ? loc.isEnglish
                                  ? 'You found all 15 mixed-region words!'
                                  : 'Nahanap mo ang 15 salita mula sa iba’t ibang rehiyon!'
                            : loc.completedMessage(regionName),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.65, end: 1),
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : Duration(milliseconds: 300 + index * 140),
                            builder: (_, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Icon(
                              index < state.starsEarned
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFFFB300),
                              size: 42,
                            ),
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
                            Flexible(
                              child: Text(
                                loc.rewardCoins(20, state.coins),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
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
                        if (_isCompletionPreview) return;
                        Navigator.pop(context); // Return to Region Selection
                      },
                      child: Text(
                        state.isFinalChallenge
                            ? loc.isEnglish
                                  ? 'Back to challenge'
                                  : 'Bumalik sa hamon'
                            : loc.backToRegionsButton,
                      ),
                    ),
                  ),
                  if (hasNext) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
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
                          if (_isCompletionPreview) return;
                          final nextRegion = ref
                              .read(gameplayProvider.notifier)
                              .getNextRegion();
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
                    ),
                  ],
                  if (!state.isFinalChallenge && !_isCompletionPreview)
                    Consumer(
                      builder: (context, ref, _) =>
                          ref.watch(finalChallengeUnlockedProvider)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: FilledButton.icon(
                                key: const Key('button_open_final_challenge'),
                                icon: const Icon(Icons.emoji_events_rounded),
                                label: Text(
                                  loc.isEnglish
                                      ? 'Final Mixed-Region Challenge'
                                      : 'Panghuling Hamon ng mga Rehiyon',
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRouter.finalChallenge,
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompletionPreview) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFDDEB),
        body: Center(
          child: FilledButton(
            onPressed: _showPreview,
            child: const Text('Preview Level Complete — sample data only'),
          ),
        ),
      );
    }
    final gameState = ref.watch(gameplayProvider);
    final loc = ref.watch(localizationsProvider);

    ref.listen<GameplayState>(gameplayProvider, (prev, next) {
      // Emit from the accepted state transition, never from rebuilds or drags.
      // The final discovery also sparkles before the completion dialog opens.
      if (prev != null &&
          prev.status == GameStatus.playing &&
          prev.region?.id == next.region?.id &&
          next.foundWords.difference(prev.foundWords).isNotEmpty &&
          ref.read(settingsProvider).isSoundEffectsEnabled) {
        ref
            .read(audioServiceProvider)
            .playSoundEffect(AppConstants.audioSfxWordFound);
      }
      if (prev?.status != GameStatus.completed &&
          next.status == GameStatus.completed) {
        _pendingCompletion = next;
      }
      if (prev != null &&
          prev.status == GameStatus.playing &&
          prev.isFinalChallenge == next.isFinalChallenge &&
          prev.region?.id == next.region?.id) {
        final discovered = next.foundWords.difference(prev.foundWords);
        _pendingWordPhotos.addAll(
          next.targetWords.where((word) => discovered.contains(word.word)),
        );
      }
      if (_pendingWordPhotos.isNotEmpty || _pendingCompletion != null) {
        _drainWordPhotos();
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
                  onPressed: () {
                    if (widget.isFinalChallenge) {
                      ref.read(gameplayProvider.notifier).initFinalChallenge();
                    } else {
                      ref
                          .read(gameplayProvider.notifier)
                          .initGame(widget.regionId);
                    }
                  },
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

    final primaryTitle = gameState.isFinalChallenge
        ? loc.isEnglish
              ? 'Final Challenge'
              : 'Panghuling Hamon'
        : loc.isEnglish
        ? (gameState.region?.designation ??
              gameState.region?.name ??
              'Word Search')
        : (gameState.region?.name ?? 'Word Search');
    final secondaryTitle = gameState.isFinalChallenge
        ? loc.isEnglish
              ? '15 mixed words'
              : '15 halong salita'
        : loc.isEnglish
        ? (gameState.region?.name ?? '')
        : (gameState.region?.designation ?? '');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: gameState.isFinalChallenge
            ? RehiyoniaAdventureBackground.sky
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              primaryTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textNavy,
              ),
            ),
            if (secondaryTitle.isNotEmpty)
              Text(
                secondaryTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedSlate,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: ExplorerStrings(loc.isEnglish)('help'),
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => HowToPlayDialog(
                title: ExplorerStrings(loc.isEnglish)('help'),
                instructions: gameState.isFinalChallenge
                    ? loc.isEnglish
                          ? 'Find the 15 words listed below the grid. The list mixes places and landmarks with words learned from regional trivia, such as festivals, crafts, and traditions. Each discovery automatically opens its matching photo and travel fact.'
                          : 'Hanapin ang 15 salita sa listahan. Halo ang mga lugar at mga salitang natutuhan sa trivia tungkol sa mga pista, likhang-sining, at tradisyon. Awtomatikong lalabas ang tamang larawan at kaalaman kapag nahanap ang salita.'
                    : ExplorerStrings(loc.isEnglish)('helpText'),
                closeLabel: loc.closeButton,
              ),
            ),
          ),
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
      body: _withFinalBackground(
        finalChallenge: gameState.isFinalChallenge,
        child: SafeArea(
          child: Column(
            children: [
              // Status bar (Grid size, Found count, Hint button)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
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

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    end:
                        gameState.foundWords.length / puzzle.placedWords.length,
                  ),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 240),
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: gameState.isFinalChallenge ? 200 : 160,
                ),
                child: SingleChildScrollView(
                  child: WordListBar(
                    words: gameState.targetWords,
                    foundWords: gameState.foundWords,
                    onWordClueTap: _showClueModal,
                    allowUnfoundClues: !gameState.isFinalChallenge,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _withFinalBackground({
    required bool finalChallenge,
    required Widget child,
  }) => finalChallenge ? RehiyoniaAdventureBackground(child: child) : child;
}
