import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single image plus inexpensive ambient overlays, sharing one finite clock.
/// All overlays use the art's coordinate space, so the lantern remains aligned
/// even when the scene is cropped for a wide or tall device.
class LiveExplorerScene extends StatelessWidget {
  const LiveExplorerScene({
    super.key,
    required this.animation,
    required this.reduceMotion,
  });
  final Animation<double> animation;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: animation,
          child: RepaintBoundary(
            child: Image.asset(
              'assets/images/branding/loading-explorers-v3.png',
              fit: BoxFit.fill,
              cacheWidth: 1080,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFFB6DCCE)),
            ),
          ),
          builder: (_, image) {
            final t = reduceMotion ? 0.0 : animation.value;
            return Transform.scale(
              key: const Key('splash_scene_motion'),
              scale: reduceMotion
                  ? 1
                  : 1.015 + .018 * Curves.easeInOut.transform(t),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 937,
                    height: 1678,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        image!,
                        if (!reduceMotion)
                          CustomPaint(painter: _AmbientPainter(t)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter(this.time);
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = time * math.pi * 2;
    // Warm lantern breathing; low contrast avoids flashing.
    final lantern = Offset(size.width * .922, size.height * .86);
    final glowRadius = size.width * (.075 + .006 * math.sin(phase * 2));
    canvas.drawCircle(
      lantern,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(255, 209, 99, .22 + .04 * math.sin(phase)),
            const Color(0x00FFD163),
          ],
        ).createShader(Rect.fromCircle(center: lantern, radius: glowRadius)),
    );

    // Small warm motes drifting above the foliage. Fixed seeds prevent jitter.
    for (var i = 0; i < 14; i++) {
      final seed = i * 2.399963;
      final x =
          ((i * .173 + .04) % 1) * size.width + math.sin(seed + phase) * 9;
      final y = size.height * (.75 + ((i * .113) % .23)) - time * 28;
      final alpha = .18 + .2 * (1 + math.sin(phase + seed)) / 2;
      canvas.drawCircle(
        Offset(x, y),
        2.0 + i % 3,
        Paint()..color = Color.fromRGBO(255, 240, 177, alpha),
      );
    }

    // A subtle moving sheen over the distant water, above the characters.
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.65 + i * .055) + math.sin(phase + i) * 6;
      final y = size.height * (.365 + i * .008);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 20 + i * 3, y),
        Paint()
          ..color = Colors.white.withValues(alpha: .18)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter oldDelegate) => oldDelegate.time != time;
}
