import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_provider.dart';
import '../models/player_avatar.dart';

class AvatarEditorState {
  const AvatarEditorState({
    required this.saved,
    required this.draft,
    this.saving = false,
    this.failed = false,
    this.savedPresets = const {},
    this.draftPresets = const {},
  });
  final PlayerAvatar saved, draft;
  final bool saving, failed;
  final Map<String, PlayerAvatar> savedPresets, draftPresets;
  bool get isDirty =>
      saved != draft ||
      savedPresets.length != draftPresets.length ||
      draftPresets.entries.any((e) => savedPresets[e.key] != e.value);
}

class AvatarEditor extends Notifier<AvatarEditorState> {
  @override
  AvatarEditorState build() {
    final profile = ref.read(profileProvider);
    final avatar = profile.avatar;
    final presets = Map<String, PlayerAvatar>.unmodifiable({
      ...profile.avatarPresets,
      avatar.baseId: avatar,
    });
    return AvatarEditorState(
      saved: avatar,
      draft: avatar,
      savedPresets: presets,
      draftPresets: presets,
    );
  }

  void change(PlayerAvatar avatar) {
    if (!state.saving) {
      state = AvatarEditorState(
        saved: state.saved,
        draft: avatar,
        savedPresets: state.savedPresets,
        draftPresets: Map.unmodifiable({
          ...state.draftPresets,
          avatar.baseId: avatar,
        }),
      );
    }
  }

  void switchBase(String base) {
    if (base != 'male' && base != 'female') return;
    change(state.draftPresets[base] ?? PlayerAvatar.starter(base));
  }

  void reset() {
    if (state.saving) return;
    state = AvatarEditorState(
      saved: state.saved,
      draft: state.saved,
      savedPresets: state.savedPresets,
      draftPresets: state.savedPresets,
    );
  }

  Future<bool> save() async {
    if (state.saving) return false;
    final before = state;
    state = AvatarEditorState(
      saved: before.saved,
      draft: before.draft,
      saving: true,
      savedPresets: before.savedPresets,
      draftPresets: before.draftPresets,
    );
    try {
      await ref
          .read(profileProvider.notifier)
          .setAvatar(before.draft, presets: before.draftPresets);
      if (!ref.mounted) return false;
      state = AvatarEditorState(
        saved: before.draft,
        draft: before.draft,
        savedPresets: before.draftPresets,
        draftPresets: before.draftPresets,
      );
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = AvatarEditorState(
          saved: before.saved,
          draft: before.draft,
          failed: true,
          savedPresets: before.savedPresets,
          draftPresets: before.draftPresets,
        );
      }
      return false;
    }
  }
}

final avatarEditorProvider =
    NotifierProvider.autoDispose<AvatarEditor, AvatarEditorState>(
      AvatarEditor.new,
    );
