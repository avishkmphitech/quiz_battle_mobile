import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/network/api_exception.dart';
import 'package:quiz_battle/core/presentation/app_snackbar.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/features/auth/presentation/models/auth_flow_extras.dart';
import 'package:quiz_battle/routes/route_paths.dart';
import 'package:quiz_battle/routes/router_refresh_provider.dart';

/// Enter the email verification code after [SignupScreen] requested an OTP.
class SignupOtpScreen extends ConsumerStatefulWidget {
  const SignupOtpScreen({super.key, required this.args});

  final SignupOtpArgs args;

  @override
  ConsumerState<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends ConsumerState<SignupOtpScreen> {
  final _otp = TextEditingController();
  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final code = _otp.text.trim();
    if (code.length != 4 || int.tryParse(code) == null) {
      showTonedSnackBar(
        context,
        'Enter the 4-digit code from your email.',
        tone: AppSnackBarTone.warning,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final session = await ref.read(authRepositoryProvider).completeRegister(
            name: widget.args.name,
            email: widget.args.email,
            password: widget.args.password,
            emailOtp: code,
          );
      await ref.read(authTokenStoreProvider).writeTokens(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
          );
      await ref
          .read(appPreferencesProvider)
          .setCachedAuthUserJson(jsonEncode(session.user.toJson()));
      ref.invalidate(currentUserProfileProvider);
      ref.read(routerRefreshNotifierProvider).notifyAuthChanged();
      if (!mounted) return;
      context.go(RoutePaths.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiExceptionSnackBar(context, e);
    } catch (e) {
      if (!mounted) return;
      showAppErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await ref.read(authRepositoryProvider).requestEmailOtp(
            email: widget.args.email,
            purpose: 'register',
          );
      if (!mounted) return;
      showTonedSnackBar(
        context,
        'A new code was sent. Check your email.',
        tone: AppSnackBarTone.success,
        duration: const Duration(seconds: 4),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiExceptionSnackBar(context, e);
    } catch (e) {
      if (!mounted) return;
      showAppErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final email = widget.args.email.trim();

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Verify email'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your code',
                    style: textTheme.headlineSmall?.copyWith(
                      color: context.palette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a verification code to\n$email',
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Development build: use code 0000.',
                    style: textTheme.bodySmall?.copyWith(
                      color: context.palette.snackBarWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: textTheme.headlineMedium?.copyWith(
                      color: context.palette.textPrimary,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••',
                      hintStyle: TextStyle(
                        color: context.palette.textMuted.withOpacity(0.6),
                        letterSpacing: 8,
                      ),
                      filled: true,
                      fillColor: context.palette.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: context.palette.textMuted.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: context.palette.orange,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _verify,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.palette.orange,
                      foregroundColor: const Color(0xFFFFFFFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const AppButtonProgress()
                        : Text(
                            'Verify & create account',
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _resending ? null : _resend,
                    child: _resending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Resend code',
                            style: textTheme.labelLarge?.copyWith(
                              color: context.palette.emerald,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
