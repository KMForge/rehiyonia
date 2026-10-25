import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/explorer_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../../shared/widgets/explorer_card.dart';
import '../../../shared/widgets/journey_landscape.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import '../../profile/providers/profile_provider.dart';
import '../../regions/models/region.dart';
import '../../regions/providers/region_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    final profile = ref.watch(profileProvider);
    final journey = ref.watch(regionsProvider);
    final regions = journey.asData?.value ?? <Region>[];
    final completed = regions.where((r) => r.starsEarned > 0).length;
    final next = regions
        .where((r) => r.isUnlocked && r.starsEarned == 0)
        .firstOrNull;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Row(
                  children: [
                    InkWell(
                      key: const Key('button_player_profile'),
                      borderRadius: BorderRadius.circular(32),
                      onTap: () => _showProfile(context, ref),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: PlayerAvatarWidget(
                          avatar: profile.avatar,
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ui('greeting'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            profile.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: loc.coins(profile.coins),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEAB8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.toll_rounded,
                              size: 20,
                              color: Color(0xFF886000),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${profile.coins}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  loc.appName,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  loc.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                JourneyLandscape(
                  height: 228,
                  group: next?.islandGroup ?? 'Luzon',
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 20,
                        right: 148,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ui('journey').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              next == null
                                  ? ui('explore')
                                  : (loc.isEnglish
                                        ? next.designation
                                        : next.name),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 0,
                        child: PlayerAvatarWidget(
                          avatar: profile.avatar,
                          size: 140,
                          fullBody: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('menu_play_button'),
                  onPressed: journey.hasError
                      ? null
                      : () => next != null && completed > 0
                            ? Navigator.pushNamed(
                                context,
                                AppRouter.regionIntro,
                                arguments: next.id,
                              )
                            : Navigator.pushNamed(context, AppRouter.regions),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    completed > 0 && next != null
                        ? ui('continue')
                        : ui('start'),
                  ),
                ),
                if (journey.hasError)
                  TextButton.icon(
                    onPressed: () => ref.invalidate(regionsProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(ui('retry')),
                  ),
                const SizedBox(height: 20),
                ExplorerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_stories_rounded,
                            color: ExplorerTheme.teal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ui('passport'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${profile.totalStars}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFF9D6900),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: regions.isEmpty ? 0 : completed / regions.length,
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: const Color(0xFFE6EEEE),
                        color: ExplorerTheme.teal,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${ui('completed')}: $completed / ${regions.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _action(
                  context,
                  key: const Key('menu_avatar_button'),
                  icon: Icons.checkroom_rounded,
                  title: ui('dress'),
                  subtitle: loc.avatarStudioButton,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRouter.avatarStudio),
                ),
                const SizedBox(height: 10),
                _action(
                  context,
                  key: const Key('menu_badge_gallery_button'),
                  icon: Icons.workspace_premium_rounded,
                  title: ui('passport'),
                  subtitle: loc.badgeGalleryButton,
                  onTap: () => Navigator.pushNamed(context, AppRouter.badges),
                ),
                const SizedBox(height: 10),
                _action(
                  context,
                  icon: Icons.explore_outlined,
                  title: ui('explore'),
                  subtitle: 'Luzon · Visayas · Mindanao',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRouter.islandGroups),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      key: const Key('menu_settings_button'),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.settings),
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      label: Text(loc.settingsButton),
                    ),
                    TextButton.icon(
                      key: const Key('menu_about_button'),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(ui('help')),
                          content: Text(ui('helpText')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(loc.closeButton),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.help_outline_rounded, size: 20),
                      label: Text(ui('help')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _action(
    BuildContext context, {
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Card(
    child: ListTile(
      key: key,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Icon(icon, color: ExplorerTheme.teal, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
    ),
  );

  Future<void> _showProfile(BuildContext context, WidgetRef ref) async {
    final loc = ref.read(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    final profile = ref.read(profileProvider);
    final controller = TextEditingController(text: profile.name);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ui('profile')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerAvatarWidget(
                avatar: profile.avatar,
                size: 112,
                fullBody: true,
              ),
              const SizedBox(height: 12),
              Text(
                '${loc.coins(profile.coins)} · ${loc.stars(profile.totalStars)}',
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('input_player_name'),
                controller: controller,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: ui('editName'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancelButton),
          ),
          FilledButton(
            key: const Key('button_save_player_name'),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              try {
                await ref
                    .read(profileProvider.notifier)
                    .setPlayerName(controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(ui('saveFailed'))));
                }
              }
            },
            child: Text(loc.saveButton),
          ),
        ],
      ),
    );
    // The dialog's reverse transition may still use its controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
  }
}
