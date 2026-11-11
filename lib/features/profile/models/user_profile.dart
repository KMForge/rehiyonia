import '../../../../core/constants/app_constants.dart';
import '../../avatar/models/player_avatar.dart';

class UserProfile {
  const UserProfile({
    this.name = AppConstants.defaultPlayerName,
    this.coins = AppConstants.startingCoins,
    this.totalStars = 0,
    this.avatar = const PlayerAvatar(),
    this.ownedWardrobeItems = const {},
    this.avatarPresets = const {},
  });

  final String name;
  final int coins;
  final int totalStars;
  final PlayerAvatar avatar;
  final Set<String> ownedWardrobeItems;
  final Map<String, PlayerAvatar> avatarPresets;

  UserProfile copyWith({
    String? name,
    int? coins,
    int? totalStars,
    PlayerAvatar? avatar,
    Set<String>? ownedWardrobeItems,
    Map<String, PlayerAvatar>? avatarPresets,
  }) {
    return UserProfile(
      name: name ?? this.name,
      coins: coins ?? this.coins,
      totalStars: totalStars ?? this.totalStars,
      avatar: avatar ?? this.avatar,
      ownedWardrobeItems: ownedWardrobeItems ?? this.ownedWardrobeItems,
      avatarPresets: avatarPresets ?? this.avatarPresets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          coins == other.coins &&
          totalStars == other.totalStars &&
          avatar == other.avatar &&
          ownedWardrobeItems.length == other.ownedWardrobeItems.length &&
          ownedWardrobeItems.containsAll(other.ownedWardrobeItems) &&
          avatarPresets.length == other.avatarPresets.length &&
          avatarPresets.entries.every(
            (e) => other.avatarPresets[e.key] == e.value,
          );

  @override
  int get hashCode => Object.hash(
    name,
    coins,
    totalStars,
    avatar,
    Object.hashAllUnordered(ownedWardrobeItems),
    Object.hashAllUnordered(
      avatarPresets.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
