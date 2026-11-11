import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedExplorerLogo extends StatelessWidget {
  const AnimatedExplorerLogo({
    super.key,
    required this.animation,
    required this.reduceMotion,
    required this.height,
  });

  final Animation<double> animation;
  final bool reduceMotion;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Rehiyonia',
    image: true,
    child: AnimatedBuilder(
      animation: animation,
      child: RepaintBoundary(
        child: Image.asset(
          'assets/images/branding/rehiyonia-logo-pink-v2.png',
          width: 360,
          height: height,
          fit: BoxFit.contain,
          cacheWidth: 900,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => const Text(
            'REHIYONIA',
            style: TextStyle(
              color: Color(0xFFAB1759),
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      builder: (_, child) {
        final t = reduceMotion ? 1.0 : animation.value;
        final reveal = Curves.easeOutCubic.transform((t / .18).clamp(0.0, 1.0));
        final float = reduceMotion ? 0.0 : math.sin(t * math.pi * 3) * 3;
        return Opacity(
          opacity: reveal,
          child: Transform.translate(
            key: const Key('splash_logo_motion'),
            offset: Offset(0, 16 * (1 - reveal) + float),
            child: Transform.scale(scale: .9 + .1 * reveal, child: child),
          ),
        );
      },
    ),
  );
}
