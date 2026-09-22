import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_initialization_provider.dart';
import '../data/repositories/trivia_repository.dart';
import '../models/trivia_item.dart';

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return TriviaRepository(appDatabase: appDb);
});

final triviaForRegionProvider = FutureProvider.family<List<TriviaItem>, int>((
  ref,
  regionId,
) async {
  final repo = ref.watch(triviaRepositoryProvider);
  return repo.getTriviaForRegion(regionId);
});
