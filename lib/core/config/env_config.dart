import 'package:flutter_dotenv/flutter_dotenv.dart';

/// **Single source** for API host and `/api/v1` base URL.
///
/// Set `API_BASE_URL` in `assets/env/.env` (see `.env.example`). Do not scatter
/// host strings elsewhere; consult `backend/` for route and payload contracts.
final class EnvConfig {
  EnvConfig._();

  /// Root API host (scheme + host, optional port), **no** `/api/v1` suffix.
  static String get apiHost {
    return dotenv.get('API_BASE_URL').trim();
  }

  /// [Dio] `baseUrl` including `/api/v1` (matches `backend/src/app.js` mount).
  static String get apiBaseUrl {
    final host = apiHost.replaceAll(RegExp(r'/+$'), '');
    return '$host/api/v1';
  }
}
