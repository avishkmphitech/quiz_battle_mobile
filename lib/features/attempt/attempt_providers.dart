import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/features/attempt/data/models/quiz_result_bundle.dart';
import 'package:quiz_battle/features/attempt/data/models/user_quiz_stats.dart';
import 'package:quiz_battle/features/attempt/data/repositories/attempt_repository.dart';
import 'package:quiz_battle/features/attempt/data/repositories/attempt_repository_impl.dart';

final attemptRepositoryProvider = Provider<AttemptRepository>((ref) {
  return AttemptRepositoryImpl(ref.watch(dioProvider));
});

/// Lifetime quiz totals (`GET /attempts/me/stats`).
final myQuizStatsProvider = FutureProvider.autoDispose<UserQuizStats>((ref) {
  return ref.watch(attemptRepositoryProvider).fetchMyStats();
});

/// Loads `my-result` + `my-result/detailed` in parallel for the result UI.
final quizResultBundleProvider =
    FutureProvider.autoDispose.family<QuizResultBundle, String>((ref, quizId) {
  return ref.watch(attemptRepositoryProvider).fetchResultBundle(quizId);
});
