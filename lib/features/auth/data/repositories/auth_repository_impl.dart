import 'package:dio/dio.dart';
import 'package:quiz_battle/core/constants/api_endpoints.dart';
import 'package:quiz_battle/core/network/api_exception.dart';
import 'package:quiz_battle/core/network/api_response_parser.dart';
import 'package:quiz_battle/core/network/run_dio.dart';
import 'package:quiz_battle/features/auth/data/models/auth_session.dart';
import 'package:quiz_battle/features/auth/data/models/auth_user.dart';
import 'package:quiz_battle/features/auth/data/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._dio, {
    required String devicePushToken,
  }) : _devicePushToken = devicePushToken;

  final Dio _dio;
  final String _devicePushToken;

  @override
  Future<void> requestEmailOtp({
    required String email,
    required String purpose,
  }) {
    return runDio(() async {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authEmailOtpRequest,
        data: {
          'email': email.trim(),
          'purpose': purpose,
        },
      );
    });
  }

  @override
  Future<AuthSession> completeRegister({
    required String name,
    required String email,
    required String password,
    required String emailOtp,
  }) {
    return runDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authRegister,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'deviceToken': _devicePushToken,
          'emailOtp': emailOtp.trim(),
        },
      );
      final data = ApiResponseParser.requireDataMap(
        res.data,
        defaultMessage: 'Register failed',
      );
      final token = data['token'] as String?;
      final userMap = data['user'];
      if (token == null || token.isEmpty || userMap is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected register response.');
      }
      return AuthSession(
        user: AuthUser.fromJson(userMap),
        accessToken: token,
        refreshToken: data['refreshToken'] as String?,
      );
    });
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return runDio(() async {
      await requestEmailOtp(email: email, purpose: 'register');
      return completeRegister(
        name: name,
        email: email,
        password: password,
        emailOtp: '0000',
      );
    });
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    return requestEmailOtp(email: email, purpose: 'password_reset');
  }

  @override
  Future<void> completePasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return runDio(() async {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authForgotPasswordReset,
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
      );
    });
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    return runDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authLogin,
        data: {
          'email': email.trim(),
          'password': password,
          'deviceToken': _devicePushToken,
        },
      );
      final data = ApiResponseParser.requireDataMap(
        res.data,
        defaultMessage: 'Login failed',
      );
      final token = data['token'] as String?;
      final refresh = data['refreshToken'] as String?;
      final userMap = data['user'];
      if (token == null || token.isEmpty || userMap is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected login response.');
      }
      return AuthSession(
        user: AuthUser.fromJson(userMap),
        accessToken: token,
        refreshToken: refresh,
      );
    });
  }

  @override
  Future<AuthUser> fetchCurrentUser() {
    return runDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.authMe);
      final data = ApiResponseParser.requireDataMap(
        res.data,
        defaultMessage: 'Could not load profile.',
      );
      return AuthUser.fromJson(data);
    });
  }

  @override
  Future<AuthUser> updateProfile({
    String? name,
    String? email,
    String? mobile,
  }) {
    return runDio(() async {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name.trim();
      if (email != null) body['email'] = email.trim();
      if (mobile != null) {
        final m = mobile.trim();
        body['mobile'] = m.isEmpty ? '' : m;
      }
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.authMe,
        data: body,
      );
      final data = ApiResponseParser.requireDataMap(
        res.data,
        defaultMessage: 'Could not update profile.',
      );
      return AuthUser.fromJson(data);
    });
  }

  @override
  Future<void> deleteAccount() {
    return runDio(() async {
      await _dio.delete<void>(ApiEndpoints.authMe);
    });
  }

  @override
  Future<AuthSession> onboard({
    required String name,
    String? email,
    String? mobile,
  }) {
    return runDio(() async {
      final body = <String, dynamic>{
        'name': name.trim(),
      };
      final e = email?.trim();
      final m = mobile?.trim();
      if (e != null && e.isNotEmpty) body['email'] = e;
      if (m != null && m.isNotEmpty) body['mobile'] = m;

      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authOnboard,
        data: body,
      );
      final data = ApiResponseParser.requireDataMap(
        res.data,
        defaultMessage: 'Sign-in failed',
      );
      final token = data['token'] as String?;
      final userMap = data['user'];
      if (token == null || token.isEmpty || userMap is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected onboard response.');
      }
      return AuthSession(
        user: AuthUser.fromJson(userMap),
        accessToken: token,
        refreshToken: data['refreshToken'] as String?,
      );
    });
  }

  @override
  Future<void> logout() {
    return runDio(() async {
      await _dio.post<void>(ApiEndpoints.authLogout, data: {});
    });
  }
}
