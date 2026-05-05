/// `GET /attempts/me/stats` (`data` payload).
final class UserQuizStats {
  const UserQuizStats({
    required this.totalQuizzesParticipated,
    required this.totalQuestionsParticipated,
    required this.totalCorrectAnswers,
    required this.totalWrongAnswers,
  });

  final int totalQuizzesParticipated;
  final int totalQuestionsParticipated;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;

  factory UserQuizStats.fromJson(Map<String, dynamic> json) {
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    return UserQuizStats(
      totalQuizzesParticipated: n('totalQuizzesParticipated'),
      totalQuestionsParticipated: n('totalQuestionsParticipated'),
      totalCorrectAnswers: n('totalCorrectAnswers'),
      totalWrongAnswers: n('totalWrongAnswers'),
    );
  }
}
