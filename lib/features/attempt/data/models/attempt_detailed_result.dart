import 'package:quiz_battle/features/attempt/data/models/attempt_answer_breakdown.dart';

/// `GET /attempts/quiz/:quizId/my-result/detailed` — `data` from `buildAttemptBreakdown`.
final class AttemptDetailedResult {
  const AttemptDetailedResult({
    required this.attemptId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.answers,
    this.submittedAt,
  });

  final String attemptId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final List<AttemptAnswerBreakdown> answers;
  final DateTime? submittedAt;

  factory AttemptDetailedResult.fromJson(Map<String, dynamic> json) {
    final answersRaw = json['answers'];
    final answers = <AttemptAnswerBreakdown>[];
    if (answersRaw is List) {
      for (final e in answersRaw) {
        if (e is Map<String, dynamic>) {
          answers.add(AttemptAnswerBreakdown.fromJson(e));
        }
      }
    }

    DateTime? submitted;
    final sub = json['submittedAt'];
    if (sub is String) {
      submitted = DateTime.tryParse(sub);
    }

    return AttemptDetailedResult(
      attemptId: json['attemptId']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? answers.length,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      answers: answers,
      submittedAt: submitted,
    );
  }
}
