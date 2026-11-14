import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pastel_adventure_background.dart';
import 'home_palette.dart';

class AdventureMenu extends StatelessWidget {
  const AdventureMenu({
    super.key,
    required this.startLabel,
    required this.passportLabel,
    required this.dressLabel,
    required this.regionsLabel,
    required this.onStart,
    required this.onPassport,
    required this.onDress,
    required this.onRegions,
  });
  final String startLabel, passportLabel, dressLabel, regionsLabel;
  final VoidCallback? onStart;
  final VoidCallback onPassport, onDress, onRegions;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        children: [
          GlossyExploreButton(
            key: const Key('menu_play_button'),
            label: startLabel,
            onPressed: onStart,
          ),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _AdventureTile(
                    key: const Key('menu_badge_gallery_button'),
                    label: passportLabel,
                    color: HomePalette.pink,
                    art: _MenuArt.passport,
                    onTap: onPassport,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AdventureTile(
                    key: const Key('menu_avatar_button'),
                    label: dressLabel,
                    color: HomePalette.blue,
                    art: _MenuArt.shirt,
                    onTap: onDress,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AdventureTile(
                    key: const Key('menu_explore_regions_button'),
                    label: regionsLabel,
                    color: HomePalette.yellow,
                    art: _MenuArt.map,
                    onTap: onRegions,
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

enum _MenuArt { passport, shirt, map }

class _AdventureTile extends StatelessWidget {
  const _AdventureTile({
    super.key,
    required this.label,
    required this.color,
    required this.art,
    required this.onTap,
  });
  final String label;
  final Color color;
  final _MenuArt art;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: CandyMenuSurface(
      color: color,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 14),
        child: Column(
          children: [
            ExcludeSemantics(
              child: SizedBox(
                height: 76,
                width: double.infinity,
                child: CustomPaint(painter: _MenuIllustration(art)),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: HomePalette.ink,
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MenuIllustration extends CustomPainter {
  const _MenuIllustration(this.art);
  final _MenuArt art;

  void _outlined(
    Canvas canvas,
    Path path,
    Color color, {
    Color edge = Colors.white,
    double width = 5,
  }) {
    canvas.drawPath(
      path,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  void _sparkle(Canvas canvas, double x, double y, double radius) {
    final path = Path()
      ..moveTo(x, y - radius)
      ..lineTo(x + radius * .3, y - radius * .3)
      ..lineTo(x + radius, y)
      ..lineTo(x + radius * .3, y + radius * .3)
      ..lineTo(x, y + radius)
      ..lineTo(x - radius * .3, y + radius * .3)
      ..lineTo(x - radius, y)
      ..lineTo(x - radius * .3, y - radius * .3)
      ..close();
    _outlined(canvas, path, const Color(0xFFFFD75B), width: 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 100, size.height / 100);
    canvas.save();
    canvas.translate(
      (size.width - 100 * scale) / 2,
      (size.height - 100 * scale) / 2,
    );
    canvas.scale(scale);
    switch (art) {
      case _MenuArt.passport:
        _passport(canvas);
      case _MenuArt.shirt:
        _shirt(canvas);
      case _MenuArt.map:
        _map(canvas);
    }
    _sparkle(canvas, 10, 34, 5);
    _sparkle(canvas, 89, 49, 5);
    _sparkle(canvas, 85, 28, 3);
    canvas.restore();
  }

  void _passport(Canvas canvas) {
    canvas.save();
    canvas.translate(50, 51);
    canvas.rotate(-0.25);
    final cover = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-28, -37, 56, 73),
          const Radius.circular(6),
        ),
      );
    canvas.drawShadow(cover, const Color(0x995D205C), 4, true);
    _outlined(canvas, cover, const Color(0xFFE83A9A));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-23, -32, 46, 63),
        const Radius.circular(3),
      ),
      Paint()
        ..color = const Color(0xFFFFD66B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    canvas.drawLine(
      const Offset(-23, -30),
      const Offset(-23, 30),
      Paint()
        ..color = const Color(0xFFAD2179)
        ..strokeWidth = 2,
    );
    final gold = Paint()
      ..color = const Color(0xFFFFDC65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(const Offset(1, 5), 15, gold);
    canvas.drawOval(const Rect.fromLTWH(-6, -10, 14, 30), gold);
    canvas.drawLine(const Offset(-14, 5), const Offset(16, 5), gold);
    canvas.drawOval(const Rect.fromLTWH(-14, -2, 30, 14), gold);
    final text = TextPainter(
      text: const TextSpan(
        text: 'PASSPORT',
        style: TextStyle(
          color: Color(0xFFFFE587),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(-text.width / 2, -25));
    canvas.restore();
  }

  void _shirt(Canvas canvas) {
    final hanger = Path()
      ..moveTo(46, 19)
      ..cubicTo(43, 10, 57, 10, 56, 18)
      ..cubicTo(56, 23, 49, 23, 49, 29)
      ..lineTo(27, 39)
      ..quadraticBezierTo(23, 43, 29, 43)
      ..lineTo(73, 43)
      ..quadraticBezierTo(78, 42, 73, 39)
      ..lineTo(49, 29);
    canvas.drawPath(
      hanger,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      hanger,
      Paint()
        ..color = const Color(0xFF62234C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    final shirt = Path()
      ..moveTo(35, 36)
      ..lineTo(20, 48)
      ..lineTo(30, 60)
      ..lineTo(36, 56)
      ..lineTo(34, 84)
      ..quadraticBezierTo(50, 90, 67, 84)
      ..lineTo(65, 56)
      ..lineTo(72, 60)
      ..lineTo(82, 48)
      ..lineTo(66, 36)
      ..lineTo(58, 36)
      ..quadraticBezierTo(50, 46, 42, 36)
      ..close();
    canvas.drawShadow(shirt, const Color(0x886B3172), 3, true);
    _outlined(canvas, shirt, const Color(0xFFF2D4A0), width: 6);
    canvas.drawPath(
      shirt,
      Paint()
        ..color = const Color(0xFFA27B4E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..strokeJoin = StrokeJoin.round,
    );
    final scarf = Path()
      ..moveTo(41, 37)
      ..lineTo(59, 37)
      ..lineTo(52, 49)
      ..lineTo(58, 65)
      ..lineTo(48, 60)
      ..lineTo(48, 48)
      ..close();
    canvas.drawPath(scarf, Paint()..color = const Color(0xFFE67599));
    for (final x in [38.0, 57.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 68, 12, 10),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFFCAAB77),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(34, 7, 34, 23),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFE3BD7C),
    );
    canvas.drawRect(
      const Rect.fromLTWH(34, 22, 34, 5),
      Paint()..color = const Color(0xFF9E7350),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(23, 27, 56, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFCFA366),
    );
  }

  void _map(Canvas canvas) {
    canvas.save();
    canvas.translate(50, 57);
    canvas.rotate(-0.08);
    final paper = Path()
      ..moveTo(-36, -22)
      ..lineTo(-13, -28)
      ..lineTo(11, -20)
      ..lineTo(36, -25)
      ..lineTo(32, 29)
      ..lineTo(9, 33)
      ..lineTo(-14, 26)
      ..lineTo(-37, 31)
      ..close();
    canvas.drawShadow(paper, const Color(0x886B3172), 3, true);
    _outlined(canvas, paper, const Color(0xFFFFD969), width: 6);
    canvas.drawPath(
      paper,
      Paint()
        ..color = const Color(0xFFE6A434)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final field = Path()
      ..moveTo(-31, -15)
      ..lineTo(-13, -20)
      ..lineTo(10, -12)
      ..lineTo(29, -16)
      ..lineTo(26, 22)
      ..lineTo(9, 26)
      ..lineTo(-13, 19)
      ..lineTo(-31, 23)
      ..close();
    canvas.drawPath(field, Paint()..color = const Color(0xFFB9DB73));
    final road = Path()
      ..moveTo(-30, 14)
      ..cubicTo(-18, -9, -4, 29, 5, 7)
      ..cubicTo(12, -12, 20, 14, 28, -6);
    canvas.drawPath(
      road,
      Paint()
        ..color = const Color(0xFFFFF6CF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    for (final x in [-13.0, 10.0]) {
      canvas.drawLine(
        Offset(x, -18),
        Offset(x, 23),
        Paint()
          ..color = const Color(0xFFFFE5A1)
          ..strokeWidth = 2,
      );
    }
    canvas.restore();
    void pin(double x, double y, Color color) {
      final path = Path()
        ..moveTo(x, y + 26)
        ..cubicTo(x - 5, y + 17, x - 15, y + 7, x - 12, y - 2)
        ..cubicTo(x - 7, y - 15, x + 10, y - 13, x + 13, y - 2)
        ..cubicTo(x + 16, y + 7, x + 5, y + 18, x, y + 26)
        ..close();
      _outlined(canvas, path, color, width: 4);
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(color, Colors.black, .2)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
    }

    pin(31, 31, const Color(0xFF2EB5F4));
    pin(65, 21, const Color(0xFFFF55A1));
  }

  @override
  bool shouldRepaint(covariant _MenuIllustration oldDelegate) =>
      art != oldDelegate.art;
}
