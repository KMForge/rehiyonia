import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../profile/providers/profile_provider.dart';
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
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Player Account Section
          Text(
            loc.accountSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                profile.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(loc.customizeName),
              trailing: IconButton(
                key: const Key('button_settings_edit_name'),
                icon: const Icon(Icons.edit_rounded),
                onPressed: () =>
                    _showEditNameDialog(context, loc, ref, profile.name),
              ),
            ),
          ),

          const Divider(height: 32),

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
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(loc.customizeName, style: const TextStyle(fontSize: 18)),
            ],
          ),
          content: TextField(
            key: const Key('input_settings_player_name'),
            controller: controller,
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: loc.enterNameHint,
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.cancelButton),
            ),
            FilledButton(
              key: const Key('button_settings_save_name'),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  ref.read(profileProvider.notifier).setPlayerName(newName);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.nameUpdatedMessage),
                      duration: const Duration(seconds: 2),
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
