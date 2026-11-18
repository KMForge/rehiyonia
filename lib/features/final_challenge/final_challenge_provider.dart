import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_initialization_provider.dart';
import '../regions/providers/region_provider.dart';
import 'final_challenge_catalog.dart';
import 'final_challenge_repository.dart';

final finalChallengeRepositoryProvider = Provider(
  (ref) => FinalChallengeRepository(ref.watch(appDatabaseProvider)),
);

final finalChallengeUnlockedProvider = Provider(
  (ref) =>
      finalChallengeUnlocked(ref.watch(regionsProvider).asData?.value ?? []),
);

final finalChallengeProgressProvider = FutureProvider(
  (ref) => ref.watch(finalChallengeRepositoryProvider).load(),
);

final finalTriviaPhotoCreditsProvider = FutureProvider((ref) async {
  final rows = jsonDecode(
    await rootBundle.loadString('assets/data/culture_image_credits.json'),
  ) as List;
  return {
    for (final row in rows.cast<Map<String, dynamic>>())
      row['asset_path'] as String: row,
  };
});
