import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_battle/core/network/api_exception.dart';

/// Normalizes [DioException] into [ApiException] for upper layers.
final class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final api = err.toApiException();
    if (kDebugMode) {
      debugPrint('[API] ${api.statusCode} ${api.path}: ${api.message}');
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: api,
        message: api.message,
      ),
    );
  }
}
