import 'package:flutter/material.dart';

import '../models/regional_word.dart';

class WordListBar extends StatelessWidget {
  const WordListBar({
    super.key,
    required this.words,
    required this.foundWords,
    required this.onWordClueTap,
  });

  final List<RegionalWord> words;
  final Set<String> foundWords;
  final void Function(RegionalWord word) onWordClueTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: words.map((w) {
          final isFound = foundWords.contains(w.word.toUpperCase());

          return InkWell(
            onTap: () => onWordClueTap(w),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFound
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFound
                      ? const Color(0xFF81C784)
                      : const Color(0xFFD1C4E9),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFound)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  Text(
                    w.word,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: isFound ? TextDecoration.lineThrough : null,
                      color: isFound
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF4A148C),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
