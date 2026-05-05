import 'package:quiz_battle/features/quiz/data/models/quiz_question.dart';

/// Current user's prior attempt on this quiz (`GET /quizzes/active` → `myAttempt`).
final class MyAttemptSummary {
  const MyAttemptSummary({
    required this.score,
    this.submittedAt,
  });

  final int score;
  final DateTime? submittedAt;

  factory MyAttemptSummary.fromJson(Map<String, dynamic> json) {
    DateTime? sub;
    final raw = json['submittedAt'];
    if (raw is String) {
      sub = DateTime.tryParse(raw);
    }
    return MyAttemptSummary(
      score: (json['score'] as num?)?.toInt() ?? 0,
      submittedAt: sub,
    );
  }
}

/// Active quiz from `GET /quizzes/active` (`backend` quiz + populated `questions`).
final class ActiveQuiz {
  const ActiveQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.myAttempt,
  });

  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;

  /// Non-null when the signed-in user already submitted this quiz.
  final MyAttemptSummary? myAttempt;

  bool get hasCompletedAttempt => myAttempt != null;

  factory ActiveQuiz.fromJson(Map<String, dynamic> json) {
    final questionsRaw = json['questions'];
    final questions = <QuizQuestion>[];
    if (questionsRaw is List) {
      for (final item in questionsRaw) {
        if (item is Map<String, dynamic>) {
          final q = QuizQuestion.fromJson(item);
          if (q.id.isNotEmpty) questions.add(q);
        }
      }
    }

    MyAttemptSummary? my;
    final myRaw = json['myAttempt'];
    if (myRaw is Map<String, dynamic>) {
      my = MyAttemptSummary.fromJson(myRaw);
    }

    return ActiveQuiz(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      questions: questions,
      myAttempt: my,
    );
  }
}
