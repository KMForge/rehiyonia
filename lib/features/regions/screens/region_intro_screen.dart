import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/rehiyonia_adventure_background.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../../shared/widgets/explorer_card.dart';
import '../../badges/region_landmark.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/region_provider.dart';
import '../region_descriptions.dart';
import '../widgets/region_landmark_scene.dart';

class RegionIntroScreen extends ConsumerWidget {
  const RegionIntroScreen({super.key, required this.regionId});
  final int regionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    final photos = ref.watch(regionLandmarksProvider);
    final avatar = ref.watch(
      profileProvider.select((profile) => profile.avatar),
    );
    return Scaffold(
      backgroundColor: RehiyoniaAdventureBackground.cream,
      appBar: AppBar(
        backgroundColor: RehiyoniaAdventureBackground.sky,
        surfaceTintColor: Colors.transparent,
        foregroundColor: RehiyoniaAdventureBackground.ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.regionIntroTitle,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RehiyoniaAdventureBackground(
        child: SizedBox.expand(
          child: ref
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
                  final region = regions
                      .where((r) => r.id == regionId)
                      .firstOrNull;
                  if (region == null) {
                    return Center(child: Text(loc.errorLoadingRegions));
                  }
                  return SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        RegionLandmarkScene(
                          avatar: avatar,
                          landmark: photos.asData?.value[region.id],
                          english: loc.isEnglish,
                          hasError: photos.hasError,
                          onRetry: () =>
                              ref.invalidate(regionLandmarksProvider),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          region.islandGroup.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.isEnglish ? region.designation : region.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontFamily: 'Fredoka',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3A174D),
                                height: 1.2,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ExplorerCard(
                          color: const Color(0xFFF5E7D7),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_stories_rounded,
                                    size: 18,
                                    color: Color(0xFF8F6A49),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      loc.culturalHighlights,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontFamily: 'Fredoka',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                regionDescription(
                                  region,
                                  english: loc.isEnglish,
                                ),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontSize: 14, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: FilledButton.icon(
                              key: const Key('button_start_learning'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFEDE5F2),
                                foregroundColor: const Color(0xFF5D456C),
                                side: const BorderSide(
                                  color: Color(0xFFDDD0E5),
                                ),
                                minimumSize: const Size(0, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: region.isUnlocked
                                  ? () => Navigator.pushNamed(
                                      context,
                                      AppRouter.localityCards,
                                      arguments: region.id,
                                    )
                                  : null,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                loc.startLearningButton,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
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
        ),
      ),
    );
  }
}
