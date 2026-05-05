import 'package:dio/dio.dart';
import 'package:quiz_battle/core/constants/api_constants.dart';
import 'package:quiz_battle/core/utils/auth_token_store.dart';

/// Injects `Authorization: Bearer <access>` when present.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final AuthTokenStore _tokens;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _tokens.readAccessToken().then((token) {
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.headerAuthorization] =
            '${ApiConstants.bearerPrefix}$token';
      }
      handler.next(options);
    }, onError: (Object e, StackTrace st) {
      handler.reject(
        DioException(requestOptions: options, error: e, stackTrace: st),
      );
    });
  }
}
