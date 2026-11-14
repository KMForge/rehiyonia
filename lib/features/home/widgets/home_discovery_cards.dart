import 'package:flutter/material.dart';

import 'pastel_adventure_background.dart';
import 'home_palette.dart';

const homeInk = HomePalette.ink;
const homeMuted = HomePalette.muted;
const homePink = HomePalette.pink;
const homeBlue = HomePalette.blue;
const homeRose = HomePalette.rose;

class HomeQuestWelcome extends StatelessWidget {
  const HomeQuestWelcome({
    super.key,
    required this.title,
    required this.message,
    required this.explorer,
  });
  final String title;
  final String message;
  final Widget explorer;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
    decoration: BoxDecoration(
      color: homeBlue,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: const [
        BoxShadow(color: Color(0xFFCBDFEF), offset: Offset(0, 5)),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 21, color: homeRose),
                  SizedBox(width: 5),
                  Icon(Icons.star_rounded, size: 15, color: homeRose),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: homeInk,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: homeInk,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        ExcludeSemantics(
          child: SizedBox(
            width: 108,
            height: 160,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 102,
                    height: 112,
                    decoration: BoxDecoration(
                      color: homePink,
                      borderRadius: BorderRadius.circular(55),
                    ),
                  ),
                ),
                Positioned(bottom: 0, child: explorer),
                const Positioned(
                  right: 0,
                  top: 2,
                  child: Icon(Icons.star_rounded, color: homeRose, size: 24),
                ),
                const Positioned(
                  left: 0,
                  top: 32,
                  child: Icon(Icons.auto_awesome, color: homeRose, size: 17),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class HomeDestinationCard extends StatelessWidget {
  const HomeDestinationCard({
    super.key,
    required this.eyebrow,
    required this.destination,
    required this.group,
    required this.imagePath,
    required this.buttonLabel,
    required this.onStart,
  });

  final String eyebrow;
  final String destination;
  final String group;
  final String imagePath;
  final String buttonLabel;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: homeBlue,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: homeInk.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 195 + MediaQuery.textScalerOf(context).scale(120) - 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x090C2440), Color(0xD9162D48)],
                      stops: [0.25, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  right: 18,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE3ED),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            eyebrow.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: homeInk,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xDFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.explore_outlined,
                            size: 22,
                            color: homeInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 22,
                  bottom: 22,
                  right: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFF6DCE8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        destination,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: GlossyExploreButton(
              key: const Key('menu_play_button'),
              onPressed: onStart,
              label: buttonLabel,
            ),
          ),
        ],
      ),
    ),
  );
}

class HomePassportCard extends StatelessWidget {
  const HomePassportCard({
    super.key,
    required this.title,
    required this.hint,
    required this.completedLabel,
    required this.completed,
    required this.total,
    required this.stars,
    required this.onTap,
  });
  final String title;
  final String hint;
  final String completedLabel;
  final int completed;
  final int total;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: homePink,
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    color: homeRose,
                    size: 25,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star_rounded, color: homeRose, size: 21),
                const SizedBox(width: 4),
                Text(
                  '$stars',
                  style: const TextStyle(
                    color: homeRose,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: homeInk,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              hint,
              style: const TextStyle(
                color: homeMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ExcludeSemantics(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 400 ? 9 : 6;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 6) / columns;
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      total,
                      (index) => Container(
                        width: width,
                        height: 30,
                        decoration: BoxDecoration(
                          color: index < completed
                              ? homeRose
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: homeRose.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Icon(
                          index < completed
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 23,
                          color: index < completed
                              ? Colors.white
                              : homeRose.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$completedLabel: $completed / $total',
                    style: const TextStyle(
                      color: homeInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: homeRose,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class HomeIslandCard extends StatelessWidget {
  const HomeIslandCard({
    super.key,
    required this.name,
    required this.caption,
    required this.imagePath,
    required this.color,
    required this.onTap,
  });
  final String name;
  final String caption;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(22),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: Key('home_island_${name.toLowerCase()}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: homeInk,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: const TextStyle(
                    color: homeMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class HomeCollectionCard extends StatelessWidget {
  const HomeCollectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final Widget illustration;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CandyMenuSurface(
    color: color,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              illustration,
              const Spacer(),
              const Icon(Icons.north_east_rounded, size: 19, color: homeMuted),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: homeInk,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: homeMuted, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    ),
  );
}
