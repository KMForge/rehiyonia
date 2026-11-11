import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/app/music_route_observer.dart';
import 'package:rehiyonia/app/app_router.dart';

void main() {
  test(
    'only splash, wardrobe and word search allow music; dialogs retain policy',
    () {
      final changes = <bool>[];
      final observer = MusicRouteObserver(changes.add);
      PageRoute<void> page(String name) => MaterialPageRoute<void>(
        settings: RouteSettings(name: name),
        builder: (_) => const SizedBox(),
      );
      final splash = page(AppRouter.splash);
      final home = page(AppRouter.home);
      final avatar = page(AppRouter.avatarStudio);
      final settings = page(AppRouter.settings);
      final game = page(AppRouter.game);
      observer.didPush(splash, null);
      observer.didReplace(newRoute: home, oldRoute: splash);
      observer.didPush(avatar, home);
      observer.didPush(settings, avatar);
      observer.didPop(settings, avatar);
      observer.didPop(avatar, home);
      observer.didPush(game, home);
      observer.didPop(game, home);
      expect(changes, [true, false, true, false, true, false, true, false]);
    },
  );
}
