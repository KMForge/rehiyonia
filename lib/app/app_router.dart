import 'package:flutter/widgets.dart';

import '../features/home/screens/home_screen.dart';
import '../features/regions/screens/region_selection_screen.dart';
import '../features/settings/screens/settings_screen.dart';

abstract final class AppRouter {
  static const home = '/';
  static const settings = '/settings';
  static const regions = '/regions';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    settings: (_) => const SettingsScreen(),
    regions: (_) => const RegionSelectionScreen(),
  };
}
