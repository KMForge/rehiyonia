import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../word_search/models/regional_word.dart';
import '../../word_search/providers/word_provider.dart';

class LocalityLearningCardsScreen extends ConsumerStatefulWidget {
  const LocalityLearningCardsScreen({super.key, required this.regionId});

  final int regionId;

  @override
  ConsumerState<LocalityLearningCardsScreen> createState() =>
      _LocalityLearningCardsScreenState();
}

class _LocalityLearningCardsScreenState
    extends ConsumerState<LocalityLearningCardsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationsProvider);
    final wordsAsync = ref.watch(wordsForRegionProvider(widget.regionId));

    return Scaffold(
      appBar: AppBar(title: Text(loc.localityCardsTitle)),
      body: wordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.deepBlue),
        ),
        error: (err, stack) => Center(child: Text(loc.errorLoadingRegions)),
        data: (localities) {
          if (localities.isEmpty) {
            return const Center(child: Text('No localities found.'));
          }

          final total = localities.length;
          final isLastPage = _currentPage == total - 1;

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Top Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.cardProgress(_currentPage + 1, total),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textNavy,
                        ),
                      ),
                      Text(
                        '${((_currentPage + 1) / total * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / total,
                      minHeight: 8,
                      backgroundColor: AppColors.babyBlue.withValues(
                        alpha: 0.3,
                      ),
                      color: AppColors.deepBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Swiping Card View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: total,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    itemBuilder: (context, index) {
                      final item = localities[index];
                      return _buildLocalityCard(item, loc);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Navigation Controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Previous Button
                      if (_currentPage > 0)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.deepBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: Text(loc.previousCard),
                        )
                      else
                        const SizedBox.shrink(),

                      const Spacer(),

                      // Next / Trivia Challenge Button
                      FilledButton.icon(
                        key: const Key('button_next_or_trivia'),
                        style: FilledButton.styleFrom(
                          backgroundColor: isLastPage
                              ? const Color(0xFF2E7D32)
                              : AppColors.deepBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          if (isLastPage) {
                            Navigator.pushNamed(
                              context,
                              AppRouter.triviaChallenge,
                              arguments: widget.regionId,
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        icon: Icon(
                          isLastPage
                              ? Icons.quiz_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(
                          isLastPage ? loc.takeTriviaButton : loc.nextCard,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocalityCard(RegionalWord item, AppLocalizations loc) {
    final title = loc.isEnglish ? item.displayNameEn : item.displayNameFil;
    final province = loc.isEnglish
        ? (item.provinceEn?.isNotEmpty == true ? item.provinceEn! : '')
        : (item.provinceFil?.isNotEmpty == true ? item.provinceFil! : '');
    final description = loc.isEnglish
        ? item.displayClueEn
        : item.displayClueFil;
    final funFact = loc.isEnglish ? item.displayFactEn : item.displayFactFil;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.babyBlue.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Landmark Photo with Keyword Overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: AppColors.babyBlue.withValues(alpha: 0.2),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item.resolvedImagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.babyBlue.withValues(alpha: 0.4),
                                  AppColors.softLavender.withValues(alpha: 0.4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.landscape_rounded,
                                    size: 48,
                                    color: AppColors.deepBlue.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepBlue,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Top Right: Word Search Target Badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                size: 14,
                                color: AppColors.deepBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.word,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.deepBlue,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Locality Name
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textNavy,
                ),
              ),

              const SizedBox(height: 8),

              // Category & Province Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pastelPink.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loc.categoryLabel(item.category),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textNavy,
                      ),
                    ),
                  ),
                  if (province.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        province,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textNavy,
                        ),
                      ),
                    ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, thickness: 1, color: Color(0xFFE8EEF4)),
              ),

              // Educational Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textNavy,
                ),
              ),

              const SizedBox(height: 16),

              // Distinct "Did You Know? / Alam Ba Ninyo?" Trivia Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFDE7), Color(0xFFFFF8E1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFECB3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFFFA000),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.funFactLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            funFact,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: AppColors.textNavy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
