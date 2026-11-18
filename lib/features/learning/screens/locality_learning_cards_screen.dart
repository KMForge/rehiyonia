import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/rehiyonia_adventure_background.dart';
import '../../../core/theme/app_colors.dart';
import '../../word_search/models/regional_word.dart';
import '../../word_search/providers/word_provider.dart';
import '../../../shared/widgets/locality_photo.dart';

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
      backgroundColor: RehiyoniaAdventureBackground.cream,
      appBar: AppBar(
        backgroundColor: RehiyoniaAdventureBackground.sky,
        surfaceTintColor: Colors.transparent,
        foregroundColor: RehiyoniaAdventureBackground.ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.localityCardsTitle,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RehiyoniaAdventureBackground(
        child: SizedBox.expand(
          child: wordsAsync.when(
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Top Progress indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  loc.cardProgress(_currentPage + 1, total),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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

                        _buildNavigation(loc, isLastPage),
                      ],
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

  Widget _buildNavigation(AppLocalizations loc, bool isLastPage) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 168),
            child: OutlinedButton.icon(
              key: const Key('button_previous_locality'),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEAF2),
                foregroundColor: AppColors.textNavy,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                side: const BorderSide(color: Color(0xFFEDB6CF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _currentPage == 0
                  ? null
                  : () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                loc.previousCard,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 168),
            child: FilledButton.icon(
              key: const Key('button_next_or_trivia'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.babyBlue,
                foregroundColor: AppColors.textNavy,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
                isLastPage ? Icons.quiz_rounded : Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(
                isLastPage ? loc.takeTriviaButton : loc.nextCard,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

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
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5E7D7),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFFE1C5A8), width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Landmark Photo with Keyword Overlay
                Center(
                  child: Container(
                    key: ValueKey('locality_photo_frame_${item.word}'),
                    constraints: const BoxConstraints(maxWidth: 320),
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD6B493)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x145B3B27),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 160,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            LocalityPhoto(locality: item),
                            // Top Right: Word Search Target Badge
                            Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
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
                                      Flexible(
                                        child: Text(
                                          item.word,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.deepBlue,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Locality Name
                if (item.word == 'SANJUAN' && item.regionId == 1)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Museo ng Katipunan • Photo: Department of Tourism',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedSlate,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
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
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE8EEF4),
                  ),
                ),

                // Educational Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textNavy,
                  ),
                ),

                const SizedBox(height: 16),

                // Distinct "Did You Know? / Alam Ba Ninyo?" Trivia Card
                Container(
                  padding: const EdgeInsets.all(12),
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
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFECB3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFFFFA000),
                          size: 20,
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
                                fontSize: 13,
                                height: 1.4,
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
      ),
    );
  }
}
