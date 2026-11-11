import 'package:flutter/material.dart';

import 'app_router.dart';

/// Dialogs retain the underlying screen's music policy.
class MusicRouteObserver extends NavigatorObserver {
  MusicRouteObserver(this.onChanged);
  final void Function(bool enabled) onChanged;
  final List<Route<dynamic>> _pages = [];
  void _notify() {
    final name = _pages.isEmpty ? null : _pages.last.settings.name;
    onChanged(
      {AppRouter.splash, AppRouter.avatarStudio, AppRouter.game}.contains(name),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      _pages.add(route);
      _notify();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_pages.remove(route)) _notify();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_pages.remove(route)) _notify();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _pages.indexOf(oldRoute);
    if (index >= 0) {
      _pages.removeAt(index);
      if (newRoute is PageRoute) _pages.insert(index, newRoute);
    } else if (newRoute is PageRoute) {
      _pages.add(newRoute);
    }
    _notify();
  }
}
