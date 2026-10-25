import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_startup_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_initialization_provider.dart';
import '../../profile/widgets/create_explorer_dialog.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _navigating = false;
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 900),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) setState(() {});
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else if (!_intro.isAnimating && !_intro.isCompleted) {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<void> _enter(bool needsName) async {
    if (!mounted) return;
    if (needsName) {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const CreateExplorerDialog(),
      );
    }
    if (mounted) Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final english = ref.watch(localizationsProvider).isEnglish;
    final startup = ref.watch(appStartupProvider);
    final progress = ref.watch(startupProgressProvider);
    final ready = startup.hasValue && !startup.isLoading && !startup.hasError;
    // A finite logo reveal, not a simulated loading timer. Progress can reach
    // 100% during the reveal; reduced motion bypasses it immediately.
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
    return Scaffold(
      backgroundColor: const Color(0xFF091C30),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/branding/loading-islands-v1.png',
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            cacheWidth: 1080,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: Color(0xFF123D51)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x2209182C),
                  Color(0x0009182C),
                  Color(0xF509182C),
                ],
                stops: [0, .4, 1],
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
                          Semantics(
                            label: 'Rehiyonia',
                            image: true,
                            child: FadeTransition(
                              opacity: _intro,
                              child: Image.asset(
                                'assets/images/branding/rehiyonia-logo-v1.png',
                                width: 360,
                                height: constraints.maxHeight < 500 ? 100 : 180,
                                fit: BoxFit.contain,
                                excludeFromSemantics: true,
                                errorBuilder: (_, _, _) => const Text(
                                  'REHIYONIA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            english
                                ? 'EVERY WORD. A NEW DISCOVERY.'
                                : 'BAWAT SALITA. BAGONG TUKLAS.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 48),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: Column(
                              children: [
                                Text(
                                  english
                                      ? 'Your next discovery awaits'
                                      : 'Naghihintay ang susunod mong tuklas',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  english
                                      ? 'Explore the Philippines, one word at a time.'
                                      : 'Tuklasin ang Pilipinas, isang salita bawat hakbang.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFCFDDE6),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 28),
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
                                          color: Color(0xFFFFD777),
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
                                          color: const Color(0xFFFFCF68),
                                          backgroundColor: const Color(
                                            0xFF385367,
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
