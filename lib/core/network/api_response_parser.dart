import 'package:quiz_battle/core/network/api_exception.dart';

/// Shared `{ success, message, data, errors }` handling for REST envelopes.
abstract final class ApiResponseParser {
  static List<String> validationErrorsFrom(Map<String, dynamic>? body) {
    final raw = body?['errors'];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  static void assertSuccess(
    Map<String, dynamic>? body, {
    String defaultMessage = 'Request failed',
  }) {
    if (body == null || body['success'] != true) {
      throw ApiException(
        message: body?['message']?.toString() ?? defaultMessage,
        validationErrors: validationErrorsFrom(body),
      );
    }
  }

  static Map<String, dynamic> requireDataMap(
    Map<String, dynamic>? body, {
    String defaultMessage = 'Request failed',
    String invalidPayloadMessage = 'Invalid response payload.',
  }) {
    assertSuccess(body, defaultMessage: defaultMessage);
    final data = body!['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: invalidPayloadMessage);
    }
    return data;
  }

  static List<dynamic> requireDataList(
    Map<String, dynamic>? body, {
    String defaultMessage = 'Request failed',
    String invalidPayloadMessage = 'Invalid response payload.',
  }) {
    assertSuccess(body, defaultMessage: defaultMessage);
    final data = body!['data'];
    if (data is! List) {
      throw ApiException(message: invalidPayloadMessage);
    }
    return data;
  }
}
