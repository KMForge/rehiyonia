import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/word_search/models/regional_word.dart';
import '../models/locality_photo_credit.dart';
import '../../core/localization/app_localizations.dart';

class LocalityPhoto extends ConsumerWidget {
  const LocalityPhoto({super.key, required this.locality});
  final RegionalWord locality;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final english = ref.watch(localizationsProvider).isEnglish;
    final credit = ref
        .watch(localityPhotoCreditsProvider)
        .asData
        ?.value['${locality.regionId}:${locality.word}'];
    final photo = Image.asset(
      credit?.assetPath ?? locality.resolvedImagePath,
      fit: BoxFit.cover,
      semanticLabel: locality.displayNameEn,
      errorBuilder: (_, _, _) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/localities/${locality.regionId <= 8
                ? 'banaue'
                : [9, 10, 11, 18].contains(locality.regionId)
                ? 'cebu'
                : 'davao'}.jpg',
            fit: BoxFit.cover,
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColoredBox(
              color: Color(0xCC16324F),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  'Regional scenery • Tanawin ng pangkat ng isla',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (credit == null) return photo;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        photo,
        Positioned(
          left: 4,
          bottom: 4,
          child: IconButton.filledTonal(
            tooltip: english ? 'Photo credits' : 'Pagkilala sa larawan',
            icon: const Icon(Icons.info_outline, size: 18),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                scrollable: true,
                title: Text(credit.caption),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(credit.title),
                    Text('${credit.author} · ${credit.license}'),
                    const SizedBox(height: 8),
                    SelectableText(credit.sourceUrl),
                    if (credit.originalSourceUrl != null)
                      SelectableText(credit.originalSourceUrl!),
                    if (credit.licenseUrl.isNotEmpty)
                      SelectableText(credit.licenseUrl),
                    Text(credit.modifications),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(english ? 'Close' : 'Isara'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
