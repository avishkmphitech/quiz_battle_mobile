/// Path segments for [GoRouter] configuration.
abstract final class RoutePaths {
  static const splash = '/';
  static const intro = '/intro';
  static const login = '/login';
  static const signup = '/signup';
  static const signupOtp = '/signup/otp';
  static const forgotPassword = '/forgot-password';
  static const forgotPasswordReset = '/forgot-password/reset';
  /// Name + email or mobile (`POST /auth/onboard`); public before quizzes.
  static const onboard = '/onboard';

  /// Main shell: dashboard tab (default after sign-in).
  static const home = '/dashboard';

  /// Main shell: full active quiz list.
  static const activeQuizzes = '/active-quizzes';

  /// Main shell: profile menu hub.
  static const profileHub = '/profile-hub';

  /// Lifetime quiz totals.
  static const stats = '/stats';

  /// Edit name / email / mobile (`PATCH /auth/me`).
  static const profileEdit = '/profile/edit';

  /// Terms or privacy (see [RouteNames.legalDocument] `extra`).
  static const legalDocument = '/legal/document';

  /// `/quiz/play/:quizId` — see [RouteNames.quizPlay].
  static const quizPlay = '/quiz/play/:quizId';

  /// `/quiz/:quizId/result` — post-submit summary.
  static const quizResult = '/quiz/:quizId/result';

  /// Logged-in user profile (name, email, role).
  static const profile = '/profile';
}

abstract final class RouteNames {
  static const splash = 'splash';
  static const intro = 'intro';
  static const login = 'login';
  static const signup = 'signup';
  static const signupOtp = 'signupOtp';
  static const forgotPassword = 'forgotPassword';
  static const forgotPasswordReset = 'forgotPasswordReset';
  static const onboard = 'onboard';
  static const home = 'home';
  static const activeQuizzes = 'activeQuizzes';
  static const profileHub = 'profileHub';
  static const stats = 'stats';
  static const profileEdit = 'profileEdit';
  static const legalDocument = 'legalDocument';
  static const quizPlay = 'quizPlay';
  static const quizResult = 'quizResult';
  static const profile = 'profile';
}
