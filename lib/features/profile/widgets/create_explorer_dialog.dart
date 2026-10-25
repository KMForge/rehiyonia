import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import '../providers/profile_provider.dart';

/// Cannot be dismissed until identity is durably saved. No account is required.
class CreateExplorerDialog extends ConsumerStatefulWidget {
  const CreateExplorerDialog({super.key});
  @override
  ConsumerState<CreateExplorerDialog> createState() =>
      _CreateExplorerDialogState();
}

class _CreateExplorerDialogState extends ConsumerState<CreateExplorerDialog> {
  final _name = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _saving = false;
  bool _failed = false;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await ref
          .read(profileRepositoryProvider)
          .completeNameCreation(_name.text);
      await ref.read(profileProvider.notifier).loadProfile();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final english = ref.watch(localizationsProvider).isEnglish;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        scrollable: true,
        title: Text(
          english
              ? 'Your adventure starts here'
              : 'Dito nagsisimula ang iyong paglalakbay',
        ),
        content: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerAvatarWidget(
                avatar: ref.watch(profileProvider).avatar,
                size: 86,
              ),
              const SizedBox(height: 16),
              Text(
                english
                    ? 'Choose an explorer nickname. You can change it later.'
                    : 'Pumili ng palayaw. Maaari mo itong palitan mamaya.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('first_launch_name'),
                controller: _name,
                enabled: !_saving,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: english ? 'Explorer nickname' : 'Palayaw',
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.characters.length < 2 ||
                      text.characters.length > 20 ||
                      RegExp(r'[\x00-\x1F\x7F]').hasMatch(text)) {
                    return english
                        ? 'Use 2–20 characters.'
                        : 'Gumamit ng 2–20 karakter.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _save(),
              ),
              if (_failed)
                Text(
                  english
                      ? 'Could not save. Please try again.'
                      : 'Hindi na-save. Subukan muli.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        actions: [
          FilledButton.icon(
            key: const Key('create_explorer_button'),
            onPressed: _saving ? null : _save,
            icon: Icon(_saving ? Icons.hourglass_top : Icons.explore_rounded),
            label: Text(
              _saving
                  ? (english ? 'Saving…' : 'Sine-save…')
                  : (english ? 'Begin adventure' : 'Simulan ang paglalakbay'),
            ),
          ),
        ],
      ),
    );
  }
}
