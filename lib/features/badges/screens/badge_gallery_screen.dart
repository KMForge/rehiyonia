import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/explorer_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../../shared/widgets/explorer_card.dart';
import '../../regions/providers/region_provider.dart';

class BadgeGalleryScreen extends ConsumerWidget {
  const BadgeGalleryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    return Scaffold(
      appBar: AppBar(title: Text(loc.badgeGalleryTitle)),
      body: ref
          .watch(regionsProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(regionsProvider),
                child: Text(ui('retry')),
              ),
            ),
            data: (regions) {
              final earned = regions
                  .where((r) => r.isUnlocked && r.starsEarned > 0)
                  .length;
              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    ExplorerCard(
                      color: const Color(0xFFDDEEE8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_stories_rounded,
                            size: 36,
                            color: ExplorerTheme.teal,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            ui('passport'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(ui('passportHint')),
                          const SizedBox(height: 16),
                          Text(
                            loc.badgesEarned(earned, regions.length),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: regions.isEmpty
                                ? 0
                                : earned / regions.length,
                            borderRadius: BorderRadius.circular(8),
                            minHeight: 7,
                            color: ExplorerTheme.teal,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...regions.map((r) {
                      final unlocked = r.isUnlocked && r.starsEarned > 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExplorerCard(
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: unlocked
                                      ? const Color(0xFFFFEAB8)
                                      : const Color(0xFFEDF1F4),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: unlocked
                                        ? const Color(0xFFCA9D48)
                                        : ExplorerTheme.line,
                                  ),
                                ),
                                child: Icon(
                                  unlocked
                                      ? Icons.military_tech_rounded
                                      : Icons.lock_outline_rounded,
                                  size: 32,
                                  color: unlocked
                                      ? const Color(0xFF855C0D)
                                      : ExplorerTheme.muted,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.isEnglish ? r.designation : r.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    if (unlocked)
                                      Row(
                                        children: List.generate(
                                          3,
                                          (i) => Icon(
                                            i < r.starsEarned
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: const Color(0xFF956600),
                                            size: 20,
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        loc.lockedBadge,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
    );
  }
}
