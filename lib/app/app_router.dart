import 'package:flutter/material.dart';

import '../features/home/screens/home_screen.dart';
import '../features/regions/screens/region_selection_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/word_search/screens/word_search_screen.dart';

abstract final class AppRouter {
  static const home = '/';
  static const settings = '/settings';
  static const regions = '/regions';
  static const game = '/game';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    settings: (_) => const SettingsScreen(),
    regions: (_) => const RegionSelectionScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    if (routeSettings.name == game) {
      final regionId = (routeSettings.arguments as int?) ?? 1;
      return MaterialPageRoute<void>(
        builder: (_) => WordSearchScreen(regionId: regionId),
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
