import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class RehiyoniaApp extends StatelessWidget {
  const RehiyoniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehiyonia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
