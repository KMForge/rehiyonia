import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'app_startup_provider.dart';
import 'music_route_observer.dart';
import '../core/constants/app_constants.dart';
import '../core/services/audio_service.dart';

class RehiyoniaApp extends ConsumerStatefulWidget {
  const RehiyoniaApp({super.key});

  @override
  ConsumerState<RehiyoniaApp> createState() => _RehiyoniaAppState();
}

class _RehiyoniaAppState extends ConsumerState<RehiyoniaApp>
    with WidgetsBindingObserver {
  AudioService? _audio;
  bool _ready = false;
  bool _active = true;
  bool _musicScreen = false;
  late final MusicRouteObserver _musicObserver;

  @override
  void initState() {
    super.initState();
    _musicObserver = MusicRouteObserver((enabled) {
      _musicScreen = enabled;
      _syncMusic();
    });
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _active = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  void _syncMusic() {
    if (!_ready) return;
    final AudioService audio =
        _audio ?? ref.read<AudioService>(audioServiceProvider);
    _audio = audio;
    audio.setBackgroundMusic(
      AppConstants.audioMusicMainTheme,
      active: _active && _musicScreen,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _syncMusic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audio?.setBackgroundMusic(AppConstants.audioMusicMainTheme, active: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    ref.listen(startupProgressProvider, (_, progress) {
      if (progress.step >= 3 && !_ready) {
        _ready = true;
        _syncMusic();
      }
    });

    return MaterialApp(
      title: 'Rehiyonia',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_musicObserver],
      theme: AppTheme.light,
      locale: Locale(settings.language.code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              MediaQuery.disableAnimationsOf(context) || settings.reduceMotion,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: AppRouter.splash,
      onGenerateInitialRoutes: (_) => [
        AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.splash))!,
      ],
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
