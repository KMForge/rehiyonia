import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_initialization_provider.dart';
import '../data/repositories/trivia_repository.dart';

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return TriviaRepository(appDatabase: appDb);
});
