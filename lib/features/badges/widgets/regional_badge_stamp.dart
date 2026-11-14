import 'package:flutter/material.dart';

import '../region_landmark.dart';

class LandmarkPhoto extends StatelessWidget {
  const LandmarkPhoto({
    super.key,
    required this.landmark,
    required this.earned,
    this.fit = BoxFit.cover,
    this.decodeWidth = 400,
  });
  final RegionLandmark landmark;
  final bool earned;
  final BoxFit fit;
  final int decodeWidth;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      landmark.assetPath,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: decodeWidth,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => Semantics(
        label: 'Photo unavailable: ${landmark.name}',
        child: const ColoredBox(
          color: Color(0xFFFFF2E4),
          child: Center(
            child: Icon(Icons.broken_image_outlined, color: Color(0xFF96225B)),
          ),
        ),
      ),
    );
    if (earned) return image;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        .56693,
        .39336,
        .03971,
        0,
        0,
        .11693,
        .84336,
        .03971,
        0,
        0,
        .11693,
        .39336,
        .48971,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: image,
    );
  }
}

/// The same locally bundled photo is used by the stamp and card background.
class RegionalBadgeStamp extends StatelessWidget {
  const RegionalBadgeStamp({
    super.key,
    required this.landmark,
    required this.earned,
    this.width = 96,
  });
  final RegionLandmark landmark;
  final bool earned;
  final double width;
  String get regionCode => landmark.regionCode;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: width * 1.2,
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            foregroundPainter: _PostageBorder(earned),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x227B536E),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LandmarkPhoto(landmark: landmark, earned: earned),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: earned ? const Color(0xFFC58A26) : const Color(0xFFE83F8D),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              earned ? Icons.star_rounded : Icons.lock_rounded,
              size: 17,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PostageBorder extends CustomPainter {
  const _PostageBorder(this.earned);
  final bool earned;
  @override
  void paint(Canvas canvas, Size size) {
    final outline = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1),
      const Radius.circular(12),
    );
    final color = earned ? const Color(0xFFE6B24D) : const Color(0xFF9DCDE6);
    canvas.drawRRect(
      outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(4),
          const Radius.circular(9),
        ),
      );
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 6) {
        canvas.drawCircle(
          metric.getTangentForOffset(distance)!.position,
          .6,
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PostageBorder oldDelegate) =>
      oldDelegate.earned != earned;
}
