import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/explorer_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/localization/explorer_strings.dart';
import '../widgets/avatar_stage.dart';
import '../data/avatar_catalog.dart';
import '../models/player_avatar.dart';
import '../providers/avatar_editor_provider.dart';
import '../widgets/player_avatar_widget.dart';
import '../widgets/wardrobe_purchase_dialog.dart';
import '../../profile/providers/profile_provider.dart';

class AvatarStudioScreen extends ConsumerStatefulWidget {
  const AvatarStudioScreen({super.key});
  @override
  ConsumerState<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends ConsumerState<AvatarStudioScreen> {
  String _category = 'hair';
  bool _allowPop = false;
  static const _categories = [
    'hair',
    'skin',
    'hairColor',
    'headwear',
    'glasses',
    'necklace',
    'earrings',
    'bracelet',
    'top',
    'topColor',
    'bottom',
    'bottomColor',
    'shoes',
  ];

  List<String> _items() => switch (_category) {
    'hair' => AvatarCatalog.hairs,
    'skin' => AvatarCatalog.skins,
    'hairColor' => AvatarCatalog.hairColors,
    'topColor' || 'bottomColor' => AvatarCatalog.colors,
    _ => AvatarCatalog.itemsFor(
      _category,
      ref.read(avatarEditorProvider).draft.baseId,
    ),
  };
  PlayerAvatar _withItem(PlayerAvatar a, int i) => switch (_category) {
    'hair' => a.copyWith(hairStyleIndex: i),
    'skin' => a.copyWith(skinIndex: i),
    'hairColor' => a.copyWith(hairColorIndex: i),
    'topColor' => a.copyWith(outfitColorIndex: i),
    'bottomColor' => a.copyWith(bottomColorIndex: i),
    'headwear' => a.copyWith(headwearId: _items()[i]),
    'glasses' => a.copyWith(glassesId: _items()[i]),
    'necklace' => a.copyWith(necklaceId: _items()[i]),
    'earrings' => a.copyWith(earringsId: _items()[i]),
    'bracelet' => a.copyWith(braceletId: _items()[i]),
    'top' => a.copyWith(topId: _items()[i]),
    'bottom' => a.copyWith(bottomId: _items()[i]),
    _ => a.copyWith(shoesId: _items()[i]),
  };

  Future<void> _previewPurchase(
    PlayerAvatar candidate,
    WardrobeItem item,
  ) async {
    final purchased = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WardrobePurchaseDialog(item: item, preview: candidate),
    );
    if (purchased == true && mounted) {
      ref.read(avatarEditorProvider.notifier).change(candidate);
    }
  }

  Future<void> _leave() async {
    final state = ref.read(avatarEditorProvider);
    if (state.saving) return;
    final ui = ExplorerStrings(ref.read(localizationsProvider).isEnglish);
    final leave =
        !state.isDirty ||
        await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(ui('discardTitle')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(ui('stay')),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(ui('discard')),
                  ),
                ],
              ),
            ) ==
            true;
    if (leave && mounted) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationsProvider);
    final ui = ExplorerStrings(loc.isEnglish);
    final state = ref.watch(avatarEditorProvider);
    final editor = ref.read(avatarEditorProvider.notifier);
    final a = state.draft;
    final profile = ref.watch(profileProvider);
    final items = _items();
    return PopScope(
      canPop: _allowPop || (!state.isDirty && !state.saving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.avatarStudioTitle),
          actions: [
            IconButton(
              tooltip: ui('reset'),
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: state.isDirty && !state.saving ? editor.reset : null,
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Text(
                    ui('studioHint'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        ui(
                          a.baseId == 'male'
                              ? 'maleCollection'
                              : 'femaleCollection',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Chip(
                        avatar: const Icon(
                          Icons.monetization_on_rounded,
                          color: Color(0xFFB27A14),
                        ),
                        label: Text(
                          '${profile.coins} ${ui('coins')}',
                          key: const Key('wardrobe_balance'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AvatarStage(
                    height: constraints.maxHeight < 500 ? 180 : 260,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 160),
                        child: PlayerAvatarWidget(
                          key: ValueKey(a.baseId),
                          avatar: a,
                          size: constraints.maxHeight < 500 ? 110 : 162,
                          fullBody: true,
                          showBorder: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SegmentedButton<String>(
                      key: const Key('avatar_base_selector'),
                      segments: [
                        ButtonSegment(
                          value: 'male',
                          label: Text(ui('male')),
                          icon: const Icon(Icons.face_rounded),
                        ),
                        ButtonSegment(
                          value: 'female',
                          label: Text(ui('female')),
                          icon: const Icon(Icons.face_3_rounded),
                        ),
                      ],
                      selected: {a.baseId},
                      onSelectionChanged: state.saving
                          ? null
                          : (v) => editor.switchBase(v.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                key: ValueKey('category_$c'),
                                label: Text(ui(c)),
                                selected: _category == c,
                                onSelected: state.saving
                                    ? null
                                    : (_) => setState(() => _category = c),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Wrap instead of fixed grid heights: labels survive text scaling.
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(items.length, (i) {
                      final candidate = _withItem(a, i);
                      final item = AvatarCatalog.slots.containsKey(_category)
                          ? AvatarCatalog.item(_category, items[i])
                          : null;
                      final owned =
                          item?.isOwned(profile.ownedWardrobeItems) ?? true;
                      final selected = candidate == a;
                      final isColor = [
                        'skin',
                        'hairColor',
                        'topColor',
                        'bottomColor',
                      ].contains(_category);
                      final palette = _category == 'skin'
                          ? AvatarPalette.skins
                          : _category == 'hairColor'
                          ? AvatarPalette.hair
                          : AvatarPalette.clothes;
                      return SizedBox(
                        width: (constraints.maxWidth - 50) / 2,
                        child: Semantics(
                          selected: selected,
                          button: true,
                          child: Material(
                            color: selected
                                ? const Color(0xFFE1F0EF)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: selected
                                    ? ExplorerTheme.teal
                                    : ExplorerTheme.line,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              key: ValueKey('avatar_item_${items[i]}'),
                              borderRadius: BorderRadius.circular(18),
                              onTap: state.saving
                                  ? null
                                  : () {
                                      if (!owned && item != null) {
                                        _previewPurchase(candidate, item);
                                      } else {
                                        editor.change(candidate);
                                      }
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    if (isColor)
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: palette[i],
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    else
                                      PlayerAvatarWidget(
                                        avatar: candidate,
                                        size: 62,
                                        fullBody: [
                                          'top',
                                          'bottom',
                                          'shoes',
                                          'necklace',
                                          'bracelet',
                                        ].contains(_category),
                                      ),
                                    const SizedBox(height: 8),
                                    if (item != null && item.price > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Wrap(
                                          spacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Icon(
                                              owned
                                                  ? Icons.verified_rounded
                                                  : Icons.lock_rounded,
                                              size: 16,
                                              color: owned
                                                  ? ExplorerTheme.teal
                                                  : const Color(0xFFAD4775),
                                            ),
                                            Text(
                                              owned
                                                  ? ui('owned')
                                                  : '${item.price} ${ui('coins')}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (selected)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: ExplorerTheme.teal,
                                            ),
                                          ),
                                        Flexible(
                                          child: Text(
                                            ui(items[i]),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.failed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      ui('saveFailed'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('button_save_avatar'),
                    onPressed: state.saving
                        ? null
                        : () async {
                            final saved = await editor.save();
                            if (saved && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.avatarSaved)),
                              );
                            }
                          },
                    icon: Icon(
                      state.saving
                          ? Icons.hourglass_top_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(state.saving ? ui('saving') : loc.saveAvatar),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
