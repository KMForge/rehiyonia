import 'package:flutter/material.dart';

/// A lightweight wardrobe display; no continuously running animation controller.
class AvatarStage extends StatelessWidget {
  const AvatarStage({super.key, required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const RadialGradient(
        center: Alignment(0, -.3),
        radius: 1.1,
        colors: [Color(0xFF397781), Color(0xFF173B54), Color(0xFF102439)],
      ),
      border: Border.all(color: const Color(0xFF496978)),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 16,
          child: Container(
            width: height * .72,
            height: height * .72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x337BDED5), width: 1.5),
            ),
          ),
        ),
        Positioned(
          bottom: 7,
          child: Container(
            width: height * .65,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: const Color(0xFF244E63),
              border: Border.all(color: const Color(0xFF78C5BE), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x335FE5C9), blurRadius: 18),
              ],
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: 18,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFFFD885).withValues(alpha: .8),
            size: 22,
          ),
        ),
        child,
      ],
    ),
  );
}
