import 'package:flutter/material.dart';

import '../features/avatar/screens/avatar_studio_screen.dart';
import '../features/badges/screens/badge_gallery_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learning/screens/locality_learning_cards_screen.dart';
import '../features/regions/screens/island_group_selection_screen.dart';
import '../features/regions/screens/region_intro_screen.dart';
import '../features/regions/screens/region_selection_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/trivia/screens/pre_game_trivia_screen.dart';
import '../features/word_search/screens/word_search_screen.dart';

abstract final class AppRouter {
  static const home = '/';
  static const splash = '/splash';
  static const settings = '/settings';
  static const regions = '/regions';
  static const game = '/game';
  static const avatarStudio = '/avatar-studio';
  static const badges = '/badges';
  static const islandGroups = '/island-groups';
  static const regionIntro = '/region-intro';
  static const localityCards = '/locality-cards';
  static const triviaChallenge = '/trivia-challenge';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    splash: (_) => const SplashScreen(),
    settings: (_) => const SettingsScreen(),
    avatarStudio: (_) => const AvatarStudioScreen(),
    badges: (_) => const BadgeGalleryScreen(),
    islandGroups: (_) => const IslandGroupSelectionScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    if (routeSettings.name == game) {
      final regionId = (routeSettings.arguments as int?) ?? 1;
      return MaterialPageRoute<void>(
        builder: (_) => WordSearchScreen(regionId: regionId),
        settings: routeSettings,
      );
    }

    if (routeSettings.name == regions) {
      final initialGroup = routeSettings.arguments as String?;
      return MaterialPageRoute<void>(
        builder: (_) => RegionSelectionScreen(initialGroup: initialGroup),
        settings: routeSettings,
      );
    }

    if (routeSettings.name == regionIntro) {
      final regionId = (routeSettings.arguments as int?) ?? 1;
      return MaterialPageRoute<void>(
        builder: (_) => RegionIntroScreen(regionId: regionId),
        settings: routeSettings,
      );
    }

    if (routeSettings.name == localityCards) {
      final regionId = (routeSettings.arguments as int?) ?? 1;
      return MaterialPageRoute<void>(
        builder: (_) => LocalityLearningCardsScreen(regionId: regionId),
        settings: routeSettings,
      );
    }

    if (routeSettings.name == triviaChallenge) {
      final regionId = (routeSettings.arguments as int?) ?? 1;
      return MaterialPageRoute<void>(
        builder: (_) => PreGameTriviaScreen(regionId: regionId),
        settings: routeSettings,
      );
    }

    final builder = routes[routeSettings.name];
    if (builder != null) {
      return MaterialPageRoute<void>(builder: builder, settings: routeSettings);
    }
    return null;
  }
}
