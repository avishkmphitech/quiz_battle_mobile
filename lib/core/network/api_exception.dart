import 'package:dio/dio.dart';

/// Application-level API failure (mapped from [DioException] and HTTP errors).
final class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.path,
    this.original,
    this.validationErrors = const [],
  });

  final String message;
  final int? statusCode;
  final String? path;
  final Object? original;
  final List<String> validationErrors;

  @override
  String toString() =>
      'ApiException($statusCode): $message${path != null ? ' ($path)' : ''}';
}

extension DioExceptionX on DioException {
  ApiException toApiException() {
    final code = response?.statusCode;
    final data = response?.data;
    String message = type.name;
    List<String> errors = const [];

    if (data is Map) {
      if (data['message'] != null) {
        message = data['message'].toString();
      }
      final raw = data['errors'];
      if (raw is List) {
        errors = raw.map((e) => e.toString()).toList();
      }
    }

    if (message.isEmpty || message == 'unknown') {
      message = 'Request failed';
    }

    return ApiException(
      message: message,
      statusCode: code,
      path: requestOptions.path,
      original: this,
      validationErrors: errors,
    );
  }
}
