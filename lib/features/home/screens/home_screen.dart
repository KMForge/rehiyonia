import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../settings/providers/settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final audioPrefs = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Emblem / Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.map_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Game Title & Tagline
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Philippine Regional Word Search',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Araling Panlipunan • Grade 5',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 32),

                // Player Stats Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${AppConstants.startingCoins} Barya',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '0 Bituin',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Menu Buttons
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        key: const Key('menu_play_button'),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/regions');
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: const Text(
                          'MAGLARO (Play)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        key: const Key('menu_settings_button'),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/settings');
                        },
                        icon: const Icon(Icons.settings_rounded),
                        label: const Text(
                          'Mga Setting',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        key: const Key('menu_about_button'),
                        onPressed: () {
                          _showAboutDialog(context);
                        },
                        icon: const Icon(Icons.info_outline_rounded),
                        label: const Text(
                          'Tungkol sa Laro (About)',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Audio status quick indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Music',
                      icon: Icon(
                        audioPrefs.isMusicEnabled
                            ? Icons.music_note_rounded
                            : Icons.music_off_rounded,
                        color: audioPrefs.isMusicEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      onPressed: () =>
                          ref.read(settingsProvider.notifier).toggleMusic(),
                    ),
                    IconButton(
                      tooltip: 'Sound Effects',
                      icon: Icon(
                        audioPrefs.isSoundEffectsEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: audioPrefs.isSoundEffectsEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      onPressed: () => ref
                          .read(settingsProvider.notifier)
                          .toggleSoundEffects(),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.map_rounded,
        size: 48,
        color: Colors.deepPurple,
      ),
      children: const [
        Text(
          'Ang Rehiyonia ay isang offline educational word search mobile game para sa mga mag-aaral ng Grade 5 Araling Panlipunan tungkol sa mga rehiyon, lalawigan, kabisera, at kultura ng Pilipinas.',
        ),
      ],
    );
  }
}
