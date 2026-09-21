import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/region.dart';
import '../providers/region_provider.dart';

class RegionSelectionScreen extends ConsumerWidget {
  const RegionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final regionsAsync = ref.watch(regionsProvider);
    final loc = ref.watch(localizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.regionsTitle)),
      body: regionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
          final islandGroups = ['Luzon', 'Visayas', 'Mindanao'];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: islandGroups.length,
            itemBuilder: (context, groupIndex) {
              final groupName = islandGroups[groupIndex];
              final groupRegions = regions
                  .where((r) => r.islandGroup == groupName)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Text(
                      loc.islandGroup(groupName),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...groupRegions.map(
                    (region) => _RegionCard(region: region, loc: loc),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
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
      elevation: region.isUnlocked ? 1.5 : 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: region.isUnlocked
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            region.isUnlocked ? Icons.explore_rounded : Icons.lock_rounded,
            color: region.isUnlocked
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        title: Text(
          primaryTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: region.isUnlocked ? null : theme.colorScheme.outline,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              secondarySubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              region.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: region.isUnlocked
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${region.starsEarned}/3',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : const Icon(Icons.lock_outline_rounded, color: Colors.grey),
        onTap: region.isUnlocked
            ? () {
                Navigator.pushNamed(
                  context,
                  AppRouter.game,
                  arguments: region.id,
                );
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.regionLockedMessage)),
                );
              },
      ),
    );
  }
}
