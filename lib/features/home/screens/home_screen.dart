import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../../shared/widgets/how_to_play_dialog.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import '../../profile/providers/profile_provider.dart';
import '../../regions/models/region.dart';
import '../../regions/providers/region_provider.dart';
import '../widgets/home_discovery_cards.dart';
import '../widgets/adventure_menu.dart';
import '../widgets/pastel_adventure_background.dart';
import '../widgets/playful_explorer_stage.dart';
import '../widgets/rehiyonia_wordmark.dart';
import '../widgets/home_palette.dart';
import '../widgets/home_player_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    String copy(String en, String fil) => loc.isEnglish ? en : fil;
    final profile = ref.watch(
      profileProvider.select(
        (profile) => (
          name: profile.name,
          avatar: profile.avatar,
          coins: profile.coins,
          totalStars: profile.totalStars,
        ),
      ),
    );
    final journey = ref.watch(regionsProvider);
    final regions = journey.asData?.value ?? <Region>[];
    final completed = regions.where((r) => r.starsEarned > 0).length;
    final next = regions
        .where((r) => r.isUnlocked && r.starsEarned == 0)
        .firstOrNull;
    final total = regions.isEmpty ? 18 : regions.length;
    final mainMenu = AdventureMenu(
      startLabel: completed > 0 && next != null
          ? ui('continue')
          : copy('Start Exploring', 'Simulan ang Paglalakbay'),
      passportLabel: copy('My Travel\nPassport', 'Aking\nPasaporte'),
      dressLabel: copy('Dress your\nExplorer', 'Bihisan ang\nManlalakbay'),
      regionsLabel: copy('Explore\nRegions', 'Tuklasin ang\nRehiyon'),
      onStart: journey.isLoading || journey.hasError
          ? null
          : () => next != null && completed > 0
                ? Navigator.pushNamed(
                    context,
                    AppRouter.regionIntro,
                    arguments: next.id,
                  )
                : Navigator.pushNamed(context, AppRouter.regions),
      onPassport: () => Navigator.pushNamed(context, AppRouter.badges),
      onDress: () => Navigator.pushNamed(context, AppRouter.avatarStudio),
      onRegions: () => Navigator.pushNamed(context, AppRouter.islandGroups),
    );

    return Scaffold(
      backgroundColor: HomePalette.pink,
      body: PastelAdventureBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
                children: [
                  HomePlayerHeader(
                    avatar: profile.avatar,
                    username: profile.name,
                    greeting: ui('greeting'),
                    coins: profile.coins,
                    coinsLabel: loc.coins(profile.coins),
                    settingsLabel: loc.settingsButton,
                    onProfile: () => _showProfile(context, ref),
                    onSettings: () =>
                        Navigator.pushNamed(context, AppRouter.settings),
                  ),
                  const SizedBox(height: 18),
                  RehiyoniaWordmark(
                    title: loc.appName,
                    subtitle: copy(
                      'PHILIPPINE WORD SEARCH',
                      'WORD SEARCH NG PILIPINAS',
                    ),
                  ),
                  const SizedBox(height: 12),
                  PlayfulExplorerStage(
                    greeting: copy('Ready, explorer?', 'Handa ka na?'),
                    message: copy(
                      'Travel through regions. Find hidden words!',
                      'Maglakbay sa mga rehiyon. Hanapin ang mga salita!',
                    ),
                    regionsLabel: copy(
                      '18 regions\nto discover',
                      '18 rehiyong\ntutuklasin',
                    ),
                    avatar: profile.avatar,
                    customizeLabel: copy(
                      'Dress your explorer',
                      'Bihisan ang explorer',
                    ),
                    exploreLabel: copy(
                      'Explore the islands',
                      'Tuklasin ang mga isla',
                    ),
                    onCustomize: () =>
                        Navigator.pushNamed(context, AppRouter.avatarStudio),
                    onExplore: () =>
                        Navigator.pushNamed(context, AppRouter.islandGroups),
                  ),
                  const SizedBox(height: 18),
                  mainMenu,
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: HomePalette.cream,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(
                          color: homeInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            const Icon(
                              Icons.flag_rounded,
                              color: homeRose,
                              size: 17,
                            ),
                            Text('${ui('completed')}: $completed / $total'),
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFAD771C),
                              size: 18,
                            ),
                            Text('${profile.totalStars}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (journey.hasError)
                    TextButton.icon(
                      onPressed: () => ref.invalidate(regionsProvider),
                      icon: const Icon(Icons.refresh),
                      label: Text(ui('retry')),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      key: const Key('menu_about_button'),
                      style: TextButton.styleFrom(
                        foregroundColor: homeInk,
                        backgroundColor: HomePalette.cream,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => HowToPlayDialog(
                          title: ui('help'),
                          instructions: ui('helpText'),
                          closeLabel: loc.closeButton,
                        ),
                      ),
                      icon: const Icon(Icons.help_outline_rounded, size: 17),
                      label: Text(
                        ui('help'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
