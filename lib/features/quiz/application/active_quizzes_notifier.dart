import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/features/quiz/data/models/active_quiz.dart';
import 'package:quiz_battle/features/quiz/data/repositories/quiz_repository.dart';
import 'package:quiz_battle/features/quiz/data/repositories/quiz_repository_impl.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepositoryImpl(ref.watch(dioProvider));
});

/// Centralized async state for the active quiz list (refresh / retry friendly).
final class ActiveQuizzes extends AutoDisposeAsyncNotifier<List<ActiveQuiz>> {
  @override
  Future<List<ActiveQuiz>> build() {
    return ref.read(quizRepositoryProvider).fetchActiveQuizzes();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(quizRepositoryProvider).fetchActiveQuizzes(),
    );
  }
}

final activeQuizzesProvider =
    AsyncNotifierProvider.autoDispose<ActiveQuizzes, List<ActiveQuiz>>(ActiveQuizzes.new);
