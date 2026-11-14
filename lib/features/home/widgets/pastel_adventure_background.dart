import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'home_palette.dart';

/// Independent scenery layers preserve proportions on short and tall screens.
class PastelAdventureBackground extends StatelessWidget {
  const PastelAdventureBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HomePalette.blue, Color(0xFFEAF6FF), HomePalette.pink],
            stops: [0, .32, 1],
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: RepaintBoundary(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = math.min(constraints.maxWidth, 620.0);
                  final decodeWidth =
                      (width * MediaQuery.devicePixelRatioOf(context))
                          .ceil()
                          .clamp(1, 1024);
                  return Center(
                    child: SizedBox(
                      width: width,
                      height: constraints.maxHeight,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _FadedScenery(
                              asset: 'home-sky-scene-v1.jpg',
                              height: width * 400 / 1024,
                              decodeWidth: decodeWidth,
                              fadeFromTop: false,
                            ),
                          ),
                          Positioned(
                            top: width * .30,
                            bottom: width * .26,
                            left: 0,
                            width: width * .065,
                            child: const _FoliageEdge(left: true),
                          ),
                          Positioned(
                            top: width * .30,
                            bottom: width * .26,
                            right: 0,
                            width: width * .065,
                            child: const _FoliageEdge(left: false),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _FadedScenery(
                              asset: 'home-travel-footer-v1.jpg',
                              height: width * 416 / 1024,
                              decodeWidth: decodeWidth,
                              fadeFromTop: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      child,
    ],
  );
}

class _FoliageEdge extends StatelessWidget {
  const _FoliageEdge({required this.left});
  final bool left;
  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (bounds) => LinearGradient(
      begin: left ? Alignment.centerLeft : Alignment.centerRight,
      end: left ? Alignment.centerRight : Alignment.centerLeft,
      colors: const [Colors.white, Colors.white, Colors.transparent],
      stops: const [0, .4, 1],
    ).createShader(bounds),
    child: ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0, .06, .94, 1],
      ).createShader(bounds),
      child: Image.asset(
        'assets/images/branding/home-foliage-${left ? 'left' : 'right'}-v1.jpg',
        fit: BoxFit.cover,
        cacheWidth: 96,
        excludeFromSemantics: true,
      ),
    ),
  );
}

class _FadedScenery extends StatelessWidget {
  const _FadedScenery({
    required this.asset,
    required this.height,
    required this.decodeWidth,
    required this.fadeFromTop,
  });
  final String asset;
  final double height;
  final int decodeWidth;
  final bool fadeFromTop;
  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (bounds) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: fadeFromTop
          ? const [Colors.transparent, Colors.white, Colors.white]
          : const [Colors.white, Colors.white, Colors.transparent],
      stops: fadeFromTop ? const [0, .22, 1] : const [0, .76, 1],
    ).createShader(bounds),
    child: Image.asset(
      'assets/images/branding/$asset',
      height: height,
      width: double.infinity,
      fit: BoxFit.contain,
      cacheWidth: decodeWidth,
      excludeFromSemantics: true,
    ),
  );
}

class GlossyExploreButton extends StatelessWidget {
  const GlossyExploreButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFBD377E)
              .withValues(alpha: onPressed == null ? .08 : .28),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: onPressed == null
                ? const [Color(0xFFBFAEBB), Color(0xFF9C8B98)]
                : const [HomePalette.hotPink, Color(0xFFD8247A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 19,
                      color: Color(0xFFFFE6A0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class CandyMenuSurface extends StatelessWidget {
  const CandyMenuSurface({
    super.key,
    required this.color,
    required this.onTap,
    required this.child,
  });
  final Color color;
  final VoidCallback onTap;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x185D527C),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFFFFBFF), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: child,
      ),
    ),
  );
}
