import 'package:quiz_battle/features/auth/data/models/auth_session.dart';
import 'package:quiz_battle/features/auth/data/models/auth_user.dart';

/// Maps to `backend/src/modules/auth/auth.routes.js`.
abstract class AuthRepository {
  /// `purpose`: `register` | `password_reset` (matches API).
  Future<void> requestEmailOtp({
    required String email,
    required String purpose,
  });

  /// Completes signup after [requestEmailOtp] with `register`.
  Future<AuthSession> completeRegister({
    required String name,
    required String email,
    required String password,
    required String emailOtp,
  });

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> completePasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  /// `GET /auth/me` — live profile for the current access token.
  Future<AuthUser> fetchCurrentUser();

  /// `PATCH /auth/me` — partial update (at least one field).
  Future<AuthUser> updateProfile({
    String? name,
    String? email,
    String? mobile,
  });

  /// `DELETE /auth/me` — removes user and all attempts (irreversible).
  Future<void> deleteAccount();

  /// `POST /auth/onboard` — name + (email or mobile); no password.
  Future<AuthSession> onboard({
    required String name,
    String? email,
    String? mobile,
  });

  Future<void> logout();
}
