import 'package:quiz_battle/features/quiz/data/models/quiz_question.dart';

/// Client-side checks aligned with `backend` `attempt.validation.js`.
final class QuizSubmitValidator {
  QuizSubmitValidator._();

  /// Returns `[answers]` when valid, otherwise `[errorMessage]` explains why.
  static ({
    List<({String questionId, int selectedIndex})>? answers,
    String? errorMessage,
  }) validateAndBuild({
    required List<QuizQuestion> questions,
    required Map<String, int?> answersByQuestionId,
  }) {
    if (questions.isEmpty) {
      return (
        answers: null,
        errorMessage: 'This quiz has no questions.',
      );
    }

    final out = <({String questionId, int selectedIndex})>[];
    final seenIds = <String>{};

    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final sel = answersByQuestionId[q.id];

      if (sel == null) {
        return (
          answers: null,
          errorMessage:
              'Answer every question before submitting. Question ${i + 1} is still unanswered.',
        );
      }

      if (q.options.isEmpty) {
        return (
          answers: null,
          errorMessage: 'A question has no options. Pull to refresh on the home screen and try again.',
        );
      }

      if (q.options.length != 4) {
        return (
          answers: null,
          errorMessage:
              'Each question must have exactly 4 answer options. Question ${i + 1} is invalid — contact support.',
        );
      }

      if (sel < 0 || sel >= q.options.length) {
        return (
          answers: null,
          errorMessage: 'One of your answers does not match the available options. Review your choices.',
        );
      }

      if (seenIds.contains(q.id)) {
        return (
          answers: null,
          errorMessage: 'Duplicate answers for the same question were detected. Please restart the quiz.',
        );
      }
      seenIds.add(q.id);
      out.add((questionId: q.id, selectedIndex: sel));
    }

    if (out.map((e) => e.questionId).toSet().length != out.length) {
      return (
        answers: null,
        errorMessage: 'Duplicate question IDs are not allowed.',
      );
    }

    if (out.length != questions.length) {
      return (
        answers: null,
        errorMessage: 'Each question must be answered exactly once.',
      );
    }

    return (answers: out, errorMessage: null);
  }
}
