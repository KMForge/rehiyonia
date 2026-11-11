import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_startup_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_initialization_provider.dart';
import '../widgets/animated_explorer_logo.dart';
import '../widgets/live_explorer_scene.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  static const logoDuration = Duration(milliseconds: 2500);
  static const presentationDuration = Duration(milliseconds: 7000);
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _navigating = false;
  late final AnimationController _intro;
  late final CurvedAnimation _loadingAnimation;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _intro =
        AnimationController(
          vsync: this,
          duration: SplashScreen.presentationDuration,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) setState(() {});
        });
    _loadingAnimation = CurvedAnimation(
      parent: _intro,
      curve: const Interval(2.5 / 7, 1),
    );
    _intro.addListener(() {
      if (!_showLoading && _intro.value >= 2.5 / 7 && mounted) {
        setState(() => _showLoading = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep the requested viewing time even with motion disabled. Visual widgets
    // independently render a still frame when Reduce Motion is enabled.
    if (!_intro.isAnimating && !_intro.isCompleted) {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _loadingAnimation.dispose();
    _intro.dispose();
    super.dispose();
  }

  Future<void> _enter(bool needsName) async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRouter.home,
      arguments: needsName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final english = ref.watch(localizationsProvider).isEnglish;
    final startup = ref.watch(appStartupProvider);
    final progress = ref.watch(startupProgressProvider);
    final ready = startup.hasValue && !startup.isLoading && !startup.hasError;
    // The presentation and real startup must both finish before onboarding.
    // Both the 2.5-second logo and 4.5-second loading scene finish first.
    if (ready && _intro.isCompleted && !_navigating) {
      _navigating = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _enter(progress.needsName),
      );
    }
    final labels = english
        ? [
            'Preparing island discoveries',
            'Loading your explorer',
            'Restoring preferences',
            'Checking your passport',
            'Ready to explore',
          ]
        : [
            'Inihahanda ang mga isla',
            'Ikinakarga ang manlalakbay',
            'Ibinabalik ang mga setting',
            'Sinusuri ang pasaporte',
            'Handa nang maglakbay',
          ];
    final value = ready ? 1.0 : progress.fraction;
    if (!_showLoading) {
      return Scaffold(
        key: const Key('logo_intro'),
        backgroundColor: const Color(0xFFFFF0F5),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _intro,
                builder: (_, _) => AnimatedExplorerLogo(
                  animation: AlwaysStoppedAnimation(
                    (_intro.value / (2.5 / 7)).clamp(0.0, 1.0),
                  ),
                  reduceMotion: MediaQuery.disableAnimationsOf(context),
                  height: 240,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          LiveExplorerScene(
            animation: _loadingAnimation,
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x10FFF0F5),
                  Color(0x00FFF0F5),
                  Color(0xD9261A30),
                ],
                stops: [0, .75, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 48).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          AnimatedExplorerLogo(
                            animation: _loadingAnimation,
                            reduceMotion: MediaQuery.disableAnimationsOf(
                              context,
                            ),
                            height: constraints.maxHeight < 500 ? 100 : 180,
                          ),
                          Text(
                            english
                                ? 'Find words. Discover the Philippines.'
                                : 'Maghanap ng salita. Tuklasin ang Pilipinas.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF37223F),
                              fontWeight: FontWeight.w700,
                              letterSpacing: .3,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 48),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: Column(
                              children: [
                                if (startup.hasError) ...[
                                  Text(
                                    english
                                        ? 'Your journey could not load. Please try again.'
                                        : 'Hindi maikarga ang paglalakbay. Subukan muli.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    key: const Key('startup_retry'),
                                    onPressed: () {
                                      ref
                                          .read(
                                            startupProgressProvider.notifier,
                                          )
                                          .update(0);
                                      ref.invalidate(appInitializationProvider);
                                      ref.invalidate(appStartupProvider);
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: Text(
                                      english ? 'Try again' : 'Subukan muli',
                                    ),
                                  ),
                                ] else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          labels[ready ? 4 : progress.step],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${(value * 100).round()}%',
                                        style: const TextStyle(
                                          color: Color(0xFFFFB8D3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: value),
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 280),
                                    builder: (_, v, _) =>
                                        LinearProgressIndicator(
                                          key: const Key('startup_progress'),
                                          value: v,
                                          minHeight: 8,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: const Color(0xFFFF8EB7),
                                          backgroundColor: const Color(
                                            0xFF5A3553,
                                          ),
                                          semanticsLabel: english
                                              ? 'Startup progress'
                                              : 'Pag-usad ng paghahanda',
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    english
                                        ? 'Tip: tap a word in the puzzle to discover its clue.'
                                        : 'Tip: pindutin ang salita sa palaisipan para sa pahiwatig.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFADBFCF),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
