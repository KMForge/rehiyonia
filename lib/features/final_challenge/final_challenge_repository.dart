import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/database_constants.dart';
import '../../core/database/app_database.dart';
import '../regions/models/region.dart';
import 'final_challenge_catalog.dart';

class FinalChallengeRound {
  const FinalChallengeRound({
    required this.regionIds,
    required this.seed,
    this.found = const {},
    this.hints = const {},
    this.bestStars = 0,
    this.includeTriviaWords = true,
  });
  final List<int> regionIds;
  final int seed, bestStars;
  final Set<String> found, hints;
  final bool includeTriviaWords;
  bool get completed => found.length == 15;
  int get stars => completed
      ? (hints.isEmpty
            ? 3
            : hints.length <= 2
            ? 2
            : 1)
      : 0;
  List<FinalChallengeClue> get clues => [
    for (var i = 0; i < regionIds.length; i++)
      (includeTriviaWords && i.isOdd ? finalTriviaWords : finalChallengeCatalog)
          .firstWhere((clue) => clue.regionId == regionIds[i]),
  ];
  Map<String, dynamic> toJson() => {
    'regions': regionIds,
    'seed': seed,
    'found': found.toList(),
    'hints': hints.toList(),
    'best_stars': max(bestStars, stars),
    'include_trivia_words': includeTriviaWords,
  };
  factory FinalChallengeRound.fromJson(Map<String, dynamic> json) {
    final round = FinalChallengeRound(
      regionIds: (json['regions'] as List).cast<int>(),
      seed: json['seed'] as int,
      found: (json['found'] as List).cast<String>().toSet(),
      hints: (json['hints'] as List).cast<String>().toSet(),
      bestStars: json['best_stars'] as int? ?? 0,
      // Existing rounds retain their original grid and discoveries.
      includeTriviaWords: json['include_trivia_words'] as bool? ?? false,
    );
    final ids = finalChallengeCatalog.map((clue) => clue.regionId).toSet();
    if (round.regionIds.length != 15 ||
        round.regionIds.toSet().length != 15 ||
        !ids.containsAll(round.regionIds)) {
      throw const FormatException('Invalid final challenge selection');
    }
    final words = round.clues.map((clue) => clue.word).toSet();
    if (!words.containsAll(round.found) || !words.containsAll(round.hints)) {
      throw const FormatException('Invalid final challenge progress');
    }
    return round;
  }
}

class FinalChallengeUpdate {
  const FinalChallengeUpdate(this.round, this.coins);
  final FinalChallengeRound round;
  final int coins;
}

/// Uses only existing user_progress and coin records; never creates a region.
class FinalChallengeRepository {
  const FinalChallengeRepository(this.database);
  final AppDatabase database;
  static const progressKey = 'final_mixed_challenge_v1';

  Future<String?> _value(DatabaseExecutor db, String key) async {
    final rows = await db.query(
      DatabaseConstants.tableUserProgress,
      where: '${DatabaseConstants.columnKey} = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : rows.first[DatabaseConstants.columnValue] as String;
  }

  Future<void> _put(DatabaseExecutor db, String key, String value) => db
      .insert(DatabaseConstants.tableUserProgress, {
        DatabaseConstants.columnKey: key,
        DatabaseConstants.columnValue: value,
        DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace)
      .then((_) {});

  Future<void> _checkUnlocked(DatabaseExecutor db) async {
    final rows = await db.query(DatabaseConstants.tableRegions);
    if (!finalChallengeUnlocked(rows.map(Region.fromMap))) {
      throw StateError(
        'Complete all 18 regions to unlock the final challenge.',
      );
    }
  }

  Future<FinalChallengeRound?> _load(DatabaseExecutor db) async {
    final value = await _value(db, progressKey);
    return value == null
        ? null
        : FinalChallengeRound.fromJson(
            jsonDecode(value) as Map<String, dynamic>,
          );
  }

  Future<FinalChallengeRound?> load() => _load(database.database);

  Future<FinalChallengeRound> start({int? seed, bool replay = false}) =>
      database.database.transaction((txn) async {
        await _checkUnlocked(txn);
        final previous = await _load(txn);
        if (previous != null && (!replay || !previous.completed)) {
          if (!previous.includeTriviaWords &&
              previous.found.isEmpty &&
              previous.hints.isEmpty) {
            final updated = FinalChallengeRound(
              regionIds: previous.regionIds,
              seed: previous.seed,
              bestStars: previous.bestStars,
            );
            await _put(txn, progressKey, jsonEncode(updated.toJson()));
            return updated;
          }
          return previous;
        }
        final chosenSeed = seed ?? Random().nextInt(0x7fffffff);
        final round = FinalChallengeRound(
          regionIds: selectFinalRegions(chosenSeed),
          seed: chosenSeed,
          bestStars: previous?.bestStars ?? 0,
        );
        await _put(txn, progressKey, jsonEncode(round.toJson()));
        return round;
      });

  /// Progress and coins commit together, so reopening or repeated taps cannot
  /// award the same discovery twice. Regional stars and badges are untouched.
  Future<FinalChallengeUpdate> discover(String word) =>
      database.database.transaction((txn) async {
        await _checkUnlocked(txn);
        final old = await _load(txn);
        if (old == null || !old.clues.any((clue) => clue.word == word)) {
          throw StateError('No matching final challenge word');
        }
        final coins =
            int.tryParse(await _value(txn, AppConstants.keyCoins) ?? '') ??
            AppConstants.startingCoins;
        if (old.found.contains(word)) return FinalChallengeUpdate(old, coins);
        final round = FinalChallengeRound(
          regionIds: old.regionIds,
          seed: old.seed,
          found: {...old.found, word},
          hints: old.hints,
          bestStars: old.bestStars,
          includeTriviaWords: old.includeTriviaWords,
        );
        final balance = coins + (round.completed ? 20 : 5);
        await _put(txn, progressKey, jsonEncode(round.toJson()));
        await _put(txn, AppConstants.keyCoins, '$balance');
        await txn.update(DatabaseConstants.tablePlayerProfile, {
          DatabaseConstants.columnCoins: balance,
        });
        return FinalChallengeUpdate(round, balance);
      });

  Future<FinalChallengeUpdate> hint(String word) =>
      database.database.transaction((txn) async {
        await _checkUnlocked(txn);
        final old = await _load(txn);
        if (old == null || !old.clues.any((clue) => clue.word == word)) {
          throw StateError('No matching final challenge clue');
        }
        final coins =
            int.tryParse(await _value(txn, AppConstants.keyCoins) ?? '') ??
            AppConstants.startingCoins;
        if (old.completed ||
            old.found.contains(word) ||
            old.hints.contains(word) ||
            coins < 10) {
          return FinalChallengeUpdate(old, coins);
        }
        final round = FinalChallengeRound(
          regionIds: old.regionIds,
          seed: old.seed,
          found: old.found,
          hints: {...old.hints, word},
          bestStars: old.bestStars,
          includeTriviaWords: old.includeTriviaWords,
        );
        await _put(txn, progressKey, jsonEncode(round.toJson()));
        await _put(txn, AppConstants.keyCoins, '${coins - 10}');
        await txn.update(DatabaseConstants.tablePlayerProfile, {
          DatabaseConstants.columnCoins: coins - 10,
        });
        return FinalChallengeUpdate(round, coins - 10);
      });
}
