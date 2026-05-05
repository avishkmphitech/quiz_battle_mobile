import 'package:quiz_battle/features/quiz/data/models/active_quiz.dart';

/// User-facing quiz list (`backend` `quiz.routes.js`).
///
/// When the API supports paging, add something like
/// `Future<PaginatedPage<ActiveQuiz>> fetchActiveQuizzesPage(PageRequest page)`
/// (see `core/domain/pagination.dart`) and evolve call sites from [fetchActiveQuizzes].
abstract class QuizRepository {
  Future<List<ActiveQuiz>> fetchActiveQuizzes();
}