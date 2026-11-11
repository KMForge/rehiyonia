import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/app_initialization_provider.dart';
import '../../avatar/models/player_avatar.dart';
import '../data/repositories/profile_repository.dart';
import '../models/user_profile.dart';

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(appDatabaseProvider)),
);

class ProfileNotifier extends Notifier<UserProfile> {
  int _revision = 0;
  @override
  UserProfile build() => const UserProfile();

  Future<void> loadProfile() async {
    final revision = _revision;
    final loaded = await ref.read(profileRepositoryProvider).load();
    if (ref.mounted && revision == _revision) state = loaded;
  }

  Future<void> setPlayerName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (ref.read(appDatabaseProvider).isOpen) {
      await ref.read(profileRepositoryProvider).saveName(trimmed);
    }
    _revision++;
    if (ref.mounted) state = state.copyWith(name: trimmed);
  }

  Future<void> setAvatar(
    PlayerAvatar avatar, {
    Map<String, PlayerAvatar>? presets,
  }) async {
    await ref
        .read(profileRepositoryProvider)
        .saveAvatar(avatar, presets: presets);
    if (!ref.mounted) return;
    _revision++;
    state = state.copyWith(
      avatar: avatar,
      avatarPresets: Map.unmodifiable({
        ...state.avatarPresets,
        ...?presets,
        avatar.baseId: avatar,
      }),
    );
  }

  Future<WardrobePurchase> buyWardrobeItem(
    String slot,
    String id,
    String base,
  ) async {
    final result = await ref
        .read(profileRepositoryProvider)
        .buyWardrobeItem(slot, id, base);
    if (ref.mounted) {
      _revision++;
      state = state.copyWith(
        coins: result.coins,
        ownedWardrobeItems: result.owned,
      );
    }
    return result;
  }

  Future<void> setCoins(int amount) async {
    final value = amount < 0 ? 0 : amount;
    if (ref.read(appDatabaseProvider).isOpen) {
      await ref
          .read(profileRepositoryProvider)
          .saveValue(AppConstants.keyCoins, '$value');
    }
    _revision++;
    if (ref.mounted) state = state.copyWith(coins: value);
  }

  Future<void> addCoins(int amount) async {
    if (!ref.read(appDatabaseProvider).isOpen) {
      await setCoins(state.coins + amount);
      return;
    }
    final value = await ref.read(profileRepositoryProvider).addCoins(amount);
    if (ref.mounted) {
      _revision++;
      state = state.copyWith(coins: value);
    }
  }

  Future<void> addStars(int amount) async {
    final value = state.totalStars + amount;
    if (ref.read(appDatabaseProvider).isOpen) {
      await ref
          .read(profileRepositoryProvider)
          .saveValue(AppConstants.keyTotalStars, '$value');
    }
    _revision++;
    if (ref.mounted) state = state.copyWith(totalStars: value);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
