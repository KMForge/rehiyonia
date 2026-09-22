import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/player_avatar.dart';

class PlayerAvatarWidget extends StatelessWidget {
  const PlayerAvatarWidget({
    super.key,
    required this.avatar,
    this.size = 64,
    this.showBorder = true,
  });

  final PlayerAvatar avatar;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.babyBlue.withValues(alpha: 0.3),
        border: showBorder
            ? Border.all(color: AppColors.deepBlue, width: size * 0.04)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.1),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: _AvatarPainter(avatar: avatar),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({required this.avatar});

  final PlayerAvatar avatar;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final headCenter = Offset(w / 2, h * 0.45);
    final headRadius = w * 0.28;

    // 1. Outfit (Shoulders / Shirt)
    final shirtPaint = Paint()
      ..color = avatar.outfitColor
      ..style = PaintingStyle.fill;
    final shirtPath = Path()
      ..moveTo(w * 0.12, h)
      ..quadraticBezierTo(w * 0.18, h * 0.72, w * 0.35, h * 0.70)
      ..lineTo(w * 0.65, h * 0.70)
      ..quadraticBezierTo(w * 0.82, h * 0.72, w * 0.88, h)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Collar / Neck
    final neckPaint = Paint()
      ..color = avatar.skinColor
      ..style = PaintingStyle.fill;
    final neckRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.66),
      width: w * 0.22,
      height: h * 0.16,
    );
    canvas.drawRect(neckRect, neckPaint);

    // Shirt collar detail
    final collarPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final collarPath = Path()
      ..moveTo(w * 0.38, h * 0.70)
      ..lineTo(w / 2, h * 0.80)
      ..lineTo(w * 0.62, h * 0.70)
      ..close();
    canvas.drawPath(collarPath, collarPaint);

    // 2. Head & Ears
    final skinPaint = Paint()
      ..color = avatar.skinColor
      ..style = PaintingStyle.fill;

    // Ears
    canvas.drawCircle(Offset(w * 0.21, h * 0.46), w * 0.07, skinPaint);
    canvas.drawCircle(Offset(w * 0.79, h * 0.46), w * 0.07, skinPaint);

    // Face
    canvas.drawCircle(headCenter, headRadius, skinPaint);

    // 3. Cheeks
    final cheekPaint = Paint()
      ..color = AppColors.pastelPink.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.34, h * 0.52), w * 0.06, cheekPaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.52), w * 0.06, cheekPaint);

    // 4. Eyes & Smile
    final eyePaint = Paint()..color = AppColors.textNavy;
    canvas.drawCircle(Offset(w * 0.38, h * 0.45), w * 0.04, eyePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.45), w * 0.04, eyePaint);

    // Eye catchlights
    final catchlight = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.37, h * 0.44), w * 0.015, catchlight);
    canvas.drawCircle(Offset(w * 0.61, h * 0.44), w * 0.015, catchlight);

    // Smile
    final smilePaint = Paint()
      ..color = AppColors.textNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(w * 0.44, h * 0.54)
      ..quadraticBezierTo(w / 2, h * 0.60, w * 0.56, h * 0.54);
    canvas.drawPath(smilePath, smilePaint);

    // 5. Hair
    _drawHair(canvas, w, h);

    // 6. Accessory
    _drawAccessory(canvas, w, h);
  }

  void _drawHair(Canvas canvas, double w, double h) {
    final hairPaint = Paint()
      ..color = avatar.hairColor
      ..style = PaintingStyle.fill;

    switch (avatar.hairStyleIndex) {
      case 0: // Short neat
        final hairPath = Path()
          ..moveTo(w * 0.20, h * 0.42)
          ..quadraticBezierTo(w * 0.22, h * 0.18, w / 2, h * 0.16)
          ..quadraticBezierTo(w * 0.78, h * 0.18, w * 0.80, h * 0.42)
          ..quadraticBezierTo(w * 0.68, h * 0.32, w / 2, h * 0.34)
          ..quadraticBezierTo(w * 0.32, h * 0.32, w * 0.20, h * 0.42);
        canvas.drawPath(hairPath, hairPaint);
        break;
      case 1: // Curly wave
        final curlyPath = Path()
          ..moveTo(w * 0.16, h * 0.48)
          ..quadraticBezierTo(w * 0.14, h * 0.20, w * 0.35, h * 0.16)
          ..quadraticBezierTo(w / 2, h * 0.12, w * 0.65, h * 0.16)
          ..quadraticBezierTo(w * 0.86, h * 0.20, w * 0.84, h * 0.48)
          ..quadraticBezierTo(w * 0.72, h * 0.36, w * 0.58, h * 0.35)
          ..quadraticBezierTo(w * 0.42, h * 0.32, w * 0.28, h * 0.36)
          ..close();
        canvas.drawPath(curlyPath, hairPaint);
        break;
      case 2: // Braided / Ponytail
        // Hair cap
        final capPath = Path()
          ..moveTo(w * 0.20, h * 0.42)
          ..quadraticBezierTo(w * 0.22, h * 0.18, w / 2, h * 0.18)
          ..quadraticBezierTo(w * 0.78, h * 0.18, w * 0.80, h * 0.42)
          ..quadraticBezierTo(w * 0.60, h * 0.30, w / 2, h * 0.32)
          ..quadraticBezierTo(w * 0.40, h * 0.30, w * 0.20, h * 0.42);
        canvas.drawPath(capPath, hairPaint);
        // Ponytail behind shoulder
        canvas.drawCircle(Offset(w * 0.82, h * 0.55), w * 0.11, hairPaint);
        canvas.drawCircle(Offset(w * 0.85, h * 0.70), w * 0.09, hairPaint);
        break;
      case 3: // Cool Spiky
      default:
        final spikyPath = Path()
          ..moveTo(w * 0.20, h * 0.42)
          ..lineTo(w * 0.24, h * 0.25)
          ..lineTo(w * 0.34, h * 0.28)
          ..lineTo(w * 0.42, h * 0.14)
          ..lineTo(w * 0.50, h * 0.24)
          ..lineTo(w * 0.60, h * 0.12)
          ..lineTo(w * 0.68, h * 0.24)
          ..lineTo(w * 0.76, h * 0.20)
          ..lineTo(w * 0.80, h * 0.42)
          ..quadraticBezierTo(w * 0.60, h * 0.32, w / 2, h * 0.34)
          ..quadraticBezierTo(w * 0.38, h * 0.32, w * 0.20, h * 0.42);
        canvas.drawPath(spikyPath, hairPaint);
        break;
    }
  }

  void _drawAccessory(Canvas canvas, double w, double h) {
    if (avatar.accessoryIndex == 0) return;

    if (avatar.accessoryIndex == 1) {
      // Explorer Cap
      final capPaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.fill;
      final visorPaint = Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.fill;

      final capRect = Rect.fromCenter(
        center: Offset(w / 2, h * 0.20),
        width: w * 0.62,
        height: h * 0.18,
      );
      canvas.drawOval(capRect, capPaint);

      final visorPath = Path()
        ..moveTo(w * 0.20, h * 0.24)
        ..quadraticBezierTo(w / 2, h * 0.34, w * 0.80, h * 0.24)
        ..quadraticBezierTo(w / 2, h * 0.20, w * 0.20, h * 0.24);
      canvas.drawPath(visorPath, visorPaint);
    } else if (avatar.accessoryIndex == 2) {
      // Sampaguita flower / ribbon
      final flowerCenter = Offset(w * 0.72, h * 0.28);
      final petalPaint = Paint()..color = Colors.white;
      final centerPaint = Paint()..color = const Color(0xFFFFD54F);

      for (int i = 0; i < 5; i++) {
        final angle = (i * 72) * 3.14159 / 180;
        canvas.drawCircle(
          Offset(
            flowerCenter.dx +
                w * 0.04 * 3.14159 * 0.3 * (angle == 0 ? 1 : -0.5),
            flowerCenter.dy + h * 0.04 * 3.14159 * 0.3 * (angle == 0 ? 0 : 0.8),
          ),
          w * 0.035,
          petalPaint,
        );
      }
      canvas.drawCircle(flowerCenter, w * 0.025, centerPaint);
    } else if (avatar.accessoryIndex == 3) {
      // Star glasses
      final glassPaint = Paint()
        ..color = AppColors.deepBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03;
      canvas.drawCircle(Offset(w * 0.38, h * 0.45), w * 0.08, glassPaint);
      canvas.drawCircle(Offset(w * 0.62, h * 0.45), w * 0.08, glassPaint);
      canvas.drawLine(
        Offset(w * 0.46, h * 0.45),
        Offset(w * 0.54, h * 0.45),
        glassPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.avatar != avatar;
}
