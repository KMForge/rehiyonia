import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_initialization_provider.dart';
import '../data/repositories/word_repository.dart';
import '../models/regional_word.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return WordRepository(appDatabase: appDb);
});

final wordsForRegionProvider = FutureProvider.family<List<RegionalWord>, int>((
  ref,
  regionId,
) async {
  final repo = ref.watch(wordRepositoryProvider);
  return repo.getWordsForRegion(regionId);
});
