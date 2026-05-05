/// Question embedded in active quiz payload (`backend` populate `questions`).
final class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.timerSeconds,
  });

  final String id;
  final String questionText;

  /// Typically 4 strings (MCQ).
  final List<String> options;

  /// Countdown length in seconds (`backend` field `timer`).
  final int timerSeconds;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOpts = json['options'];
    final opts = rawOpts is List
        ? rawOpts.map((e) => e.toString()).toList()
        : <String>[];

    return QuizQuestion(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      questionText: json['questionText'] as String? ?? '',
      options: opts,
      timerSeconds: (json['timer'] as num?)?.toInt() ?? 30,
    );
  }
}
