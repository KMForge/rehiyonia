import 'package:flutter/widgets.dart';

import '../features/home/screens/home_screen.dart';

abstract final class AppRouter {
  static const home = '/';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(title: 'Flutter Demo Home Page'),
  };
}
