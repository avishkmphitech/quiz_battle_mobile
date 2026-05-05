/// Minimal fields from `POST /attempts` success `data` (`backend` attempt model).
final class AttemptSubmitResult {
  const AttemptSubmitResult({
    required this.attemptId,
    required this.quizId,
    required this.score,
  });

  final String attemptId;
  final String quizId;
  final int score;

  factory AttemptSubmitResult.fromJson(Map<String, dynamic> json) {
    return AttemptSubmitResult(
      attemptId: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }
}
