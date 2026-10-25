import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/features/avatar/models/player_avatar.dart';
import 'package:rehiyonia/features/profile/data/repositories/profile_repository.dart';
import 'package:rehiyonia/features/profile/models/user_profile.dart';
import 'package:rehiyonia/features/regions/providers/region_provider.dart';
import 'package:rehiyonia/features/regions/models/region.dart';

class TestRegions extends RegionsNotifier {
  @override
  Future<List<Region>> build() async => defaultPhilippineRegions;
}

class MemoryProfileRepository extends ProfileRepository {
  MemoryProfileRepository() : super(AppDatabase());
  PlayerAvatar avatar = const PlayerAvatar();
  bool failSave = false;
  @override
  Future<void> saveAvatar(PlayerAvatar value) async {
    if (failSave) throw StateError('Storage unavailable');
    avatar = value;
  }

  @override
  Future<UserProfile> load() async => UserProfile(avatar: avatar);
}
