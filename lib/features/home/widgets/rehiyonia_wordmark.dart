import 'package:flutter/material.dart';

import 'home_palette.dart';

/// Reuses the same pink-and-gold logo as the existing splash screen.
class RehiyoniaWordmark extends StatelessWidget {
  const RehiyoniaWordmark({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title, subtitle;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        label: title,
        header: true,
        image: true,
        child: Image.asset(
          'assets/images/branding/rehiyonia-logo-pink-v2.png',
          key: const Key('home_existing_logo'),
          width: 330,
          height: 150,
          fit: BoxFit.contain,
          cacheWidth: 900,
          excludeFromSemantics: true,
        ),
      ),
      ClipPath(
        clipper: const _RibbonClipper(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [HomePalette.blue, Color(0xFFECF9FF), HomePalette.blue],
            ),
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HomePalette.ink,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: .9,
            ),
          ),
        ),
      ),
    ],
  );
}

class _RibbonClipper extends CustomClipper<Path> {
  const _RibbonClipper();
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width - 9, size.height / 2)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..lineTo(9, size.height / 2)
    ..close();
  @override
  bool shouldReclip(covariant _RibbonClipper oldClipper) => false;
}
