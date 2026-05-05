import 'package:dio/dio.dart';
import 'package:quiz_battle/core/constants/api_endpoints.dart';
import 'package:quiz_battle/core/network/api_response_parser.dart';
import 'package:quiz_battle/core/network/run_dio.dart';
import 'package:quiz_battle/features/attempt/data/models/attempt_detailed_result.dart';
import 'package:quiz_battle/features/attempt/data/models/attempt_my_result_summary.dart';
import 'package:quiz_battle/features/attempt/data/models/attempt_submit_result.dart';
import 'package:quiz_battle/features/attempt/data/models/quiz_result_bundle.dart';
import 'package:quiz_battle/features/attempt/data/models/user_quiz_stats.dart';
import 'package:quiz_battle/features/attempt/data/repositories/attempt_repository.dart';

final class AttemptRepositoryImpl implements AttemptRepository {
  AttemptRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserQuizStats> fetchMyStats() {
    return runDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.attemptsMyStats);
      final data = ApiResponseParser.requireDataMap(
        res.data,
        defaultMessage: 'Could not load stats.',
      );
      return UserQuizStats.fromJson(data);
    });
  }

  @override
  Future<AttemptSubmitResult> submitAttempt({
    required String quizId,
    required List<({String questionId, int selectedIndex})> answers,
  }) {
    return runDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.attempts,
        data: {
          'quizId': quizId,
          'answers': answers
              .map(
                (a) => {
                  'questionId': a.questionId,
                  'selectedAnswer': a.selectedIndex,
                },
              )
              .toList(),
        },
      );
      final data = ApiResponseParser.requireDataMap(
        res.data,
        defaultMessage: 'Submit failed',
        invalidPayloadMessage: 'Unexpected submit response.',
      );
      return AttemptSubmitResult.fromJson(data);
    });
  }

  @override
  Future<QuizResultBundle> fetchResultBundle(String quizId) {
    return runDio(() async {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>(ApiEndpoints.attemptQuizMyResult(quizId)),
        _dio.get<Map<String, dynamic>>(ApiEndpoints.attemptQuizMyResultDetailed(quizId)),
      ]);
      final summaryRes = responses[0];
      final detailedRes = responses[1];

      final sData = ApiResponseParser.requireDataMap(
        summaryRes.data,
        defaultMessage: 'Could not load result.',
      );
      final dData = ApiResponseParser.requireDataMap(
        detailedRes.data,
        defaultMessage: 'Could not load detailed result.',
      );

      return QuizResultBundle(
        summary: AttemptMyResultSummary.fromJson(sData),
        detailed: AttemptDetailedResult.fromJson(dData),
      );
    });
  }
}
