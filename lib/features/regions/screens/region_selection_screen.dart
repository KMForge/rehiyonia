import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/region.dart';
import '../providers/region_provider.dart';

class RegionSelectionScreen extends ConsumerStatefulWidget {
  const RegionSelectionScreen({super.key, this.initialGroup});

  final String? initialGroup;

  @override
  ConsumerState<RegionSelectionScreen> createState() =>
      _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends ConsumerState<RegionSelectionScreen> {
  String _selectedGroup = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.initialGroup != null) {
      _selectedGroup = widget.initialGroup!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(regionsProvider);
    final loc = ref.watch(localizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.regionsTitle)),
      body: regionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.deepBlue),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('${loc.errorLoadingRegions}: $err'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(regionsProvider),
                child: Text(loc.retryButton),
              ),
            ],
          ),
        ),
        data: (regions) {
          final filterOptions = ['All', 'Luzon', 'Visayas', 'Mindanao'];

          final filteredRegions = _selectedGroup == 'All'
              ? regions
              : regions.where((r) => r.islandGroup == _selectedGroup).toList();

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Island Group Tab Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: filterOptions.map((opt) {
                      final isSelected = _selectedGroup == opt;
                      String label = opt;
                      if (opt == 'Visayas') {
                        label = loc.visayasTitle;
                      } else if (opt == 'All') {
                        label = loc.isEnglish ? 'All (18)' : 'Lahat (18)';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: AppColors.deepBlue,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textNavy,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.deepBlue
                                  : AppColors.babyBlue,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() => _selectedGroup = opt);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Regions List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredRegions.length,
                    itemBuilder: (context, index) {
                      final region = filteredRegions[index];
                      return _RegionCard(region: region, loc: loc);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({required this.region, required this.loc});

  final Region region;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show English designation primarily if English, Filipino name primarily if Tagalog
    final primaryTitle = loc.isEnglish ? region.designation : region.name;
    final secondarySubtitle = loc.isEnglish ? region.name : region.designation;

    return Card(
      elevation: region.isUnlocked ? 2 : 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: region.isUnlocked
              ? AppColors.babyBlue.withValues(alpha: 0.6)
              : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: region.isUnlocked
              ? AppColors.babyBlue.withValues(alpha: 0.5)
              : const Color(0xFFF1F5F9),
          child: Icon(
            region.isUnlocked ? Icons.explore_rounded : Icons.lock_rounded,
            color: region.isUnlocked
                ? AppColors.deepBlue
                : const Color(0xFF94A3B8),
          ),
        ),
        title: Text(
          primaryTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: region.isUnlocked
                ? AppColors.textNavy
                : const Color(0xFF94A3B8),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              secondarySubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedSlate,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              region.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textNavy,
              ),
            ),
          ],
        ),
        trailing: region.isUnlocked
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB300),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${region.starsEarned}/3',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textNavy,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8)),
        onTap: region.isUnlocked
            ? () {
                Navigator.pushNamed(
                  context,
                  AppRouter.regionIntro,
                  arguments: region.id,
                );
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.regionLockedMessage),
                    backgroundColor: AppColors.deepBlue,
                  ),
                );
              },
      ),
    );
  }
}
