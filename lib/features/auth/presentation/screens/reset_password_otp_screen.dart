import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/network/api_exception.dart';
import 'package:quiz_battle/core/presentation/app_snackbar.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/features/auth/presentation/models/auth_flow_extras.dart';
import 'package:quiz_battle/routes/route_paths.dart';

class ResetPasswordOtpScreen extends ConsumerStatefulWidget {
  const ResetPasswordOtpScreen({super.key, required this.args});

  final PasswordResetOtpArgs args;

  @override
  ConsumerState<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends ConsumerState<ResetPasswordOtpScreen> {
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _resending = false;

  @override
  void dispose() {
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final code = _otp.text.trim();
    if (code.length != 4 || int.tryParse(code) == null) {
      showTonedSnackBar(
        context,
        'Enter the 4-digit reset code.',
        tone: AppSnackBarTone.warning,
      );
      return;
    }
    final p = _password.text;
    if (p.length < 6) {
      showTonedSnackBar(
        context,
        'New password must be at least 6 characters.',
        tone: AppSnackBarTone.warning,
      );
      return;
    }
    if (p != _confirm.text) {
      showTonedSnackBar(
        context,
        'Passwords do not match.',
        tone: AppSnackBarTone.warning,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).completePasswordReset(
            email: widget.args.email,
            otp: code,
            newPassword: p,
          );
      if (!mounted) return;
      showTonedSnackBar(
        context,
        'Password updated. Sign in with your new password.',
        tone: AppSnackBarTone.success,
        duration: const Duration(seconds: 4),
      );
      context.go(RoutePaths.login);
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
      await ref.read(authRepositoryProvider).requestPasswordReset(
            email: widget.args.email,
          );
      if (!mounted) return;
      showTonedSnackBar(
        context,
        'If an account exists, a new code window was started.',
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
    final email = widget.args.email;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('New password'),
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
                    email,
                    style: textTheme.titleSmall?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Reset code',
                    style: textTheme.labelLarge?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: textTheme.headlineSmall?.copyWith(
                      color: context.palette.textPrimary,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: context.palette.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: context.palette.orange,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    style: TextStyle(color: context.palette.textPrimary),
                    decoration: _pwdDec(context, 'New password'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    style: TextStyle(color: context.palette.textPrimary),
                    decoration: _pwdDec(context, 'Confirm password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: context.palette.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
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
                            'Update password',
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

  InputDecoration _pwdDec(BuildContext context, String label) {
    final p = context.palette;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: p.textSecondary),
      floatingLabelStyle: TextStyle(color: p.orange),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.textMuted.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.orange, width: 1.5),
      ),
      filled: true,
      fillColor: p.card,
    );
  }
}
