import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_initialization_provider.dart';
import '../data/repositories/word_repository.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return WordRepository(appDatabase: appDb);
});
