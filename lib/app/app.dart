import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class RehiyoniaApp extends StatelessWidget {
  const RehiyoniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      initialRoute: AppRouter.home,
      routes: AppRouter.routes,
    );
  }
}
