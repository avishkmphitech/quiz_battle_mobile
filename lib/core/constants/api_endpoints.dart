/// Paths relative to [EnvConfig.apiBaseUrl] (`…/api/v1`).
///
/// Source: `backend/src/app.js`, `backend/src/modules/**`.
abstract final class ApiEndpoints {
  /// `POST` body: `{ email, purpose: "register" | "password_reset" }` — starts OTP window (dev OTP: `0000`).
  static const String authEmailOtpRequest = '/auth/email-otp/request';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authForgotPasswordReset = '/auth/forgot-password/reset';
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh-token';
  static const String authMe = '/auth/me';
  static const String authOnboard = '/auth/onboard';

  /// `GET /attempts/me/stats` — lifetime totals for the signed-in user.
  static const String attemptsMyStats = '/attempts/me/stats';

  /// `backend/src/modules/quiz/quiz.routes.js` — requires user JWT + app version headers.
  static const String quizzesActive = '/quizzes/active';

  /// `backend/src/modules/attempt/attempt.routes.js` — POST submit.
  static const String attempts = '/attempts';

  /// `GET /attempts/quiz/:quizId/my-result`
  static String attemptQuizMyResult(String quizId) =>
      '/attempts/quiz/$quizId/my-result';

  /// `GET /attempts/quiz/:quizId/my-result/detailed`
  static String attemptQuizMyResultDetailed(String quizId) =>
      '/attempts/quiz/$quizId/my-result/detailed';
}
