import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../trivia/providers/trivia_provider.dart';
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameplayProvider.notifier).initGame(widget.regionId);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(gameplayProvider.notifier).tickTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showClueModal(RegionalWord word) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      word.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                word.word,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.clue,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCompletionDialog(GameplayState state) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Center(
            child: Text(
              '🎉 Maligayang Bati!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nahanap mo ang lahat ng salita sa ${state.region?.name ?? 'Rehiyon'}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < state.starsEarned
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 40,
                  );
                }),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+20 Barya (Kabuuan: ${state.coins})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _showTriviaDialog(widget.regionId);
              },
              child: const Text('Basahin ang Trivia'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to Region Selection
              },
              child: const Text('Magpatuloy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTriviaDialog(int regionId) async {
    final triviaRepo = ref.read(triviaRepositoryProvider);
    final triviaList = await triviaRepo.getTriviaForRegion(regionId);
    if (!mounted) return;

    final trivia = triviaList.isNotEmpty ? triviaList.first : null;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text('Alamin Natin! (Trivia)'),
            ],
          ),
          content: trivia == null
              ? const Text('Walang trivia para sa rehiyong ito.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trivia.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sagot: ${trivia.answer}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      trivia.funFact,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Naintindihan ko!'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameplayProvider);

    ref.listen<GameplayState>(gameplayProvider, (prev, next) {
      if (prev?.status != GameStatus.completed &&
          next.status == GameStatus.completed) {
        _timer?.cancel();
        _showCompletionDialog(next);
      }
    });

    if (gameState.status == GameStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (gameState.status == GameStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aberya')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(gameState.errorMessage ?? 'May naganap na aberya.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref
                      .read(gameplayProvider.notifier)
                      .initGame(widget.regionId),
                  child: const Text('Subukan Muli'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final puzzle = gameState.puzzle;
    if (puzzle == null) {
      return const Scaffold(
        body: Center(child: Text('Walang puzzle na mabuo.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gameState.region?.name ?? 'Word Search',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              gameState.region?.designation ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gameState.coins}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(gameState.elapsedSeconds),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Nahanap: ${gameState.foundWords.length} / ${puzzle.placedWords.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: gameState.coins >= 10
                        ? () => ref.read(gameplayProvider.notifier).useHint()
                        : null,
                    icon: const Icon(Icons.lightbulb_outline, size: 16),
                    label: const Text('Hint (-10 🪙)'),
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
