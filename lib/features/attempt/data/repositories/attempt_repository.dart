import 'package:quiz_battle/features/attempt/data/models/attempt_submit_result.dart';
import 'package:quiz_battle/features/attempt/data/models/quiz_result_bundle.dart';
import 'package:quiz_battle/features/attempt/data/models/user_quiz_stats.dart';

abstract class AttemptRepository {
  Future<UserQuizStats> fetchMyStats();

  Future<AttemptSubmitResult> submitAttempt({
    required String quizId,
    required List<({String questionId, int selectedIndex})> answers,
  });

  Future<QuizResultBundle> fetchResultBundle(String quizId);
}
