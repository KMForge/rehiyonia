import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/explorer_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../providers/region_provider.dart';

class RegionSelectionScreen extends ConsumerStatefulWidget {
  const RegionSelectionScreen({super.key, this.initialGroup});
  final String? initialGroup;
  @override
  ConsumerState<RegionSelectionScreen> createState() =>
      _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends ConsumerState<RegionSelectionScreen> {
  late String _selected = widget.initialGroup ?? 'All';
  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    return Scaffold(
      appBar: AppBar(title: Text(loc.regionsTitle)),
      body: ref
          .watch(regionsProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: TextButton.icon(
                onPressed: () => ref.invalidate(regionsProvider),
                icon: const Icon(Icons.refresh),
                label: Text(ui('retry')),
              ),
            ),
            data: (regions) {
              final visible = regions
                  .where(
                    (r) => _selected == 'All' || r.islandGroup == _selected,
                  )
                  .toList();
              return SafeArea(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: ['All', 'Luzon', 'Visayas', 'Mindanao']
                            .map(
                              (g) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    g == 'All'
                                        ? '${loc.isEnglish ? 'All' : 'Lahat'} (${regions.length})'
                                        : g,
                                  ),
                                  selected: _selected == g,
                                  onSelected: (_) =>
                                      setState(() => _selected = g),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final r = visible[index];
                          final completed = r.starsEarned > 0;
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => r.isUnlocked
                                  ? Navigator.pushNamed(
                                      context,
                                      AppRouter.regionIntro,
                                      arguments: r.id,
                                    )
                                  : ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ui('locked'))),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: completed
                                            ? const Color(0xFFDFF1E9)
                                            : const Color(0xFFEDF1F4),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        completed
                                            ? Icons.verified_rounded
                                            : r.isUnlocked
                                            ? Icons.explore_rounded
                                            : Icons.lock_outline_rounded,
                                        color: completed
                                            ? ExplorerTheme.teal
                                            : ExplorerTheme.muted,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.islandGroup.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 1.3,
                                              fontWeight: FontWeight.w800,
                                              color: ExplorerTheme.teal,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            loc.isEnglish
                                                ? r.designation
                                                : r.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            loc.isEnglish
                                                ? r.name
                                                : r.designation,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(height: 8),
                                          if (r.isUnlocked)
                                            Wrap(
                                              spacing: 2,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                for (var i = 0; i < 3; i++)
                                                  Icon(
                                                    i < r.starsEarned
                                                        ? Icons.star_rounded
                                                        : Icons
                                                              .star_border_rounded,
                                                    size: 18,
                                                    color: const Color(
                                                      0xFF956600,
                                                    ),
                                                  ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  ui(
                                                    completed
                                                        ? 'completed'
                                                        : 'available',
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            )
                                          else
                                            Text(
                                              ui('locked'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (r.isUnlocked)
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: ExplorerTheme.teal,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
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
