import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../regions/providers/region_provider.dart';

class BadgeGalleryScreen extends ConsumerWidget {
  const BadgeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final regionsAsync = ref.watch(regionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.badgeGalleryTitle)),
      body: regionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.deepBlue),
        ),
        error: (err, stack) => Center(child: Text(loc.errorLoadingRegions)),
        data: (regions) {
          final earnedCount = regions
              .where((r) => r.isUnlocked && r.starsEarned > 0)
              .length;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Header Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.babyBlue, AppColors.softLavender],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.military_tech_rounded,
                        size: 48,
                        color: Color(0xFFE65100),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.badgesEarned(earnedCount, regions.length),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: regions.isEmpty
                              ? 0
                              : earnedCount / regions.length,
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          color: AppColors.deepBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Badges Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    final isEarned =
                        region.isUnlocked && region.starsEarned > 0;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isEarned
                            ? Colors.white
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isEarned
                              ? AppColors.babyBlue
                              : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                        boxShadow: isEarned
                            ? [
                                BoxShadow(
                                  color: AppColors.deepBlue.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isEarned
                                  ? const Color(0xFFFFF8E1)
                                  : const Color(0xFFE2E8F0),
                              border: Border.all(
                                color: isEarned
                                    ? const Color(0xFFFFD54F)
                                    : const Color(0xFF94A3B8),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isEarned
                                  ? Icons.workspace_premium_rounded
                                  : Icons.lock_outline_rounded,
                              size: 30,
                              color: isEarned
                                  ? const Color(0xFFFFA000)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            region.code,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isEarned
                                  ? AppColors.textNavy
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            region.designation,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isEarned
                                  ? AppColors.mutedSlate
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (isEarned)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (s) => Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: s < region.starsEarned
                                      ? const Color(0xFFFFB300)
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                            )
                          else
                            Text(
                              loc.lockedBadge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
