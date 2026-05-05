import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_battle/core/config/env_config.dart';
import 'package:quiz_battle/core/constants/api_constants.dart';
import 'package:quiz_battle/core/constants/api_endpoints.dart';
import 'package:quiz_battle/core/network/app_header_values.dart';
import 'package:quiz_battle/core/utils/auth_token_store.dart';

/// On `401`, exchanges `refreshToken` once (see `backend` auth routes).
///
/// Register this **after** [LogInterceptor] so `onError` runs **before** error mapping.
final class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required Dio dio,
    required AuthTokenStore tokens,
    required AppHeaderValues headerValues,
    required String devicePushToken,
    required Future<void> Function() onSessionExpired,
  })  : _dio = dio,
        _tokens = tokens,
        _headerValues = headerValues,
        _devicePushToken = devicePushToken,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final AuthTokenStore _tokens;
  final AppHeaderValues _headerValues;
  final String _devicePushToken;
  final Future<void> Function() _onSessionExpired;

  static final _skipPathFragments = [
    '/auth/refresh-token',
    '/auth/login',
    '/auth/register',
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final code = err.response?.statusCode;
    if (code != 401) {
      handler.next(err);
      return;
    }
    final path = err.requestOptions.path;
    for (final fragment in _skipPathFragments) {
      if (path.contains(fragment)) {
        handler.next(err);
        return;
      }
    }

    unawaited(_refresh(err, handler));
  }

  Future<void> _refresh(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final refresh = await _tokens.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        await _expire();
        handler.next(err);
        return;
      }

      final plain = Dio(
        BaseOptions(
          baseUrl: EnvConfig.apiBaseUrl,
          headers: {
            Headers.contentTypeHeader: Headers.jsonContentType,
            Headers.acceptHeader: Headers.jsonContentType,
            ..._headerValues.toHeaders(),
          },
        ),
      );

      final res = await plain.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {
          'refreshToken': refresh,
          'deviceToken': _devicePushToken,
        },
      );

      final body = res.data;
      if (body == null) {
        await _expire();
        handler.next(err);
        return;
      }
      if (body['success'] != true) {
        await _expire();
        handler.next(err);
        return;
      }

      final data = body['data'];
      if (data is! Map) {
        await _expire();
        handler.next(err);
        return;
      }

      final access = data['token'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (access == null || access.isEmpty) {
        await _expire();
        handler.next(err);
        return;
      }

      await _tokens.writeTokens(
        accessToken: access,
        refreshToken: newRefresh ?? refresh,
      );

      final ro = err.requestOptions;
      ro.headers[ApiConstants.headerAuthorization] =
          '${ApiConstants.bearerPrefix}$access';

      final clone = await _dio.fetch(ro);
      handler.resolve(clone);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[auth] refresh failed: $e $st');
      }
      await _expire();
      handler.next(err);
    }
  }

  Future<void> _expire() async {
    await _tokens.clear();
    await _onSessionExpired();
  }
}
