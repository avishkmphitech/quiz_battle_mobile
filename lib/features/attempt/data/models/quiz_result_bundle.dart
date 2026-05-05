import 'package:quiz_battle/features/attempt/data/models/attempt_detailed_result.dart';
import 'package:quiz_battle/features/attempt/data/models/attempt_my_result_summary.dart';

/// Pair from `my-result` + `my-result/detailed` for the result screen.
final class QuizResultBundle {
  const QuizResultBundle({
    required this.summary,
    required this.detailed,
  });

  final AttemptMyResultSummary summary;
  final AttemptDetailedResult detailed;
}
