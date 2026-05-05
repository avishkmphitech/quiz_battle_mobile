import 'package:quiz_battle/features/auth/data/models/auth_user.dart';

/// Tokens + user after login or register (`backend` `sendSuccess` `data` payload).
final class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;

  /// Present after login; register currently returns access only.
  final String? refreshToken;
}
