/// One row from `GET .../my-result/detailed` `data.answers[]`.
final class AttemptAnswerBreakdown {
  const AttemptAnswerBreakdown({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.selectedAnswerRaw,
    required this.correctAnswerIndex,
    required this.isCorrect,
  });

  final String questionId;
  final String questionText;
  final List<String> options;

  /// Stored value from the attempt (index or option text).
  final Object? selectedAnswerRaw;

  /// Correct option index (`backend` question.correctAnswer).
  final int? correctAnswerIndex;
  final bool isCorrect;

  factory AttemptAnswerBreakdown.fromJson(Map<String, dynamic> json) {
    final optsRaw = json['options'];
    final opts = optsRaw is List
        ? optsRaw.map((e) => e.toString()).toList()
        : <String>[];

    final ca = json['correctAnswer'];
    int? correctIdx;
    if (ca is num) {
      correctIdx = ca.toInt();
    }

    return AttemptAnswerBreakdown(
      questionId: json['questionId']?.toString() ?? '',
      questionText: json['questionText'] as String? ?? '',
      options: opts,
      selectedAnswerRaw: json['selectedAnswer'],
      correctAnswerIndex: correctIdx,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  String get userAnswerLabel => _labelForSelection(selectedAnswerRaw, options);

  String get correctAnswerLabel =>
      correctAnswerIndex != null &&
              correctAnswerIndex! >= 0 &&
              correctAnswerIndex! < options.length
          ? options[correctAnswerIndex!]
          : (correctAnswerIndex?.toString() ?? '—');
}

String _labelForSelection(Object? raw, List<String> options) {
  if (raw == null) return '—';
  if (raw is num) {
    final i = raw.toInt();
    if (i >= 0 && i < options.length) return options[i];
    return raw.toString();
  }
  return raw.toString();
}
