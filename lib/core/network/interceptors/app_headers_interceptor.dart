import 'package:dio/dio.dart';
import 'package:quiz_battle/core/network/app_header_values.dart';

/// Adds `x-app-version` and `x-device-type` on every request.
final class AppHeadersInterceptor extends Interceptor {
  AppHeadersInterceptor(this._values);

  final AppHeaderValues _values;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final h = _values.toHeaders();
    options.headers.addAll(h);
    handler.next(options);
  }
}
