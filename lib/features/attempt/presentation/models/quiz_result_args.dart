/// Passed via `GoRouter` `extra` to [QuizResultScreen].
final class QuizResultArgs {
  const QuizResultArgs({
    required this.quizId,
    required this.quizTitle,
    required this.totalQuestions,
    this.score,
    this.attemptId,
    this.conflictMessage,
  });

  final String quizId;
  final String quizTitle;
  final int totalQuestions;

  /// Set after successful submit.
  final int? score;
  final String? attemptId;

  /// When non-null, user already had an attempt (e.g. HTTP 409).
  final String? conflictMessage;

  bool get isConflict => conflictMessage != null && conflictMessage!.isNotEmpty;
}
