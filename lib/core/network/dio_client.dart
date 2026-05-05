import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_battle/core/config/env_config.dart';
import 'package:quiz_battle/core/network/app_header_values.dart';
import 'package:quiz_battle/core/network/interceptors/app_headers_interceptor.dart';
import 'package:quiz_battle/core/network/interceptors/auth_interceptor.dart';
import 'package:quiz_battle/core/network/interceptors/error_interceptor.dart';
import 'package:quiz_battle/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:quiz_battle/core/utils/auth_token_store.dart';

/// Factory for the shared [Dio] instance used across repositories.
final class DioClient {
  DioClient._();

  static Dio create({
    required AuthTokenStore authTokenStore,
    required AppHeaderValues headerValues,
    required String devicePushToken,
    required Future<void> Function() onSessionExpired,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          Headers.contentTypeHeader: Headers.jsonContentType,
          Headers.acceptHeader: Headers.jsonContentType,
        },
      ),
    );

    dio.interceptors.addAll([
      AppHeadersInterceptor(headerValues),
      AuthInterceptor(authTokenStore),
      ErrorInterceptor(),
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
        ),
      TokenRefreshInterceptor(
        dio: dio,
        tokens: authTokenStore,
        headerValues: headerValues,
        devicePushToken: devicePushToken,
        onSessionExpired: onSessionExpired,
      ),
    ]);

    return dio;
  }
}
