import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import '../../mascot/widgets/bayanito_mascot_widget.dart';
import '../../profile/providers/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = ref.watch(localizationsProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar: Player Profile Chip & Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Chip (Clickable for name edit)
                  InkWell(
                    key: const Key('button_player_profile'),
                    onTap: () =>
                        _showEditNameDialog(context, loc, ref, profile.name),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.babyBlue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBlue.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlayerAvatarWidget(
                            avatar: profile.avatar,
                            size: 32,
                            showBorder: false,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textNavy,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit_rounded,
                            size: 15,
                            color: AppColors.deepBlue,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats Pill (Coins & Stars)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.babyBlue, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: Color(0xFFFFB300),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          loc.coins(profile.coins),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textNavy,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFA000),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          loc.stars(profile.totalStars),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 14),

              // Hero Bayanito Mascot with Soft Circular Backdrop & Speech Bubble
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.7),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepBlue.withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: BayanitoMascotWidget(
                  size: 110,
                  showSpeechBubble: true,
                  speechText: loc.isEnglish
                      ? "Welcome, Explorer! Let's uncover the 18 regions of the Philippines!"
                      : 'Tara, maglakbay tayo sa 18 rehiyon ng Pilipinas!',
                ),
              ),

              const SizedBox(height: 12),

              // Game Title
              Text(
                AppConstants.appName,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pastelPink.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pastelPink.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  loc.curriculumTag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textNavy,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Primary PLAY Button with Rich Gradient and Elevation
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF1E5B99)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E5B99).withValues(alpha: 0.38),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('menu_play_button'),
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.regions);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              loc.playButton,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Island Group Exploration Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.babyBlue, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepBlue.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.explore_rounded,
                      color: AppColors.deepBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.isEnglish
                          ? '18 Regions • Luzon, Visayas, Mindanao'
                          : '18 Rehiyon • Luzon, Visayas, Mindanao',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textNavy,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2x2 Menu Grid for Secondary Actions with Pastel Gradients
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    // Avatar Studio (Rose / Coral gradient)
                    _buildMenuCard(
                      key: const Key('menu_avatar_button'),
                      icon: Icons.face_retouching_natural_rounded,
                      label: loc.avatarStudioButton,
                      gradientColors: const [
                        Color(0xFFFFF0F5),
                        Color(0xFFFFE4E8),
                      ],
                      borderColor: const Color(0xFFF8BBD0),
                      iconColor: const Color(0xFFD81B60),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.avatarStudio),
                    ),

                    // Badge Gallery (Amber / Gold gradient)
                    _buildMenuCard(
                      key: const Key('menu_badge_gallery_button'),
                      icon: Icons.military_tech_rounded,
                      label: loc.badgeGalleryButton,
                      gradientColors: const [
                        Color(0xFFFFFDF0),
                        Color(0xFFFFF8E1),
                      ],
                      borderColor: const Color(0xFFFFE082),
                      iconColor: const Color(0xFFFFA000),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.badges),
                    ),

                    // Settings (Lavender / Purple gradient)
                    _buildMenuCard(
                      key: const Key('menu_settings_button'),
                      icon: Icons.settings_rounded,
                      label: loc.settingsButton,
                      gradientColors: const [
                        Color(0xFFF6F2FF),
                        Color(0xFFEDE7F6),
                      ],
                      borderColor: const Color(0xFFD1C4E9),
                      iconColor: const Color(0xFF5C6BC0),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.settings),
                    ),

                    // About Game (Sky Blue gradient)
                    _buildMenuCard(
                      key: const Key('menu_about_button'),
                      icon: Icons.info_outline_rounded,
                      label: loc.aboutButton,
                      gradientColors: const [
                        Color(0xFFF0F8FF),
                        Color(0xFFE1F5FE),
                      ],
                      borderColor: const Color(0xFFB3E5FC),
                      iconColor: const Color(0xFF0288D1),
                      onTap: () => _showAboutDialog(context, loc),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required Key key,
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations loc) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.deepBlue),
            const SizedBox(width: 8),
            Text(loc.aboutTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.aboutContent,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.babyBlue.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: AppColors.deepBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Department of Education • Grade 5 AP Curriculum',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deepBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.closeButton),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    AppLocalizations loc,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: AppColors.deepBlue),
              const SizedBox(width: 8),
              Text(loc.customizeName, style: const TextStyle(fontSize: 18)),
            ],
          ),
          content: TextField(
            key: const Key('input_player_name'),
            controller: controller,
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: loc.enterNameHint,
              prefixIcon: const Icon(
                Icons.badge_outlined,
                color: AppColors.deepBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.cancelButton),
            ),
            FilledButton(
              key: const Key('button_save_player_name'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  ref.read(profileProvider.notifier).setPlayerName(newName);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.nameUpdatedMessage),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.deepBlue,
                    ),
                  );
                }
              },
              child: Text(loc.saveButton),
            ),
          ],
        );
      },
    );
  }
}
