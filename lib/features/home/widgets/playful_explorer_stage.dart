import 'package:flutter/material.dart';

import '../../avatar/models/player_avatar.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import 'home_discovery_cards.dart';
import 'philippine_journey_map.dart';
import 'home_palette.dart';

class PlayfulExplorerStage extends StatelessWidget {
  const PlayfulExplorerStage({
    super.key,
    required this.avatar,
    required this.onCustomize,
    required this.onExplore,
    required this.customizeLabel,
    required this.exploreLabel,
    required this.greeting,
    required this.message,
    required this.regionsLabel,
  });
  final PlayerAvatar avatar;
  final VoidCallback onCustomize, onExplore;
  final String customizeLabel, exploreLabel;
  final String greeting, message, regionsLabel;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: const _PassportStitchPainter(),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFAF2), HomePalette.cream],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF2BDD2), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x207B5274),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 19, color: homeRose),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  regionsLabel.replaceAll('\n', ' '),
                  style: const TextStyle(
                    color: homeRose,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.explore_outlined, color: homeMuted, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = (constraints.maxWidth * .61).clamp(210.0, 260.0);
                return SizedBox(
                  height: height,
                  child: CustomPaint(
                    painter: const _AdventureLandscapePainter(),
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 12,
                          right: 10,
                          child: IgnorePointer(
                            child: ExcludeSemantics(child: TransformPostcard()),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 14,
                          width: constraints.maxWidth * .43,
                          height: height - 28,
                          child: Tooltip(
                            message: customizeLabel,
                            child: Semantics(
                              label: customizeLabel,
                              button: true,
                              child: InkWell(
                                key: const Key('adventure_customize_avatar'),
                                onTap: onCustomize,
                                borderRadius: BorderRadius.circular(24),
                                child: FittedBox(
                                  alignment: Alignment.bottomCenter,
                                  child: Align(
                                    widthFactor: .72,
                                    child: PlayerAvatarWidget(
                                      key: const Key('adventure_player_avatar'),
                                      avatar: avatar,
                                      size: 180,
                                      fullBody: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: constraints.maxWidth * .43,
                          right: 2,
                          top: 8,
                          bottom: 30,
                          child: Tooltip(
                            message: exploreLabel,
                            child: Semantics(
                              label: exploreLabel,
                              button: true,
                              child: InkWell(
                                key: const Key('adventure_explore_map'),
                                onTap: onExplore,
                                borderRadius: BorderRadius.circular(24),
                                child: const PhilippineJourneyMap(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            greeting,
            style: const TextStyle(
              color: homeInk,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: homeMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

class TransformPostcard extends StatelessWidget {
  const TransformPostcard({super.key});
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: .16,
    child: Container(
      width: 39,
      height: 31,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DE),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18795279),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.landscape_rounded,
        color: Color(0xFF89BCA3),
        size: 24,
      ),
    ),
  );
}

class _PassportStitchPainter extends CustomPainter {
  const _PassportStitchPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(8),
          const Radius.circular(22),
        ),
      );
    final paint = Paint()
      ..color = const Color(0xFFE8B9CA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in outline.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 9) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
      }
    }
    // Sparse flecks give the passport paper a light, unobtrusive texture.
    final grain = Paint()..color = const Color(0x09846445);
    for (double y = 15; y < size.height - 10; y += 17) {
      for (double x = 16; x < size.width - 10; x += 19) {
        canvas.drawCircle(
          Offset(x + (y.toInt().isEven ? 3 : 0), y),
          .45,
          grain,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PassportStitchPainter oldDelegate) => false;
}

class _AdventureLandscapePainter extends CustomPainter {
  const _AdventureLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDEFFC), Color(0xFFF5FAFF)],
        ).createShader(bounds),
    );
    canvas.drawCircle(
      Offset(size.width * .19, 36),
      20,
      Paint()..color = const Color(0xFFFFE9AC),
    );
    final cloud = Paint()..color = Colors.white.withValues(alpha: .75);
    for (final center in [
      Offset(size.width * .40, 39),
      Offset(size.width * .87, 25),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 58, height: 13),
        cloud,
      );
      canvas.drawCircle(center.translate(-7, -5), 10, cloud);
      canvas.drawCircle(center.translate(8, -3), 8, cloud);
    }
    final hills = Path()
      ..moveTo(0, size.height * .69)
      ..cubicTo(
        size.width * .17,
        size.height * .38,
        size.width * .34,
        size.height * .82,
        size.width * .57,
        size.height * .67,
      )
      ..quadraticBezierTo(
        size.width * .85,
        size.height * .49,
        size.width,
        size.height * .66,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hills, Paint()..color = const Color(0xFFBCDCC5));
    final foreground = Path()
      ..moveTo(0, size.height * .86)
      ..quadraticBezierTo(
        size.width * .37,
        size.height * .68,
        size.width,
        size.height * .89,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      foreground,
      Paint()..color = Color.lerp(HomePalette.green, HomePalette.blue, .35)!,
    );
    final path = Path()
      ..moveTo(size.width * .13, size.height + 12)
      ..cubicTo(
        size.width * .67,
        size.height * .83,
        size.width * .27,
        size.height * .85,
        size.width * .57,
        size.height * .75,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFE8CE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
    );
    final route = Path()
      ..moveTo(size.width * .32, size.height * .85)
      ..quadraticBezierTo(
        size.width * .64,
        size.height * .99,
        size.width * .72,
        size.height * .57,
      );
    for (final metric in route.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 9) {
        final point = metric.getTangentForOffset(distance)!.position;
        canvas.drawCircle(point, 1.7, Paint()..color = const Color(0xFFBB638A));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdventureLandscapePainter oldDelegate) => false;
}
