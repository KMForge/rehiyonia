import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/region_provider.dart';

class IslandGroupSelectionScreen extends ConsumerWidget {
  const IslandGroupSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final regionsAsync = ref.watch(regionsProvider);

    final groups = [
      {
        'name': 'Luzon',
        'title': loc.luzonTitle,
        'color': AppColors.babyBlue,
        'icon': Icons.terrain_rounded,
      },
      {
        'name': 'Visayas',
        'title': loc.visayasTitle,
        'color': AppColors.pastelPink,
        'icon': Icons.sailing_rounded,
      },
      {
        'name': 'Mindanao',
        'title': loc.mindanaoTitle,
        'color': AppColors.softLavender,
        'icon': Icons.forest_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.selectIslandGroup)),
      body: regionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.deepBlue),
        ),
        error: (err, stack) => Center(child: Text(loc.errorLoadingRegions)),
        data: (regions) {
          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupName = group['name'] as String;
                final groupTitle = group['title'] as String;
                final cardColor = group['color'] as Color;
                final icon = group['icon'] as IconData;

                final groupRegions = regions
                    .where((r) => r.islandGroup == groupName)
                    .toList();
                final unlockedCount = groupRegions
                    .where((r) => r.isUnlocked)
                    .length;
                final totalStars = groupRegions.fold<int>(
                  0,
                  (sum, r) => sum + r.starsEarned,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 2,
                    shadowColor: AppColors.deepBlue.withValues(alpha: 0.1),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.regions,
                          arguments: groupName,
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cardColor.withValues(alpha: 0.8),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: AppColors.deepBlue,
                                size: 34,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    groupTitle,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.regionsCount(groupRegions.length),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mutedSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.successMint
                                              .withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '$unlockedCount / ${groupRegions.length} Unlocked',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: Color(0xFFFFB300),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$totalStars',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textNavy,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: AppColors.mutedSlate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
