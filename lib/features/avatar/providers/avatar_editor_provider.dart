import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_provider.dart';
import '../models/player_avatar.dart';

class AvatarEditorState {
  const AvatarEditorState({
    required this.saved,
    required this.draft,
    this.saving = false,
    this.failed = false,
  });
  final PlayerAvatar saved, draft;
  final bool saving, failed;
  bool get isDirty => saved != draft;
}

class AvatarEditor extends Notifier<AvatarEditorState> {
  @override
  AvatarEditorState build() {
    final avatar = ref.read(profileProvider).avatar;
    return AvatarEditorState(saved: avatar, draft: avatar);
  }

  void change(PlayerAvatar avatar) {
    if (!state.saving) {
      state = AvatarEditorState(saved: state.saved, draft: avatar);
    }
  }

  void reset() => change(state.saved);
  Future<bool> save() async {
    if (state.saving) return false;
    final before = state;
    state = AvatarEditorState(
      saved: before.saved,
      draft: before.draft,
      saving: true,
    );
    try {
      await ref.read(profileProvider.notifier).setAvatar(before.draft);
      if (!ref.mounted) return false;
      state = AvatarEditorState(saved: before.draft, draft: before.draft);
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = AvatarEditorState(
          saved: before.saved,
          draft: before.draft,
          failed: true,
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
