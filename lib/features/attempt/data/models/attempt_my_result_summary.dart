/// `GET /attempts/quiz/:quizId/my-result` — raw attempt document (`data`).
final class AttemptMyResultSummary {
  const AttemptMyResultSummary({
    required this.attemptId,
    required this.quizId,
    required this.score,
    required this.answerCount,
    this.submittedAt,
  });

  final String attemptId;
  final String quizId;
  final int score;

  /// Length of `answers` array (total questions in attempt).
  final int answerCount;
  final DateTime? submittedAt;

  factory AttemptMyResultSummary.fromJson(Map<String, dynamic> json) {
    final answersRaw = json['answers'];
    final count = answersRaw is List ? answersRaw.length : 0;
    DateTime? submitted;
    final sub = json['submittedAt'];
    if (sub is String) {
      submitted = DateTime.tryParse(sub);
    }

    return AttemptMyResultSummary(
      attemptId: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      answerCount: count,
      submittedAt: submitted,
    );
  }
}
