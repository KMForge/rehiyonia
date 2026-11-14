import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../providers/region_provider.dart';

class IslandGroupSelectionScreen extends ConsumerWidget {
  const IslandGroupSelectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDFF3FF),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF3A174D),
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.selectIslandGroup,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDFF3FF), Color(0xFFFFF4E7), Color(0xFFFFD6EB)],
            stops: [0, .4, 1],
          ),
        ),
        child: SizedBox.expand(
          child: ref
              .watch(regionsProvider)
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(regionsProvider),
                    child: Text(ui('retry')),
                  ),
                ),
                data: (regions) => SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: ['Luzon', 'Visayas', 'Mindanao'].map((group) {
                          final entries = regions
                              .where((r) => r.islandGroup == group)
                              .toList();
                          final completed = entries
                              .where((r) => r.starsEarned > 0)
                              .length;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _IslandGroupPhotoCard(
                              group: group,
                              progress:
                                  '${loc.regionsCount(entries.length)} · ${ui('completed')}: $completed',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRouter.regions,
                                arguments: group,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _IslandGroupPhotoCard extends StatelessWidget {
  const _IslandGroupPhotoCard({
    required this.group,
    required this.progress,
    required this.onTap,
  });

  final String group, progress;
  final VoidCallback onTap;

  String get landmark => switch (group) {
    'Luzon' => 'Mayon Volcano, Albay',
    'Visayas' => 'Chocolate Hills, Bohol',
    _ => 'Maria Cristina Falls, Iligan City',
  };

  String get photoPath =>
      'assets/images/region_landmarks/${switch (group) {
        'Luzon' => 'region_v_mayon_volcano',
        'Visayas' => 'region_vii_chocolate_hills',
        _ => 'region_x_maria_cristina_falls',
      }}.jpg';

  @override
  Widget build(BuildContext context) {
    final portrait = group == 'Mindanao';
    final background = Image.asset(
      photoPath,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -.35),
      cacheWidth: 960,
      excludeFromSemantics: true,
    );
    return Card(
      key: ValueKey('island_group_$group'),
      color: const Color(0xFF243D4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFF1BED6), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: portrait
                    ? ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: background,
                      )
                    : background,
              ),
            ),
            // Preserve the complete portrait waterfall against a matching
            // photo backdrop instead of cropping away its top and bottom.
            if (portrait)
              Positioned.fill(
                child: Image.asset(
                  photoPath,
                  fit: BoxFit.contain,
                  cacheWidth: 480,
                  excludeFromSemantics: true,
                ),
              ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x000C2435),
                      Color(0x330C2435),
                      Color(0xF20C2435),
                    ],
                    stops: [0, .45, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 150, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          landmark,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progress,
                          style: const TextStyle(
                            color: Color(0xFFE3F4FF),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
