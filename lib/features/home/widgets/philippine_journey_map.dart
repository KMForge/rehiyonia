import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'philippine_coastlines.dart';
import 'home_palette.dart';

/// Decorative coastline map, not an administrative-boundary or navigation map.
abstract final class PhilippineJourneyArt {
  static void paint(
    Canvas canvas,
    Rect bounds, {
    double opacity = 1,
    bool journey = false,
  }) {
    final scale = math.min(bounds.width / 10.4, bounds.height / 17.1);
    final origin = Offset(
      bounds.center.dx - 10.4 * scale / 2,
      bounds.center.dy - 17.1 * scale / 2,
    );
    Offset project(double longitude, double latitude) =>
        origin + Offset((longitude - 116.4) * scale, (21.4 - latitude) * scale);
    for (final island in philippineCoastlines) {
      final path = Path();
      for (var i = 0; i < island.length; i++) {
        final point = project(island[i].dx, island[i].dy);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path.shift(const Offset(1, 2)),
        Paint()
          ..color = const Color(0xFFB58DBD).withValues(alpha: opacity * .4),
      );
      canvas.drawPath(
        path,
        Paint()..color = HomePalette.blue.withValues(alpha: opacity),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = journey ? 1.3 : .8,
      );
    }
    if (!journey) return;
    final points = [
      project(121.1, 16.2),
      project(123.5, 11),
      project(125, 7.9),
    ];
    final route = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..cubicTo(
        points[0].dx - 18,
        points[0].dy + 32,
        points[1].dx - 15,
        points[1].dy - 20,
        points[1].dx,
        points[1].dy,
      )
      ..quadraticBezierTo(
        points[1].dx + 26,
        points[1].dy + 7,
        points[2].dx,
        points[2].dy,
      );
    for (final metric in route.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += 8) {
        canvas.drawPath(
          metric.extractPath(offset, math.min(offset + 4, metric.length)),
          Paint()
            ..color = HomePalette.hotPink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final pin = Path()
        ..moveTo(point.dx, point.dy + 7)
        ..cubicTo(
          point.dx - 4,
          point.dy + 2,
          point.dx - 8,
          point.dy - 1,
          point.dx - 8,
          point.dy - 6,
        )
        ..arcToPoint(
          Offset(point.dx + 8, point.dy - 6),
          radius: const Radius.circular(8),
        )
        ..cubicTo(
          point.dx + 8,
          point.dy - 1,
          point.dx + 4,
          point.dy + 2,
          point.dx,
          point.dy + 7,
        )
        ..close();
      canvas.drawPath(pin, Paint()..color = HomePalette.hotPink);
      canvas.drawPath(
        pin,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(
        point.translate(0, -6),
        2.6,
        Paint()..color = Colors.white,
      );
      final label = TextPainter(
        text: TextSpan(
          text: ['Luzon', 'Visayas', 'Mindanao'][i],
          style: TextStyle(
            color: const Color(0xFF713F72),
            fontSize: bounds.width < 170 ? 10 : 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final position = Offset(
        i == 0 ? point.dx + 9 : point.dx - label.width - 9,
        point.dy - label.height / 2,
      );
      final labelBounds = Rect.fromLTWH(
        position.dx - 4,
        position.dy - 2,
        label.width + 8,
        label.height + 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelBounds, const Radius.circular(6)),
        Paint()..color = Colors.white.withValues(alpha: .86),
      );
      label.paint(canvas, position);
      label.dispose();
    }
  }
}

class PhilippineJourneyMap extends StatelessWidget {
  const PhilippineJourneyMap({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Pilipinas: Luzon, Visayas, Mindanao',
    child: const CustomPaint(
      painter: _JourneyMapPainter(),
      child: SizedBox.expand(),
    ),
  );
}

class _JourneyMapPainter extends CustomPainter {
  const _JourneyMapPainter();
  @override
  void paint(Canvas canvas, Size size) => PhilippineJourneyArt.paint(
    canvas,
    (Offset.zero & size).deflate(5),
    journey: true,
  );
  @override
  bool shouldRepaint(covariant _JourneyMapPainter oldDelegate) => false;
}
