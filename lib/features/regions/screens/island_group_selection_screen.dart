import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../../shared/widgets/journey_landscape.dart';
import '../providers/region_provider.dart';

class IslandGroupSelectionScreen extends ConsumerWidget {
  const IslandGroupSelectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    return Scaffold(
      appBar: AppBar(title: Text(loc.selectIslandGroup)),
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
            data: (regions) => SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: ['Luzon', 'Visayas', 'Mindanao'].map((group) {
                  final entries = regions
                      .where((r) => r.islandGroup == group)
                      .toList();
                  final completed = entries
                      .where((r) => r.starsEarned > 0)
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.regions,
                          arguments: group,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            JourneyLandscape(height: 100, group: group),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${loc.regionsCount(entries.length)} · ${ui('completed')}: $completed',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
    );
  }
}
