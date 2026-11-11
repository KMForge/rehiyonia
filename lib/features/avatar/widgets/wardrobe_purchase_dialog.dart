import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../../profile/data/repositories/profile_repository.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/avatar_catalog.dart';
import '../models/player_avatar.dart';
import 'avatar_stage.dart';
import 'player_avatar_widget.dart';

class WardrobePurchaseDialog extends ConsumerStatefulWidget {
  const WardrobePurchaseDialog({
    super.key,
    required this.item,
    required this.preview,
  });
  final WardrobeItem item;
  final PlayerAvatar preview;
  @override
  ConsumerState<WardrobePurchaseDialog> createState() =>
      _WardrobePurchaseDialogState();
}

class _WardrobePurchaseDialogState
    extends ConsumerState<WardrobePurchaseDialog> {
  bool _buying = false;
  String? _error;

  Future<void> _buy() async {
    if (_buying) return;
    setState(() {
      _buying = true;
      _error = null;
    });
    try {
      await ref
          .read(profileProvider.notifier)
          .buyWardrobeItem(
            widget.item.slot,
            widget.item.id,
            widget.preview.baseId,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on InsufficientWardrobeCoins {
      if (mounted) {
        setState(() {
          _buying = false;
          _error = 'notEnoughCoins';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _buying = false;
          _error = 'purchaseFailed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = ExplorerStrings(ref.watch(localizationsProvider).isEnglish);
    final profile = ref.watch(profileProvider);
    final owned = widget.item.isOwned(profile.ownedWardrobeItems);
    final affordable = profile.coins >= widget.item.price;
    return PopScope(
      canPop: !_buying,
      child: AlertDialog(
        scrollable: true,
        title: Text(ui(widget.item.id)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarStage(
                height: 225,
                child: PlayerAvatarWidget(
                  avatar: widget.preview,
                  size: 142,
                  fullBody: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(ui('permanentUnlock'), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                '${ui('yourCoins')}: ${profile.coins}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (!affordable && !owned) ...[
                const SizedBox(height: 8),
                Text(
                  '${ui('needMoreCoins')}: ${widget.item.price - profile.coins}',
                  textAlign: TextAlign.center,
                ),
                Text(ui('earnCoinsHint'), textAlign: TextAlign.center),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  ui(_error!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('cancel_wardrobe_purchase'),
            onPressed: _buying ? null : () => Navigator.pop(context, false),
            child: Text(ui('keepBrowsing')),
          ),
          FilledButton.icon(
            key: const Key('buy_wardrobe_item'),
            onPressed: _buying || (!owned && !affordable)
                ? null
                : owned
                ? () => Navigator.pop(context, true)
                : _buy,
            icon: Icon(
              _buying
                  ? Icons.hourglass_top
                  : owned
                  ? Icons.check
                  : Icons.lock_open,
            ),
            label: Text(
              _buying
                  ? ui('buying')
                  : owned
                  ? ui('equip')
                  : '${ui('unlockFor')} ${widget.item.price} ${ui('coins')}',
            ),
          ),
        ],
      ),
    );
  }
}
