import 'package:flutter/material.dart';

/// A lightweight wardrobe display; no continuously running animation controller.
class AvatarStage extends StatelessWidget {
  const AvatarStage({
    super.key,
    required this.height,
    required this.child,
    this.baseId = 'female',
  });
  final double height;
  final Widget child;
  final String baseId;

  bool get _isMale => baseId == 'male';
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: RadialGradient(
        center: Alignment(0, -.3),
        radius: 1.1,
        colors: _isMale
            ? const [Color(0xFFFFF8ED), Color(0xFFDDF3FF), Color(0xFFDDF3EC)]
            : const [Color(0xFFFFF8ED), Color(0xFFDDF3FF), Color(0xFFFFDDEB)],
      ),
      border: Border.all(
        color: _isMale ? const Color(0xFFB5D8E8) : const Color(0xFFF0BDD5),
      ),
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
              border: Border.all(color: const Color(0xFFB7DCEB), width: 1.5),
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
              color: _isMale
                  ? const Color(0xFFDDEFF8)
                  : const Color(0xFFFCE3ED),
              border: Border.all(
                color: _isMale
                    ? const Color(0xFFA8CEDF)
                    : const Color(0xFFE9B5CE),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isMale
                      ? const Color(0x228BB4C5)
                      : const Color(0x22C58BAC),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: 18,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFC99445).withValues(alpha: .8),
            size: 22,
          ),
        ),
        child,
      ],
    ),
  );
}
