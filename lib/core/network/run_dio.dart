import 'package:dio/dio.dart';
import 'package:quiz_battle/core/network/api_exception.dart';

/// Runs [fn] and maps [DioException] to [ApiException] consistently.
Future<T> runDio<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on DioException catch (e) {
    final err = e.error;
    if (err is ApiException) throw err;
    throw e.toApiException();
  }
}
