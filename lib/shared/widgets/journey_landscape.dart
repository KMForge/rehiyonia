import 'package:flutter/material.dart';

import '../../app/explorer_theme.dart';

/// Decorative scenery, deliberately not an educational geographic map.
class JourneyLandscape extends StatelessWidget {
  const JourneyLandscape({
    super.key,
    this.height = 180,
    this.child,
    this.group = 'Luzon',
  });
  final double height;
  final Widget? child;
  final String group;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _Landscape(group), child: child),
    ),
  );
}

class _Landscape extends CustomPainter {
  const _Landscape(this.group);
  final String group;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFDBEFF0),
    );
    canvas.drawCircle(
      Offset(w * .79, h * .26),
      24,
      Paint()..color = ExplorerTheme.sun,
    );
    final back = Path()
      ..moveTo(0, h * .72)
      ..quadraticBezierTo(w * .15, h * .18, w * .38, h * .63)
      ..quadraticBezierTo(w * .67, h * .05, w, h * .60)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF83BCA9));
    final front = Path()
      ..moveTo(0, h * .86)
      ..quadraticBezierTo(w * .4, h * .3, w * .65, h * .86)
      ..quadraticBezierTo(w * .82, h * .52, w, h * .76)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..color = group == 'Visayas'
            ? const Color(0xFF58A9BA)
            : const Color(0xFF398579),
    );
    final sea = Path()
      ..moveTo(0, h * .92)
      ..quadraticBezierTo(w * .5, h * .83, w, h * .95)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(sea, Paint()..color = const Color(0xFF146C84));
    final cloud = Paint()..color = Colors.white.withValues(alpha: .65);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .1, h * .18, 65, 14),
        const Radius.circular(12),
      ),
      cloud,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .48, h * .1, 40, 10),
        const Radius.circular(10),
      ),
      cloud,
    );
  }

  @override
  bool shouldRepaint(_Landscape oldDelegate) => group != oldDelegate.group;
}
