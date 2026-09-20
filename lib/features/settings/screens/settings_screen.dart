import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final audioPrefs = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Mga Setting (Settings)')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Tunog at Musika (Audio)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Musika sa Background (Music)'),
            subtitle: const Text(
              'I-play ang pampasiglang tugtugin habang naglalaro',
            ),
            value: audioPrefs.isMusicEnabled,
            onChanged: (_) => notifier.toggleMusic(),
            secondary: const Icon(Icons.music_note_rounded),
          ),
          SwitchListTile(
            title: const Text('Mga Tunog ng Laro (Sound Effects)'),
            subtitle: const Text('Tunog sa pagpili ng salita at pagpindot'),
            value: audioPrefs.isSoundEffectsEnabled,
            onChanged: (_) => notifier.toggleSoundEffects(),
            secondary: const Icon(Icons.volume_up_rounded),
          ),
          const Divider(height: 32),
          Text(
            'Lakas ng Tunog (Volume)',
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
