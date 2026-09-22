import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';
import 'app_theme.dart';

class RehiyoniaApp extends ConsumerWidget {
  const RehiyoniaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Rehiyonia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: Locale(settings.language.code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
