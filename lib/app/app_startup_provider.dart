import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/providers/app_initialization_provider.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/settings/providers/settings_provider.dart';

class StartupProgress {
  const StartupProgress({this.step = 0, this.needsName = false});
  final int step;
  final bool needsName;
  double get fraction => step / 4;
}

class StartupProgressNotifier extends Notifier<StartupProgress> {
  @override
  StartupProgress build() => const StartupProgress();
  void update(int step, {bool needsName = false}) =>
      state = StartupProgress(step: step, needsName: needsName);
}

final startupProgressProvider =
    NotifierProvider<StartupProgressNotifier, StartupProgress>(
      StartupProgressNotifier.new,
    );

/// One startup gate: never expose Home until storage and saved identity are ready.
final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.watch(appInitializationProvider.future);
  if (!ref.mounted) return;
  ref.read(startupProgressProvider.notifier).update(1);
  await ref.read(profileProvider.notifier).loadProfile();
  if (!ref.mounted) return;
  ref.read(startupProgressProvider.notifier).update(2);
  await ref.read(settingsProvider.notifier).loadSavedPreferences();
  if (!ref.mounted) return;
  ref.read(startupProgressProvider.notifier).update(3);
  final needsName = await ref
      .read(profileRepositoryProvider)
      .needsNameCreation();
  if (!ref.mounted) return;
  ref.read(startupProgressProvider.notifier).update(4, needsName: needsName);
});
