import 'package:quiz_battle/core/network/api_exception.dart';

/// User-visible text for any thrown error (API or unknown).
String formatAnyApiError(Object error) {
  if (error is ApiException) return formatApiException(error);
  return error.toString();
}

/// User-visible API error text (message + validation lines; no HTTP status in UI).
String formatApiException(ApiException e) {
  final parts = <String>[e.message];
  if (e.validationErrors.isNotEmpty) {
    parts.addAll(e.validationErrors);
  }
  return parts.join('\n');
}
