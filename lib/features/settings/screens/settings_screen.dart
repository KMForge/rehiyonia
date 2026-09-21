import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/app_language.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final audioPrefs = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final loc = ref.watch(localizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Language Section
          Text(
            loc.languageSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.languageSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SegmentedButton<AppLanguage>(
                key: const Key('settings_language_selector'),
                segments: const [
                  ButtonSegment<AppLanguage>(
                    value: AppLanguage.english,
                    label: Text('English'),
                    icon: Icon(Icons.language_rounded),
                  ),
                  ButtonSegment<AppLanguage>(
                    value: AppLanguage.tagalog,
                    label: Text('Tagalog'),
                    icon: Icon(Icons.translate_rounded),
                  ),
                ],
                selected: {audioPrefs.language},
                onSelectionChanged: (newSelection) {
                  notifier.setLanguage(newSelection.first);
                },
              ),
            ),
          ),

          const Divider(height: 36),

          // Audio Section
          Text(
            loc.audioSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(loc.musicTitle),
            subtitle: Text(loc.musicSubtitle),
            value: audioPrefs.isMusicEnabled,
            onChanged: (_) => notifier.toggleMusic(),
            secondary: const Icon(Icons.music_note_rounded),
          ),
          SwitchListTile(
            title: Text(loc.sfxTitle),
            subtitle: Text(loc.sfxSubtitle),
            value: audioPrefs.isSoundEffectsEnabled,
            onChanged: (_) => notifier.toggleSoundEffects(),
            secondary: const Icon(Icons.volume_up_rounded),
          ),
          const Divider(height: 32),
          Text(
            loc.volumeTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: audioPrefs.volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(audioPrefs.volume * 100).round()}%',
            onChanged: (value) => notifier.setVolume(value),
          ),
        ],
      ),
    );
  }
}
