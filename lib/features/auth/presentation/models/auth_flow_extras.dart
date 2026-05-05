/// Passed via [GoRouterState.extra] to OTP / reset screens.
final class SignupOtpArgs {
  const SignupOtpArgs({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

final class PasswordResetOtpArgs {
  const PasswordResetOtpArgs({required this.email});

  final String email;
}
