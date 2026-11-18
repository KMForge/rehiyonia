import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Offline, flower-free scenery shared by exploration and trivia.
/// Sizes to its child, so it also works inside a scrolling trivia dialog.
class RehiyoniaAdventureBackground extends StatelessWidget {
  const RehiyoniaAdventureBackground({super.key, required this.child});

  static const sky = Color(0xFF9EBBD5);
  static const periwinkle = Color(0xFFD5D9EC);
  static const champagne = Color(0xFFF1D8B8);
  static const cream = Color(0xFFFFF5E8);
  static const peach = Color(0xFFF8DCD5);
  static const mauve = Color(0xFFA67C96);
  static const ink = Color(0xFF43205A);

  final Widget child;

  /// Keeps the button's own ink effects, focus behavior, and disabled state.
  static Widget glossyMauve(
    BuildContext context,
    Set<WidgetState> states,
    Widget? child,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: states.contains(WidgetState.disabled)
          ? null
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0C9D8), Color(0xFFC5A1B9)],
              stops: [0, .65],
            ),
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [sky, periwinkle, cream, champagne, peach, periwinkle],
        stops: [0, .24, .47, .68, .87, 1],
      ),
    ),
    child: CustomPaint(painter: const _AdventureSceneryPainter(), child: child),
  );
}

/// Paint-only decoration: no semantics, touch targets, assets, or animation.
class _AdventureSceneryPainter extends CustomPainter {
  const _AdventureSceneryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final w = size.width;
    final h = size.height;
    final scale = math.min(w / 390, 1.4);

    _cloud(canvas, Offset(w * .13, 24 * scale), .75 * scale);
    _cloud(canvas, Offset(w * .85, h * .27), .6 * scale);
    _palm(canvas, Offset(-7, 8), scale, false);
    _palm(canvas, Offset(w + 7, 6), scale, true);

    final mountains = Path()
      ..moveTo(0, h * .7)
      ..lineTo(w * .18, h * .52)
      ..lineTo(w * .29, h * .63)
      ..lineTo(w * .46, h * .46)
      ..lineTo(w * .7, h * .68)
      ..lineTo(w * .88, h * .55)
      ..lineTo(w, h * .65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(mountains, Paint()..color = const Color(0x239EBBD5));

    for (var layer = 0; layer < 2; layer++) {
      final base = h - (layer == 0 ? 72 : 25) * scale;
      final hills = Path()
        ..moveTo(0, base)
        ..cubicTo(
          w * .2,
          base - 95 * scale,
          w * .3,
          base + 26 * scale,
          w * .55,
          base - 12 * scale,
        )
        ..quadraticBezierTo(w * .8, base - 70 * scale, w, base - 14 * scale)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        hills,
        Paint()
          ..color = layer == 0
              ? const Color(0x339EBBD5)
              : const Color(0x33AFA6C5),
      );
    }

    final route = Path()
      ..moveTo(w - 12 * scale, h * .76)
      ..cubicTo(
        w - 65 * scale,
        h * .67,
        w + 15 * scale,
        h * .58,
        w - 25 * scale,
        h * .41,
      );
    final dots = Paint()
      ..color = const Color(0xBBFFFFFF)
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final metric in route.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 9 * scale) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 2 * scale, metric.length)),
          dots,
        );
      }
    }
    canvas.save();
    canvas.translate(w - 25 * scale, h * .41);
    canvas.scale(scale);
    canvas.drawPath(
      Path()
        ..moveTo(0, -14)
        ..lineTo(-10, 10)
        ..lineTo(0, 5)
        ..lineTo(9, 11)
        ..close(),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    canvas.drawLine(
      const Offset(0, -10),
      const Offset(0, 5),
      Paint()
        ..color = const Color(0x779EBBD5)
        ..strokeWidth = 1,
    );
    canvas.restore();
    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset center, double scale) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    final paint = Paint()..color = const Color(0x99FFFFFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, 0, 60, 15),
        const Radius.circular(8),
      ),
      paint,
    );
    canvas.drawCircle(const Offset(-10, 0), 12, paint);
    canvas.drawCircle(const Offset(9, -3), 16, paint);
    canvas.restore();
  }

  void _palm(Canvas canvas, Offset origin, double scale, bool mirror) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(mirror ? -scale : scale, scale);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(20, 8, 35, 62),
      Paint()
        ..color = const Color(0x559AAEAA)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    for (var i = 0; i < 5; i++) {
      final y = 7.0 + i * 9;
      final x = 5.0 + i * 4;
      for (final side in [-1, 1]) {
        final tip = Offset(x + (side == 1 ? 24 : -15), y + 20);
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(tip.dx, y, tip.dx, tip.dy)
            ..quadraticBezierTo(x + side * 3, y + 9, x, y)
            ..close(),
          Paint()..color = const Color(0x449AAEAA),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AdventureSceneryPainter oldDelegate) => false;
}
