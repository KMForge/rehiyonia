import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rehiyonia_adventure_background.dart';
import '../models/locality_photo_credit.dart';
import '../../features/badges/region_landmark.dart';
import '../../features/regions/providers/region_provider.dart';
import '../../features/word_search/models/regional_word.dart';
import '../../features/final_challenge/final_challenge_catalog.dart';
import '../../features/final_challenge/final_challenge_provider.dart';

final discoveryImageAssetsProvider = FutureProvider(
  (ref) async =>
      (await AssetManifest.loadFromAssetBundle(rootBundle))
          .listAssets()
          .toSet(),
);

/// Shown only after a successful discovery; opening it never awards rewards.
class WordDiscoveryContent extends ConsumerWidget {
  const WordDiscoveryContent({
    super.key,
    required this.word,
    required this.english,
    this.isFinalChallenge = false,
  });
  final RegionalWord word;
  final bool english;
  final bool isFinalChallenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTriviaWord = word.category == 'Trivia';
    final localityCredit = !isFinalChallenge
        ? ref
              .watch(localityPhotoCreditsProvider)
              .asData
              ?.value['${word.regionId}:${word.word}']
        : null;
    final photoPanel = !isFinalChallenge
        ? localityCredit != null
              ? _photo(
                  localityCredit.assetPath,
                  english
                      ? localityCredit.caption
                      : (localityCredit.captionFil ?? localityCredit.caption),
                  localityCredit.credit,
                )
              : ref
                    .watch(discoveryImageAssetsProvider)
                    .when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) =>
                          _regionalPhoto(ref, localityFallback: true),
                      data: (assets) => assets.contains(word.resolvedImagePath)
                          ? _photo(
                              word.resolvedImagePath,
                              english
                                  ? word.displayNameEn
                                  : word.displayNameFil,
                              word.word == 'SANJUAN' && word.regionId == 1
                                  ? {
                                      'author':
                                          'Philippine Department of Tourism',
                                      'license': 'Source attribution',
                                      'source_url': 'https://cms-bmco.dmtlph.com/destination/national-capital-region/san-juan/',
                                      'license_url': '',
                                      'modifications': 'Existing bundled locality photograph.',
                                    }
                                  : null,
                            )
                          : _regionalPhoto(ref, localityFallback: true),
                    )
        : isTriviaWord
        ? ref
              .watch(finalTriviaPhotoCreditsProvider)
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => TextButton(
                  onPressed: () =>
                      ref.invalidate(finalTriviaPhotoCreditsProvider),
                  child: Text(english ? 'Retry photo' : 'Subukan muli'),
                ),
                data: (credits) {
                  final entry = finalTriviaWords.firstWhere(
                    (entry) => entry.regionId == word.regionId,
                  );
                  return _photo(
                    entry.imagePath!,
                    english ? entry.captionEn! : entry.captionFil!,
                    credits[entry.imagePath]!,
                  );
                },
              )
        : _regionalPhoto(ref);
    final region = defaultPhilippineRegions.firstWhere(
      (r) => r.id == word.regionId,
    );
    return RehiyoniaAdventureBackground(
      key: const Key('final_discovery_popup'),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      english ? 'Word found!' : 'Nahanap ang salita!',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        color: RehiyoniaAdventureBackground.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: english ? 'Close' : 'Isara',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                word.word,
                key: const Key('final_discovered_word'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: RehiyoniaAdventureBackground.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(region.designation, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              photoPanel,
              const SizedBox(height: 12),
              Text(
                english ? 'Travel trivia' : 'Trivia sa paglalakbay',
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                english ? word.displayFactEn : word.displayFactFil,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: FilledButton(
                  key: const Key('continue_final_discovery'),
                  style:
                      FilledButton.styleFrom(
                        backgroundColor: RehiyoniaAdventureBackground.mauve,
                        foregroundColor: RehiyoniaAdventureBackground.ink,
                        minimumSize: const Size(0, 48),
                      ).copyWith(
                        backgroundBuilder:
                            RehiyoniaAdventureBackground.glossyMauve,
                      ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(english ? 'Continue' : 'Magpatuloy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _regionalPhoto(WidgetRef ref, {bool localityFallback = false}) => ref
      .watch(regionLandmarksProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => TextButton(
          onPressed: () => ref.invalidate(regionLandmarksProvider),
          child: Text(english ? 'Retry photo' : 'Subukan muli'),
        ),
        data: (photos) {
          final photo = photos[word.regionId]!;
          final caption = localityFallback
              ? english
                    ? 'Regional landmark: ${photo.name}. A photo of ${word.displayNameEn} is not bundled.'
                    : 'Palatandaan ng rehiyon: ${photo.name}. Walang kasamang larawan ng ${word.displayNameFil}.'
              : '${photo.name} · ${photo.location}';
          return _photo(photo.assetPath, caption, {
            'author': photo.author,
            'license': photo.license,
            'source_url': photo.sourceUrl,
            'license_url': photo.licenseUrl,
            'modifications': photo.modifications,
          });
        },
      );

  Widget _photo(String asset, String caption, Map<String, dynamic>? credit) =>
      Column(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                asset,
                key: ValueKey('final_discovery_photo_${word.regionId}'),
                height: 150,
                fit: BoxFit.contain,
                cacheWidth: 720,
                semanticLabel: caption,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (credit != null)
            ExpansionTile(
              title: Text(english ? 'Photo credits' : 'Pagkilala sa larawan'),
              childrenPadding: const EdgeInsets.all(12),
              children: [
                if (credit['title'] != null) Text(credit['title'] as String),
                Text('${credit['author']} · ${credit['license']}'),
                SelectableText(credit['source_url'] as String),
                if (credit['original_source_url'] != null)
                  SelectableText(credit['original_source_url'] as String),
                if ((credit['license_url'] as String? ?? '').isNotEmpty)
                  SelectableText(credit['license_url'] as String),
                Text(credit['modifications'] as String? ?? ''),
              ],
            ),
        ],
      );
}
