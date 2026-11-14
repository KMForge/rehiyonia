import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../avatar/models/player_avatar.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import '../../badges/region_landmark.dart';

/// The region's bundled, credited photograph behind the saved player avatar.
class RegionLandmarkScene extends StatelessWidget {
  const RegionLandmarkScene({
    super.key,
    required this.avatar,
    required this.landmark,
    required this.english,
    required this.onRetry,
    this.hasError = false,
  });

  final PlayerAvatar avatar;
  final RegionLandmark? landmark;
  final bool english, hasError;
  final VoidCallback onRetry;

  Alignment get _photoAlignment => switch (landmark?.regionId) {
    1 || 3 || 9 => const Alignment(0, -.6),
    13 => const Alignment(0, -.65),
    16 => Alignment.bottomCenter,
    _ => Alignment.center,
  };

  @override
  Widget build(BuildContext context) => Container(
    height: 240,
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFFDFF3FF),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFF1BED7)),
    ),
    child: Stack(
      children: [
        if (landmark case final photo?)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Image.asset(
                photo.assetPath,
                fit: BoxFit.cover,
                alignment: _photoAlignment,
                cacheWidth: 960,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Color(0xFFDFF3FF)),
              ),
            ),
          ),
        if (landmark case final photo?)
          Positioned.fill(
            child: Image.asset(
              photo.assetPath,
              key: ValueKey('region_landmark_photo_${photo.regionId}'),
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              cacheWidth: 960,
              gaplessPlayback: true,
              semanticLabel: '${photo.name}, ${photo.location}',
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFDFF3FF),
                child: Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x33FFF2E4), Color(0x00FFF2E4)],
                stops: [0, .35],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: PlayerAvatarWidget(
              key: const Key('region_explorer_avatar'),
              avatar: avatar,
              size: 104,
              fullBody: true,
              showBorder: false,
            ),
          ),
        ),
        if (landmark case final photo?) ...[
          Positioned(
            left: 12,
            right: 60,
            top: 12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEEFFF2E4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  photo.name,
                  textAlign: TextAlign.left,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3A174D),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filledTonal(
              key: const Key('region_photo_credits'),
              tooltip: english ? 'Photo credits' : 'Pagkilala sa larawan',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xEEFFF2E4),
                foregroundColor: const Color(0xFF3A174D),
              ),
              icon: const Icon(Icons.info_outline_rounded, size: 20),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFFFFF2E4),
                  scrollable: true,
                  title: Text(
                    english ? 'Photo credits' : 'Pagkilala sa larawan',
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${photo.name}\n${photo.location}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text('${photo.author} · ${photo.license}'),
                      const SizedBox(height: 12),
                      SelectableText(photo.sourceUrl),
                      if (photo.licenseUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SelectableText(photo.licenseUrl),
                      ],
                      const SizedBox(height: 12),
                      Text(photo.modifications),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(english ? 'Close' : 'Isara'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (hasError)
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              tooltip: english ? 'Retry photo' : 'Subukang muli ang larawan',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
      ],
    ),
  );
}
