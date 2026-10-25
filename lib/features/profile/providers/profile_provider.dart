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

  Future<void> setAvatar(PlayerAvatar avatar) async {
    await ref.read(profileRepositoryProvider).saveAvatar(avatar);
    if (!ref.mounted) return;
    _revision++;
    state = state.copyWith(avatar: avatar);
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

  Future<void> addCoins(int amount) => setCoins(state.coins + amount);

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
