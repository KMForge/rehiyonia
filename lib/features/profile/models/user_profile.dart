import '../../../../core/constants/app_constants.dart';
import '../../avatar/models/player_avatar.dart';

class UserProfile {
  const UserProfile({
    this.name = AppConstants.defaultPlayerName,
    this.coins = AppConstants.startingCoins,
    this.totalStars = 0,
    this.avatar = const PlayerAvatar(),
  });

  final String name;
  final int coins;
  final int totalStars;
  final PlayerAvatar avatar;

  UserProfile copyWith({
    String? name,
    int? coins,
    int? totalStars,
    PlayerAvatar? avatar,
  }) {
    return UserProfile(
      name: name ?? this.name,
      coins: coins ?? this.coins,
      totalStars: totalStars ?? this.totalStars,
      avatar: avatar ?? this.avatar,
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
          avatar == other.avatar;

  @override
  int get hashCode => Object.hash(name, coins, totalStars, avatar);
}
