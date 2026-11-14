import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../regions/models/region.dart';
import '../regional_badges.dart';
import '../region_landmark.dart';
import 'regional_badge_stamp.dart';

class TravelBadgeCard extends StatelessWidget {
  const TravelBadgeCard({
    super.key,
    required this.region,
    required this.loc,
    required this.landmark,
  });
  final Region region;
  final AppLocalizations loc;
  final RegionLandmark landmark;
  bool get earned => region.isUnlocked && region.starsEarned > 0;
  String get status => earned
      ? (loc.isEnglish ? 'Badge Earned!' : 'Nakuha ang Tsapa!')
      : loc.lockedBadge;
  static const ink = Color(0xFF3A174D);

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x157C537E),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFFFFF2E4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: earned
                ? const Color(0xFFE9B24F)
                : (region.islandGroup == 'Visayas'
                      ? const Color(0xFFBDEBFF)
                      : const Color(0xFFF1BED7)),
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showStamp(context),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: .85,
                        heightFactor: 1,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.transparent, Colors.white],
                            stops: [.1, 1],
                          ).createShader(bounds),
                          child: Opacity(
                            opacity: earned ? .22 : .16,
                            child: LandmarkPhoto(
                              landmark: landmark,
                              earned: earned,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      region.islandGroup.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Color(0xFF75627E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ExcludeSemantics(
                        child: RegionalBadgeStamp(
                          key: ValueKey('regional_stamp_${region.id}'),
                          landmark: landmark,
                          earned: earned,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      regionalBadgeTitle(region, english: loc.isEnglish),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        color: ink,
                        fontSize: 16,
                        height: 1.15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      landmark.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF65516D),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .88),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: earned
                              ? const Color(0xFF9F396D)
                              : const Color(0xFF75627E),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 3; i++)
                          Icon(
                            earned && i < region.starsEarned
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: earned
                                ? const Color(0xFFB7811F)
                                : const Color(0xFFA99CAC),
                            size: 18,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _showStamp(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFFFFF2E4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => SingleChildScrollView(
      key: const Key('regional_badge_details'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8BCCF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: earned
                      ? const Color(0xFFE6B24D)
                      : const Color(0xFFF1BED7),
                  width: 2,
                ),
              ),
              child: AspectRatio(
                aspectRatio: landmark.width / landmark.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LandmarkPhoto(
                    landmark: landmark,
                    earned: earned,
                    fit: BoxFit.contain,
                    decodeWidth: 960,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            landmark.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              color: ink,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${landmark.location} · ${regionalBadgeTitle(region, english: loc.isEnglish)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF685575),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFF96225B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            region.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF685575),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            earned
                ? (loc.isEnglish
                      ? 'A new memory in your Philippine adventure!'
                      : 'Bagong alaala sa iyong paglalakbay sa Pilipinas!')
                : (loc.isEnglish
                      ? 'Complete this region’s word search to collect its stamp.'
                      : 'Tapusin ang word search ng rehiyon upang makuha ang tsapa.'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF685575), height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            '${landmark.author} · ${landmark.license}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF75627E),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          ExpansionTile(
            title: Text(
              loc.isEnglish ? 'Photo credits' : 'Pagkilala sa larawan',
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            children: [
              SelectableText(
                landmark.sourceUrl,
                style: const TextStyle(fontSize: 12, height: 1.5),
              ),
              if (landmark.licenseUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                SelectableText(
                  landmark.licenseUrl,
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                landmark.modifications,
                style: const TextStyle(
                  color: Color(0xFF75627E),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.closeButton),
          ),
        ],
      ),
    ),
  );
}
