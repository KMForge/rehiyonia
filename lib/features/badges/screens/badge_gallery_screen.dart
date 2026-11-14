import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../regions/providers/region_provider.dart';
import '../regional_badges.dart';
import '../region_landmark.dart';
import '../widgets/travel_badge_card.dart';

class BadgeGalleryScreen extends ConsumerWidget {
  const BadgeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    final photos = ref.watch(regionLandmarksProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDFF3FF),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF3A174D),
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.badgeGalleryTitle,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDFF3FF), Color(0xFFFFF4E7), Color(0xFFFFD6EB)],
            stops: [0, .4, 1],
          ),
        ),
        child: SafeArea(
          child: ref
              .watch(regionsProvider)
              .when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE44691)),
                ),
                error: (_, _) => Center(
                  child: TextButton.icon(
                    onPressed: () => ref.invalidate(regionsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(ui('retry')),
                  ),
                ),
                data: (savedRegions) {
                  if (photos.hasError) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(regionLandmarksProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(ui('retry')),
                      ),
                    );
                  }
                  final landmarks = photos.asData?.value;
                  if (landmarks == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE44691),
                      ),
                    );
                  }
                  final regions = regionalBadgeRegions(savedRegions);
                  final earned = regions
                      .where(
                        (region) => region.isUnlocked && region.starsEarned > 0,
                      )
                      .length;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 700 ? 3 : 2;
                          return ListView(
                            key: const Key('travel_passport_gallery'),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                            children: [
                              _PassportCover(earned: earned, loc: loc, ui: ui),
                              const SizedBox(height: 26),
                              Text(
                                loc.isEnglish
                                    ? 'Your stamp collection'
                                    : 'Iyong koleksiyon ng mga tsapa',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 25,
                                  color: Color(0xFF3A174D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                loc.isEnglish
                                    ? 'One region. One adventure. One stamp to keep.'
                                    : 'Isang rehiyon. Isang paglalakbay. Isang tsapang aalagaan.',
                                style: const TextStyle(
                                  color: Color(0xFF75627E),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              for (
                                var start = 0;
                                start < regions.length;
                                start += columns
                              )
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        for (
                                          var column = 0;
                                          column < columns;
                                          column++
                                        ) ...[
                                          if (column > 0)
                                            const SizedBox(width: 12),
                                          Expanded(
                                            child:
                                                start + column < regions.length
                                                ? TravelBadgeCard(
                                                    key: ValueKey(
                                                      'regional_badge_${regions[start + column].id}',
                                                    ),
                                                    region:
                                                        regions[start + column],
                                                    loc: loc,
                                                    landmark:
                                                        landmarks[regions[start +
                                                                column]
                                                            .id]!,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                loc.isEnglish
                                    ? 'Made of little discoveries. Filled with big memories.'
                                    : 'Maliliit na tuklas. Malalaking alaala.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF856A80),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}

class _PassportCover extends StatelessWidget {
  const _PassportCover({
    required this.earned,
    required this.loc,
    required this.ui,
  });
  final int earned;
  final AppLocalizations loc;
  final ExplorerStrings ui;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: const _PassportStitches(),
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFCF3), Color(0xFFFFF0E0)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF3B9D2), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x187A547C),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ExcludeSemantics(
                child: SizedBox(
                  width: 64,
                  height: 82,
                  child: CustomPaint(painter: _PassportBookArt()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REHIYONIA',
                      style: const TextStyle(
                        color: Color(0xFFAD3975),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ui('passport'),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 28,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3A174D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ui('passportHint'),
            style: const TextStyle(
              color: Color(0xFF75627E),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loc.badgesEarned(earned, regionalBadgeTotal),
            style: const TextStyle(
              fontFamily: 'Fredoka',
              color: Color(0xFF3A174D),
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: earned / regionalBadgeTotal,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFE44691),
            backgroundColor: const Color(0xFFF1DCE7),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDFEFFB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFB73577),
                  size: 17,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    loc.isEnglish
                        ? '18 regions. A whole country of stories.'
                        : '18 rehiyon. Isang bansang puno ng kuwento.',
                    style: const TextStyle(
                      color: Color(0xFF4B476B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PassportStitches extends CustomPainter {
  const _PassportStitches();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(8),
          const Radius.circular(24),
        ),
      );
    final paint = Paint()
      ..color = const Color(0xFFE7B6CB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 9) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PassportStitches oldDelegate) => false;
}

class _PassportBookArt extends CustomPainter {
  const _PassportBookArt();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-.13);
    final cover = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-27, -36, 54, 72),
      const Radius.circular(7),
    );
    canvas.drawRRect(
      cover.shift(const Offset(3, 3)),
      Paint()..color = const Color(0x22A93E7F),
    );
    canvas.drawRRect(
      cover,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF777B5), Color(0xFFCF287D)],
        ).createShader(cover.outerRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-22, -31, 44, 62),
        const Radius.circular(4),
      ),
      Paint()
        ..color = const Color(0xFFFFE49A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    final gold = Paint()
      ..color = const Color(0xFFFFE49A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(const Offset(0, 3), 16, gold);
    canvas.drawOval(const Rect.fromLTWH(-7, -13, 14, 32), gold);
    canvas.drawOval(const Rect.fromLTWH(-16, -3, 32, 12), gold);
    canvas.drawLine(const Offset(-16, 3), const Offset(16, 3), gold);
    canvas.drawLine(const Offset(-12, -23), const Offset(12, -23), gold);
    canvas.drawLine(const Offset(-8, 26), const Offset(8, 26), gold);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PassportBookArt oldDelegate) => false;
}
