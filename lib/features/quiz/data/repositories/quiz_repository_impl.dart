import 'package:dio/dio.dart';
import 'package:quiz_battle/core/constants/api_endpoints.dart';
import 'package:quiz_battle/core/network/api_response_parser.dart';
import 'package:quiz_battle/core/network/run_dio.dart';
import 'package:quiz_battle/features/quiz/data/models/active_quiz.dart';
import 'package:quiz_battle/features/quiz/data/repositories/quiz_repository.dart';

final class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ActiveQuiz>> fetchActiveQuizzes() {
    return runDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.quizzesActive);
      final raw = ApiResponseParser.requireDataList(
        res.data,
        defaultMessage: 'Failed to load quizzes',
        invalidPayloadMessage: 'Unexpected quizzes response.',
      );
      return raw
          .whereType<Map<String, dynamic>>()
          .map(ActiveQuiz.fromJson)
          .where((q) => q.id.isNotEmpty)
          .toList();
    });
  }
}
