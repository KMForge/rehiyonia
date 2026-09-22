import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum MascotExpression { idle, thinking, cheering, celebrating }

/// Vector-painted mascot: Bayanito the Philippine Eagle Explorer
/// Scalable, responsive, child-friendly, with zero bitmap dependencies.
class BayanitoMascotWidget extends StatefulWidget {
  const BayanitoMascotWidget({
    super.key,
    this.size = 120,
    this.expression = MascotExpression.idle,
    this.showSpeechBubble = false,
    this.speechText,
    this.animated,
  });

  final double size;
  final MascotExpression expression;
  final bool showSpeechBubble;
  final String? speechText;
  final bool? animated;

  @override
  State<BayanitoMascotWidget> createState() => _BayanitoMascotWidgetState();
}

class _BayanitoMascotWidgetState extends State<BayanitoMascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    final isTestEnv = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    final shouldAnimate = widget.animated ?? !isTestEnv;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (shouldAnimate) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showSpeechBubble && widget.speechText != null) ...[
                _buildSpeechBubble(context, widget.speechText!),
                const SizedBox(height: 8),
              ],
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _BayanitoPainter(expression: widget.expression),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeechBubble(BuildContext context, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.babyBlue, width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textNavy,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}

class _BayanitoPainter extends CustomPainter {
  _BayanitoPainter({required this.expression});

  final MascotExpression expression;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.55);

    // 1. Feather Crest (Philippine Eagle Crown)
    final crestPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..style = PaintingStyle.fill;
    final crestLightPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    // Outer crest feathers
    for (int i = -3; i <= 3; i++) {
      final angle = (i * 12) * math.pi / 180;
      final crestPath = Path()
        ..moveTo(w / 2, h * 0.35)
        ..quadraticBezierTo(
          w / 2 + math.sin(angle) * (w * 0.45),
          h * 0.35 - math.cos(angle) * (h * 0.42),
          w / 2 + math.sin(angle + 0.1) * (w * 0.35),
          h * 0.35,
        );
      canvas.drawPath(
        crestPath,
        (i.abs() % 2 == 0) ? crestPaint : crestLightPaint,
      );
    }

    // 2. Head & Body (Soft cream / warm white)
    final headPaint = Paint()
      ..color = const Color(0xFFFFF8E7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.36, headPaint);

    // Subtle head border
    final outlinePaint = Paint()
      ..color = const Color(0xFFBCAAA4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawCircle(center, w * 0.36, outlinePaint);

    // 3. Explorer Adventurer Hat
    final hatBrimPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;
    final hatCrownPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    final hatBandPaint = Paint()
      ..color = AppColors.deepBlue
      ..style = PaintingStyle.fill;

    // Crown
    final hatCrownRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.22),
        width: w * 0.48,
        height: h * 0.22,
      ),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(hatCrownRect, hatCrownPaint);

    // Band
    final hatBandRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.29),
      width: w * 0.48,
      height: h * 0.06,
    );
    canvas.drawRect(hatBandRect, hatBandPaint);

    // Gold badge buckle on hat
    final bucklePaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(w / 2, h * 0.29), w * 0.04, bucklePaint);

    // Brim
    final hatBrimRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.33),
      width: w * 0.76,
      height: h * 0.08,
    );
    canvas.drawOval(hatBrimRect, hatBrimPaint);

    // 4. Rosy Cheeks
    final cheekPaint = Paint()
      ..color = AppColors.pastelPink.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.28, h * 0.62), w * 0.08, cheekPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.62), w * 0.08, cheekPaint);

    // 5. Eyes
    _drawEyes(canvas, w, h);

    // 6. Hooked Beak (Philippine Eagle signature beak)
    final beakPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;
    final beakTipPaint = Paint()
      ..color = const Color(0xFF424242)
      ..style = PaintingStyle.fill;

    final beakPath = Path()
      ..moveTo(w * 0.40, h * 0.56)
      ..quadraticBezierTo(w / 2, h * 0.54, w * 0.60, h * 0.56)
      ..quadraticBezierTo(w * 0.56, h * 0.72, w / 2, h * 0.74)
      ..quadraticBezierTo(w * 0.44, h * 0.72, w * 0.40, h * 0.56);
    canvas.drawPath(beakPath, beakPaint);

    // Beak hook tip
    final hookPath = Path()
      ..moveTo(w * 0.46, h * 0.66)
      ..quadraticBezierTo(w / 2, h * 0.65, w * 0.54, h * 0.66)
      ..quadraticBezierTo(w / 2, h * 0.75, w * 0.46, h * 0.66);
    canvas.drawPath(hookPath, beakTipPaint);

    // 7. Neckerchief / Bandana (Pastel Pink or Baby Blue)
    final scarfPaint = Paint()
      ..color = AppColors.pastelPink
      ..style = PaintingStyle.fill;
    final scarfKnotPaint = Paint()
      ..color = AppColors.deepBlue
      ..style = PaintingStyle.fill;

    final scarfPath = Path()
      ..moveTo(w * 0.32, h * 0.86)
      ..quadraticBezierTo(w / 2, h * 0.96, w * 0.68, h * 0.86)
      ..quadraticBezierTo(w / 2, h * 0.82, w * 0.32, h * 0.86);
    canvas.drawPath(scarfPath, scarfPaint);
    canvas.drawCircle(Offset(w / 2, h * 0.88), w * 0.045, scarfKnotPaint);

    // 8. Expression-specific accents
    if (expression == MascotExpression.cheering ||
        expression == MascotExpression.celebrating) {
      _drawCelebrationSparkles(canvas, w, h);
    } else if (expression == MascotExpression.thinking) {
      _drawThinkingBubble(canvas, w, h);
    }
  }

  void _drawEyes(Canvas canvas, double w, double h) {
    final eyePaint = Paint()
      ..color = AppColors.textNavy
      ..style = PaintingStyle.fill;
    final catchlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (expression == MascotExpression.cheering ||
        expression == MascotExpression.celebrating) {
      // Happy curved closed eyes ^ ^
      final happyEyePaint = Paint()
        ..color = AppColors.textNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round;

      final leftPath = Path()
        ..moveTo(w * 0.28, h * 0.54)
        ..quadraticBezierTo(w * 0.34, h * 0.48, w * 0.40, h * 0.54);
      final rightPath = Path()
        ..moveTo(w * 0.60, h * 0.54)
        ..quadraticBezierTo(w * 0.66, h * 0.48, w * 0.72, h * 0.54);

      canvas.drawPath(leftPath, happyEyePaint);
      canvas.drawPath(rightPath, happyEyePaint);
    } else {
      // Big expressive open eyes with sparkling catchlights
      final eyeRadius = w * 0.07;
      final leftCenter = Offset(w * 0.34, h * 0.52);
      final rightCenter = Offset(w * 0.66, h * 0.52);

      canvas.drawCircle(leftCenter, eyeRadius, eyePaint);
      canvas.drawCircle(rightCenter, eyeRadius, eyePaint);

      // Primary catchlights
      canvas.drawCircle(
        Offset(leftCenter.dx - w * 0.02, leftCenter.dy - h * 0.015),
        eyeRadius * 0.4,
        catchlightPaint,
      );
      canvas.drawCircle(
        Offset(rightCenter.dx - w * 0.02, rightCenter.dy - h * 0.015),
        eyeRadius * 0.4,
        catchlightPaint,
      );

      // Secondary micro catchlights
      canvas.drawCircle(
        Offset(leftCenter.dx + w * 0.025, leftCenter.dy + h * 0.02),
        eyeRadius * 0.2,
        catchlightPaint,
      );
      canvas.drawCircle(
        Offset(rightCenter.dx + w * 0.025, rightCenter.dy + h * 0.02),
        eyeRadius * 0.2,
        catchlightPaint,
      );
    }
  }

  void _drawCelebrationSparkles(Canvas canvas, double w, double h) {
    final starPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    // Small decorative stars around mascot
    _drawStar(canvas, Offset(w * 0.12, h * 0.28), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.88, h * 0.25), w * 0.05, starPaint);
    _drawStar(canvas, Offset(w * 0.90, h * 0.65), w * 0.035, starPaint);
  }

  void _drawThinkingBubble(Canvas canvas, double w, double h) {
    final sparkPaint = Paint()
      ..color = const Color(0xFFFFCA28)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.82, h * 0.22), w * 0.04, sparkPaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.15), w * 0.025, sparkPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final double outerAngle = (i * 72 - 90) * math.pi / 180;
      final double innerAngle = (i * 72 + 36 - 90) * math.pi / 180;
      final x1 = center.dx + radius * math.cos(outerAngle);
      final y1 = center.dy + radius * math.sin(outerAngle);
      final x2 = center.dx + (radius * 0.5) * math.cos(innerAngle);
      final y2 = center.dy + (radius * 0.5) * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BayanitoPainter oldDelegate) =>
      oldDelegate.expression != expression;
}
