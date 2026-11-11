import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/explorer_theme.dart';
import '../models/player_avatar.dart';

abstract final class AvatarPalette {
  static const skins = [
    Color(0xFFF1C59D),
    Color(0xFFD2A078),
    Color(0xFFAD704A),
    Color(0xFFFFDFC2),
  ];
  static const hair = [
    Color(0xFF242738),
    Color(0xFF49342C),
    Color(0xFF6A4434),
    Color(0xFF987557),
  ];
  static const clothes = [
    Color(0xFF206DA8),
    Color(0xFFC86577),
    Color(0xFF298A75),
    Color(0xFF8070B0),
  ];
  static Color at(List<Color> colors, int i) =>
      colors[i.clamp(0, colors.length - 1)];
}

/// The same coordinate-based character is used for portrait and full body.
class PlayerAvatarWidget extends StatelessWidget {
  const PlayerAvatarWidget({
    super.key,
    required this.avatar,
    this.size = 64,
    this.showBorder = true,
    this.fullBody = false,
  });
  final PlayerAvatar avatar;
  final double size;
  final bool showBorder, fullBody;
  @override
  Widget build(BuildContext context) {
    final painting = RepaintBoundary(
      child: CustomPaint(
        size: Size(size, fullBody ? size * 1.55 : size),
        painter: _AvatarPainter(avatar, fullBody),
      ),
    );
    if (fullBody) return painting;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE5F0EF),
        border: showBorder ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: ClipOval(child: painting),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.avatar, this.fullBody);
  final PlayerAvatar avatar;
  final bool fullBody;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (fullBody) {
      canvas.scale(size.width / 220, size.height / 340);
    } else {
      canvas.scale(size.width / 145);
      canvas.translate(-37.5, -15);
    }
    final skin = AvatarPalette.at(AvatarPalette.skins, avatar.skinIndex);
    final hair = AvatarPalette.at(AvatarPalette.hair, avatar.hairColorIndex);
    final top = AvatarPalette.at(
      AvatarPalette.clothes,
      avatar.outfitColorIndex,
    );
    final bottom = Color.lerp(
      AvatarPalette.at(AvatarPalette.clothes, avatar.bottomColorIndex),
      ExplorerTheme.ink,
      .45,
    )!;
    final female = avatar.baseId == 'female';
    final longHair = avatar.hairStyleIndex == 2 || avatar.hairStyleIndex >= 4;
    void oval(double x, double y, double w, double h, Color color) =>
        canvas.drawOval(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
    void box(double x, double y, double w, double h, double r, Color color) =>
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h),
            Radius.circular(r),
          ),
          Paint()..color = color,
        );
    void stroke(List<Offset> points, Color color, double width) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }

    // Ground shadow and back hair.
    oval(57, 318, 111, 12, const Color(0x220D425A));
    if (longHair) {
      box(55, 39, 109, avatar.hairStyleIndex == 4 ? 96 : 138, 38, hair);
      if (avatar.hairStyleIndex == 2) {
        oval(149, 65, 29, 79, hair);
        box(151, 72, 22, 7, 3, ExplorerTheme.sun);
      }
    }
    // Legs: shorts reveal calves; pants and shoes keep the same anchors.
    box(78, 225, 26, 83, 12, skin);
    box(116, 225, 26, 83, 12, skin);
    final shortBottom = [
      'shorts',
      'sport_shorts',
      'pleated_shorts',
      'skirt',
    ].contains(avatar.bottomId);
    if (avatar.bottomId == 'wide_pants') {
      for (final x in [76.0, 115.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(x, 219)
            ..lineTo(x + 28, 219)
            ..lineTo(x + 35, 299)
            ..lineTo(x - 6, 299)
            ..close(),
          Paint()..color = bottom,
        );
      }
    } else if (!shortBottom) {
      box(75, 215, 31, 84, 10, bottom);
      box(114, 215, 31, 84, 10, bottom);
    } else {
      box(73, 215, 35, 42, 8, bottom);
      box(112, 215, 35, 42, 8, bottom);
    }
    box(75, 211, 69, 26, 8, bottom);
    if (avatar.bottomId == 'skirt') {
      canvas.drawPath(
        Path()
          ..moveTo(77, 216)
          ..lineTo(143, 216)
          ..lineTo(155, 262)
          ..quadraticBezierTo(110, 273, 65, 262)
          ..close(),
        Paint()..color = bottom,
      );
      for (var x = 81.0; x <= 139; x += 14) {
        stroke(
          [Offset(x, 229), Offset(x + (x - 110) * .25, 260)],
          Colors.white.withValues(alpha: .3),
          2,
        );
      }
    }
    if (avatar.bottomId == 'chinos') {
      stroke(
        [const Offset(80, 237), const Offset(95, 245)],
        ExplorerTheme.paper,
        2,
      );
      stroke(
        [const Offset(140, 237), const Offset(125, 245)],
        ExplorerTheme.paper,
        2,
      );
      box(75, 288, 31, 9, 2, Color.lerp(bottom, Colors.white, .3)!);
      box(114, 288, 31, 9, 2, Color.lerp(bottom, Colors.white, .3)!);
    }
    if (avatar.bottomId == 'sport_shorts') {
      stroke([const Offset(77, 235), const Offset(77, 252)], Colors.white, 3);
      stroke([const Offset(143, 235), const Offset(143, 252)], Colors.white, 3);
    }
    if (avatar.bottomId == 'pleated_shorts') {
      for (final x in [82.0, 96.0, 121.0, 135.0]) {
        stroke(
          [Offset(x, 233), Offset(x, 254)],
          Colors.white.withValues(alpha: .4),
          2,
        );
      }
    }
    // Tailored seams, cuffs and utility pockets retain the shared leg anchors.
    stroke(
      [const Offset(90, 239), Offset(90, shortBottom ? 250 : 288)],
      Colors.white.withValues(alpha: .18),
      2,
    );
    stroke(
      [const Offset(130, 239), Offset(130, shortBottom ? 250 : 288)],
      Colors.white.withValues(alpha: .18),
      2,
    );
    if (avatar.bottomId == 'cargo') {
      box(74, 252, 25, 23, 4, Color.lerp(bottom, Colors.white, .16)!);
      box(122, 252, 25, 23, 4, Color.lerp(bottom, Colors.white, .16)!);
      stroke([const Offset(77, 258), const Offset(96, 258)], bottom, 2);
      stroke([const Offset(125, 258), const Offset(144, 258)], bottom, 2);
    }
    if (['flats', 'heels', 'loafers'].contains(avatar.shoesId)) {
      final shoeColor = avatar.shoesId == 'loafers'
          ? const Color(0xFF73503E)
          : top;
      for (final x in [72.0, 114.0]) {
        box(x, 304, 35, 12, 6, shoeColor);
        oval(x + 7, 298, 21, 12, skin);
        if (avatar.shoesId == 'heels') {
          box(x + 24, 309, 8, 11, 2, shoeColor);
          box(x, 313, 13, 6, 2, shoeColor);
          stroke([Offset(x + 5, 301), Offset(x + 29, 301)], shoeColor, 3);
          oval(x + 25, 299, 5, 5, ExplorerTheme.sun);
        } else if (avatar.shoesId == 'loafers') {
          box(x + 3, 304, 29, 7, 3, shoeColor);
          stroke(
            [Offset(x + 11, 307), Offset(x + 23, 307)],
            ExplorerTheme.sun,
            3,
          );
        } else {
          oval(x + 9, 307, 8, 5, ExplorerTheme.paper);
          oval(x + 17, 307, 8, 5, ExplorerTheme.paper);
        }
      }
    } else if (avatar.shoesId == 'sandals' ||
        avatar.shoesId == 'strappy_sandals') {
      box(74, 298, 33, 18, 7, skin);
      box(115, 298, 33, 18, 7, skin);
      box(73, 310, 35, 7, 3, ExplorerTheme.ink);
      box(114, 310, 35, 7, 3, ExplorerTheme.ink);
      stroke(
        [const Offset(80, 300), const Offset(100, 307)],
        ExplorerTheme.ink,
        5,
      );
      stroke(
        [const Offset(122, 300), const Offset(143, 307)],
        ExplorerTheme.ink,
        5,
      );
      if (avatar.shoesId == 'strappy_sandals') {
        for (final x in [78.0, 119.0]) {
          stroke([Offset(x, 293), Offset(x + 23, 293)], top, 4);
          stroke([Offset(x, 307), Offset(x + 20, 298)], ExplorerTheme.sun, 3);
          oval(x + 20, 291, 5, 5, ExplorerTheme.sun);
        }
      }
    } else if (avatar.shoesId == 'boots') {
      box(75, 286, 31, 24, 5, const Color(0xFF97683D));
      box(115, 286, 31, 24, 5, const Color(0xFF97683D));
      box(68, 301, 40, 18, 7, const Color(0xFF704B31));
      box(114, 301, 40, 18, 7, const Color(0xFF704B31));
      for (var y = 291.0; y <= 303; y += 6) {
        stroke([Offset(83, y), Offset(99, y)], ExplorerTheme.paper, 2);
        stroke([Offset(122, y), Offset(138, y)], ExplorerTheme.paper, 2);
      }
      box(68, 315, 40, 5, 2, ExplorerTheme.ink);
      box(114, 315, 40, 5, 2, ExplorerTheme.ink);
    } else {
      if (avatar.shoesId == 'high_tops') {
        box(75, 281, 31, 27, 6, top);
        box(115, 281, 31, 27, 6, top);
        stroke(
          [const Offset(80, 286), const Offset(101, 286)],
          Colors.white,
          3,
        );
        stroke(
          [const Offset(120, 286), const Offset(141, 286)],
          Colors.white,
          3,
        );
      }
      box(68, 294, 40, 24, 9, Colors.white);
      box(114, 294, 40, 24, 9, Colors.white);
      box(68, 312, 40, 6, 3, ExplorerTheme.ink);
      box(114, 312, 40, 6, 3, ExplorerTheme.ink);
      stroke([const Offset(84, 299), const Offset(99, 299)], top, 3);
      stroke([const Offset(124, 299), const Offset(139, 299)], top, 3);
      stroke([const Offset(84, 305), const Offset(99, 305)], top, 3);
      stroke([const Offset(124, 305), const Offset(139, 305)], top, 3);
    }
    // Arms, hands and shirt silhouette.
    stroke([const Offset(71, 158), const Offset(58, 212)], skin, 19);
    stroke([const Offset(149, 158), const Offset(165, 207)], skin, 19);
    oval(46, 207, 21, 23, skin);
    oval(154, 202, 21, 23, skin);
    final shirt = Path()
      ..moveTo(92, 135)
      ..lineTo(73, 141)
      ..quadraticBezierTo(66, 143, 62, 155)
      ..lineTo(57, 174)
      ..lineTo(78, 181)
      ..lineTo(female ? 83 : 77, 202)
      ..lineTo(75, 223)
      ..quadraticBezierTo(110, 231, 145, 223)
      ..lineTo(female ? 137 : 143, 202)
      ..lineTo(142, 181)
      ..lineTo(163, 174)
      ..lineTo(156, 151)
      ..quadraticBezierTo(153, 143, 146, 141)
      ..lineTo(128, 135)
      ..close();
    canvas.drawPath(
      shirt,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(top, Colors.white, .22)!,
            top,
            Color.lerp(top, ExplorerTheme.ink, .28)!,
          ],
        ).createShader(const Rect.fromLTWH(57, 135, 106, 96)),
    );
    canvas.drawPath(
      shirt,
      Paint()
        ..color = ExplorerTheme.ink.withValues(alpha: .16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    stroke(
      [const Offset(81, 216), const Offset(110, 220), const Offset(139, 216)],
      Colors.white.withValues(alpha: .2),
      2,
    );
    box(96, 120, 28, 25, 9, skin);
    final collar = Path()
      ..moveTo(91, 138)
      ..quadraticBezierTo(110, 165, 129, 138);
    canvas.drawPath(
      collar,
      Paint()
        ..color = Colors.white.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    if (avatar.topId == 'striped_tee') {
      canvas.save();
      canvas.clipPath(shirt);
      for (var y = 166.0; y < 220; y += 14) {
        box(57, y, 106, 5, 0, Colors.white.withValues(alpha: .75));
      }
      canvas.restore();
    } else if (avatar.topId == 'varsity') {
      canvas.save();
      canvas.clipPath(shirt);
      box(56, 143, 25, 42, 5, ExplorerTheme.paper);
      box(140, 143, 25, 42, 5, ExplorerTheme.paper);
      canvas.restore();
      stroke(
        [const Offset(110, 154), const Offset(110, 221)],
        ExplorerTheme.paper,
        3,
      );
      for (var y = 163.0; y < 215; y += 13) {
        oval(113, y, 3, 3, ExplorerTheme.sun);
      }
      box(80, 210, 60, 10, 3, ExplorerTheme.paper);
      stroke(
        [
          const Offset(126, 168),
          const Offset(123, 176),
          const Offset(132, 176),
          const Offset(129, 168),
        ],
        ExplorerTheme.sun,
        3,
      );
    } else if (avatar.topId == 'barong') {
      canvas.drawPath(shirt, Paint()..color = const Color(0xFFF3E3C1));
      stroke(
        [const Offset(109, 143), const Offset(109, 219)],
        const Color(0xFFB69565),
        2,
      );
      for (var y = 160.0; y < 211; y += 12) {
        for (final x in [96.0, 124.0]) {
          stroke(
            [
              Offset(x, y - 4),
              Offset(x + 4, y),
              Offset(x, y + 4),
              Offset(x - 4, y),
              Offset(x, y - 4),
            ],
            const Color(0xFFB69565),
            1.4,
          );
        }
        oval(108, y, 3, 3, const Color(0xFFB69565));
      }
    } else if (['blouse', 'bolero', 'peplum'].contains(avatar.topId)) {
      oval(61, 143, 25, 32, top);
      oval(135, 143, 25, 32, top);
      if (avatar.topId == 'bolero') {
        box(93, 155, 34, 65, 5, ExplorerTheme.paper);
        canvas.drawPath(
          Path()
            ..moveTo(90, 140)
            ..lineTo(106, 155)
            ..lineTo(89, 185)
            ..lineTo(78, 180)
            ..close(),
          Paint()..color = top,
        );
        canvas.drawPath(
          Path()
            ..moveTo(130, 140)
            ..lineTo(114, 155)
            ..lineTo(131, 185)
            ..lineTo(142, 180)
            ..close(),
          Paint()..color = top,
        );
        oval(133, 161, 7, 7, ExplorerTheme.sun);
      } else {
        canvas.drawPath(
          Path()
            ..moveTo(110, 155)
            ..lineTo(95, 149)
            ..lineTo(95, 163)
            ..close(),
          Paint()..color = ExplorerTheme.paper,
        );
        canvas.drawPath(
          Path()
            ..moveTo(110, 155)
            ..lineTo(125, 149)
            ..lineTo(125, 163)
            ..close(),
          Paint()..color = ExplorerTheme.paper,
        );
        for (var y = 169.0; y < 208; y += 12) {
          oval(108, y, 4, 4, ExplorerTheme.paper);
        }
      }
      if (avatar.topId == 'peplum') {
        canvas.drawPath(
          Path()
            ..moveTo(84, 199)
            ..lineTo(136, 199)
            ..lineTo(153, 232)
            ..quadraticBezierTo(110, 242, 67, 232)
            ..close(),
          Paint()..color = top,
        );
        box(83, 196, 54, 6, 2, ExplorerTheme.sun);
        for (final x in [87.0, 103.0, 119.0, 135.0]) {
          stroke(
            [Offset(x, 207), Offset(x + (x - 110) * .25, 230)],
            Colors.white.withValues(alpha: .3),
            2,
          );
        }
      }
    } else if (avatar.topId == 'polo') {
      final collarLeft = Path()
        ..moveTo(90, 136)
        ..lineTo(108, 151)
        ..lineTo(91, 159)
        ..close();
      final collarRight = Path()
        ..moveTo(130, 136)
        ..lineTo(112, 151)
        ..lineTo(129, 159)
        ..close();
      canvas.drawPath(collarLeft, Paint()..color = Colors.white);
      canvas.drawPath(collarRight, Paint()..color = Colors.white);
      oval(108, 161, 4, 4, Colors.white);
      oval(108, 169, 4, 4, Colors.white);
    } else if (avatar.topId == 'jacket') {
      box(101, 151, 18, 70, 2, const Color(0xFFF8F0DD));
      stroke(
        [const Offset(94, 147), const Offset(89, 218)],
        ExplorerTheme.ink.withValues(alpha: .3),
        2,
      );
      stroke(
        [const Offset(126, 147), const Offset(131, 218)],
        ExplorerTheme.ink.withValues(alpha: .3),
        2,
      );
      box(78, 185, 16, 15, 3, Colors.white.withValues(alpha: .3));
      box(128, 185, 16, 15, 3, Colors.white.withValues(alpha: .3));
    } else if (avatar.topId == 'hoodie') {
      final hood = Path()
        ..moveTo(88, 139)
        ..quadraticBezierTo(110, 180, 132, 139);
      canvas.drawPath(
        hood,
        Paint()
          ..color = Color.lerp(top, ExplorerTheme.ink, .35)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
      stroke([const Offset(101, 154), const Offset(100, 177)], Colors.white, 2);
      stroke([const Offset(120, 154), const Offset(121, 177)], Colors.white, 2);
      box(91, 188, 38, 22, 8, Color.lerp(top, ExplorerTheme.ink, .18)!);
      stroke(
        [const Offset(97, 194), const Offset(93, 204)],
        Colors.white.withValues(alpha: .5),
        2,
      );
      stroke(
        [const Offset(123, 194), const Offset(127, 204)],
        Colors.white.withValues(alpha: .5),
        2,
      );
    } else if (avatar.topId == 'explorer') {
      box(80, 150, 25, 69, 5, const Color(0xFFC9A66D));
      box(116, 150, 25, 69, 5, const Color(0xFFC9A66D));
      for (final x in [83.0, 119.0]) {
        box(x, 176, 19, 15, 3, const Color(0xFFA7804C));
        box(x, 197, 19, 15, 3, const Color(0xFFA7804C));
        stroke(
          [Offset(x + 2, 180), Offset(x + 17, 180)],
          const Color(0xFFF2D6A3),
          2,
        );
      }
      oval(123, 157, 12, 12, ExplorerTheme.teal);
      stroke(
        [const Offset(129, 159), const Offset(129, 167)],
        ExplorerTheme.sun,
        2,
      );
      stroke(
        [const Offset(125, 163), const Offset(133, 163)],
        ExplorerTheme.sun,
        2,
      );
    } else {
      oval(124, 176, 13, 13, Colors.white.withValues(alpha: .8));
      stroke(
        [
          const Offset(127, 182),
          const Offset(130, 185),
          const Offset(134, 179),
        ],
        top,
        2,
      );
    }
    // Ears and face.
    oval(55, 73, 19, 29, skin);
    oval(146, 73, 19, 29, skin);
    oval(female ? 65 : 62, 34, female ? 90 : 96, 100, skin);
    canvas.drawOval(
      Rect.fromLTWH(female ? 65 : 62, 34, female ? 90 : 96, 100),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.4, -.5),
          radius: 1,
          colors: [
            Colors.white.withValues(alpha: .16),
            Colors.transparent,
            const Color(0x15904D24),
          ],
          stops: const [0, .6, 1],
        ).createShader(const Rect.fromLTWH(62, 34, 96, 100)),
    );
    stroke([const Offset(81, 72), const Offset(92, 70)], hair, 2.5);
    stroke([const Offset(126, 70), const Offset(138, 72)], hair, 2.5);
    oval(64, 81, 7, 11, Color.lerp(skin, const Color(0xFFB25B52), .25)!);
    oval(151, 81, 7, 11, Color.lerp(skin, const Color(0xFFB25B52), .25)!);
    oval(77, 100, 15, 7, const Color(0x44D16D6D));
    oval(128, 100, 15, 7, const Color(0x44D16D6D));
    oval(84, 78, 9, 13, ExplorerTheme.ink);
    oval(127, 78, 9, 13, ExplorerTheme.ink);
    oval(86, 80, 3, 4, Colors.white);
    oval(129, 80, 3, 4, Colors.white);
    if (female) {
      stroke(
        [const Offset(83, 82), const Offset(80, 78)],
        ExplorerTheme.ink,
        2,
      );
      stroke(
        [const Offset(136, 82), const Offset(140, 78)],
        ExplorerTheme.ink,
        2,
      );
    }
    final smile = Path()
      ..moveTo(100, 107)
      ..quadraticBezierTo(110, 116, 121, 106);
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF834239)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    stroke(
      [const Offset(109, 94), const Offset(106, 99), const Offset(112, 99)],
      Color.lerp(skin, const Color(0xFF9B6044), .3)!,
      2,
    );

    // Front hair remains above the face; hat trims the tall silhouette.
    final capOn =
        avatar.headwearId == 'cap' || avatar.headwearId == 'sport_cap';
    final hairPath = Path()
      ..moveTo(62, 82)
      ..cubicTo(44, 27, 77, 13, 111, 21)
      ..cubicTo(151, 11, 174, 41, 157, 82)
      ..lineTo(147, 67)
      ..quadraticBezierTo(127, 68, 106, 48)
      ..quadraticBezierTo(92, 68, 67, 67)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = hair);
    if (avatar.hairStyleIndex == 1) {
      for (var i = 0; i < 6; i++) {
        oval(57 + i * 15.0, 26 + (i % 2) * 6, 29, 30, hair);
      }
    } else if (avatar.hairStyleIndex == 3 && !capOn) {
      final spike = Path()
        ..moveTo(65, 41)
        ..lineTo(76, 13)
        ..lineTo(91, 25)
        ..lineTo(108, 5)
        ..lineTo(124, 24)
        ..lineTo(143, 12)
        ..lineTo(152, 44)
        ..close();
      canvas.drawPath(spike, Paint()..color = hair);
    }
    stroke(
      [const Offset(80, 39), const Offset(90, 33), const Offset(102, 31)],
      Colors.white.withValues(alpha: .12),
      4,
    );
    if (capOn) {
      box(
        60,
        23,
        99,
        34,
        17,
        avatar.headwearId == 'sport_cap' ? top : const Color(0xFFCD9D5F),
      );
      box(
        100,
        48,
        73,
        10,
        5,
        avatar.headwearId == 'sport_cap'
            ? ExplorerTheme.ink
            : const Color(0xFF98703D),
      );
      oval(99, 29, 20, 20, ExplorerTheme.paper);
      stroke(
        [const Offset(104, 39), const Offset(109, 33), const Offset(115, 39)],
        ExplorerTheme.teal,
        2,
      );
    } else if (avatar.headwearId == 'beret') {
      oval(54, 14, 112, 39, top);
      box(65, 41, 87, 10, 4, Color.lerp(top, ExplorerTheme.ink, .3)!);
      stroke([const Offset(107, 14), const Offset(111, 8)], top, 5);
      oval(137, 31, 9, 9, ExplorerTheme.sun);
    } else if (avatar.headwearId == 'crown') {
      final crown = Path()
        ..moveTo(70, 47)
        ..lineTo(64, 14)
        ..lineTo(88, 30)
        ..lineTo(110, 7)
        ..lineTo(132, 30)
        ..lineTo(156, 14)
        ..lineTo(149, 47)
        ..close();
      canvas.drawPath(crown, Paint()..color = ExplorerTheme.sun);
      box(70, 40, 79, 9, 3, const Color(0xFFF9D981));
      for (final x in [85.0, 110.0, 135.0]) {
        oval(x - 4, 33, 8, 10, const Color(0xFFC14E82));
      }
    } else if (avatar.headwearId == 'bucket') {
      final hat = Path()
        ..moveTo(68, 49)
        ..lineTo(77, 19)
        ..quadraticBezierTo(110, 8, 145, 19)
        ..lineTo(155, 49)
        ..close();
      canvas.drawPath(hat, Paint()..color = const Color(0xFF4B9B89));
      box(57, 43, 108, 15, 7, const Color(0xFF287565));
      stroke(
        [const Offset(79, 35), const Offset(143, 35)],
        const Color(0xFFA8D7BD),
        2,
      );
      box(102, 22, 18, 14, 3, ExplorerTheme.paper);
      oval(107, 25, 8, 8, ExplorerTheme.sun);
    } else if (avatar.headwearId == 'flower') {
      for (var i = 0; i < 5; i++) {
        final a = i * math.pi * 2 / 5;
        oval(143 + math.cos(a) * 8, 47 + math.sin(a) * 8, 12, 12, Colors.white);
      }
      oval(145, 49, 9, 9, ExplorerTheme.sun);
    }
    if (avatar.earringsId != 'none') {
      for (final x in [63.0, 157.0]) {
        oval(x - 3, 97, 6, 6, ExplorerTheme.sun);
        if (avatar.earringsId == 'hoops') {
          canvas.drawOval(
            Rect.fromLTWH(x - 6, 100, 12, 15),
            Paint()
              ..color = ExplorerTheme.sun
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5,
          );
        } else if (avatar.earringsId == 'star_drops') {
          stroke([Offset(x, 101), Offset(x, 109)], ExplorerTheme.sun, 2);
          final star = Path();
          for (var i = 0; i < 10; i++) {
            final angle = i * math.pi / 5 - math.pi / 2;
            final radius = i.isEven ? 7.0 : 3.0;
            final point = Offset(
              x + math.cos(angle) * radius,
              113 + math.sin(angle) * radius,
            );
            if (i == 0) {
              star.moveTo(point.dx, point.dy);
            } else {
              star.lineTo(point.dx, point.dy);
            }
          }
          canvas.drawPath(star..close(), Paint()..color = ExplorerTheme.sun);
        }
      }
    }
    if (avatar.braceletId != 'none') {
      for (final wrist in [const Offset(53, 207), const Offset(160, 202)]) {
        box(
          wrist.dx - 6,
          wrist.dy,
          18,
          avatar.braceletId == 'gem_cuff' ? 10 : 6,
          3,
          avatar.braceletId == 'woven'
              ? const Color(0xFFDE8065)
              : ExplorerTheme.sun,
        );
        if (avatar.braceletId == 'woven') {
          stroke(
            [
              Offset(wrist.dx - 3, wrist.dy + 3),
              Offset(wrist.dx + 8, wrist.dy + 3),
            ],
            ExplorerTheme.paper,
            2,
          );
        } else if (avatar.braceletId == 'gem_cuff') {
          oval(wrist.dx, wrist.dy + 2, 7, 7, const Color(0xFF40ACAE));
        }
      }
    }
    if (avatar.necklaceId != 'none') {
      final chain = Path()
        ..moveTo(92, 144)
        ..quadraticBezierTo(109, 194, 129, 144);
      canvas.drawPath(
        chain,
        Paint()
          ..color = ExplorerTheme.sun
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      if (avatar.necklaceId == 'pendant') {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(105, 169, 11, 14),
            const Radius.circular(3),
          ),
          Paint()..color = ExplorerTheme.sun,
        );
      }
      if (avatar.necklaceId == 'pearls') {
        for (var i = 0; i <= 10; i++) {
          final t = i / 10;
          oval(89 + 37 * t, 141 + 100 * t * (1 - t), 6, 6, ExplorerTheme.paper);
        }
      } else if (avatar.necklaceId == 'gem_pendant') {
        final gem = Path()
          ..moveTo(110, 166)
          ..lineTo(118, 175)
          ..lineTo(110, 185)
          ..lineTo(102, 175)
          ..close();
        canvas.drawPath(gem, Paint()..color = const Color(0xFF40ACAE));
        canvas.drawPath(
          gem,
          Paint()
            ..color = ExplorerTheme.sun
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    if (avatar.glassesId != 'none') {
      if (avatar.glassesId == 'sunglasses') {
        box(74, 73, 28, 25, 7, const Color(0xFF24485B));
        box(118, 73, 28, 25, 7, const Color(0xFF24485B));
        stroke(
          [const Offset(79, 78), const Offset(92, 78)],
          const Color(0xFF90D9DC),
          3,
        );
        stroke(
          [const Offset(123, 78), const Offset(136, 78)],
          const Color(0xFF90D9DC),
          3,
        );
      }
      final p = Paint()
        ..color = ExplorerTheme.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final radius = Radius.circular(avatar.glassesId == 'round' ? 16 : 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(74, 73, 28, 25), radius),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(118, 73, 28, 25), radius),
        p,
      );
      stroke(
        [const Offset(102, 82), const Offset(118, 82)],
        ExplorerTheme.ink,
        3,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AvatarPainter old) =>
      old.avatar != avatar || old.fullBody != fullBody;
}
