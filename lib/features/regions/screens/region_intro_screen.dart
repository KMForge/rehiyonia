import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../../shared/widgets/explorer_card.dart';
import '../../../shared/widgets/journey_landscape.dart';
import '../../mascot/widgets/bayanito_mascot_widget.dart';
import '../providers/region_provider.dart';

class RegionIntroScreen extends ConsumerWidget {
  const RegionIntroScreen({super.key, required this.regionId});
  final int regionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    return Scaffold(
      appBar: AppBar(title: Text(loc.regionIntroTitle)),
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
              final region = regions.where((r) => r.id == regionId).firstOrNull;
              if (region == null) {
                return Center(child: Text(loc.errorLoadingRegions));
              }
              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    JourneyLandscape(
                      group: region.islandGroup,
                      height: 180,
                      child: const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: BayanitoMascotWidget(
                            size: 95,
                            animated: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      region.islandGroup.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.isEnglish ? region.designation : region.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(loc.isEnglish ? region.name : region.designation),
                    const SizedBox(height: 24),
                    ExplorerCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_stories_rounded),
                          const SizedBox(height: 12),
                          Text(
                            loc.culturalHighlights,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            region.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.localitiesToExplore,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('button_start_learning'),
                      onPressed: region.isUnlocked
                          ? () => Navigator.pushNamed(
                              context,
                              AppRouter.localityCards,
                              arguments: region.id,
                            )
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(loc.startLearningButton),
                    ),
                    if (!region.isUnlocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(ui('locked')),
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
