import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/network/api_exception.dart';
import 'package:quiz_battle/core/presentation/app_snackbar.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/routes/route_paths.dart';
import 'package:quiz_battle/features/auth/presentation/widgets/app_logo.dart';
import 'package:quiz_battle/routes/router_refresh_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Email is required.';
    final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!email.hasMatch(s)) return 'Please enter a valid email.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final session = await ref.read(authRepositoryProvider).login(
            email: _email.text,
            password: _password.text,
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

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AppLogo(size: 88)),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome back',
                        style: textTheme.headlineSmall?.copyWith(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: textTheme.bodyMedium?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You need an account before joining a quiz.',
                        style: textTheme.bodySmall?.copyWith(
                          color: p.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        style: TextStyle(color: p.textPrimary),
                        decoration: _fieldDecoration('Email', p),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        style: TextStyle(color: p.textPrimary),
                        decoration: _fieldDecoration('Password', p).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: p.textSecondary,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: p.orange,
                          foregroundColor: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const AppButtonProgress()
                            : Text(
                                'Sign in',
                                style: textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push(RoutePaths.forgotPassword),
                        child: Text(
                          'Forgot password?',
                          style: textTheme.labelLarge?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push(RoutePaths.signup),
                        child: Text(
                          'Create an account',
                          style: textTheme.labelLarge?.copyWith(
                            color: p.emerald,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(RoutePaths.onboard),
                        child: Text(
                          'Name & phone only (no password)',
                          style: textTheme.labelLarge?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, AppPalette p) {
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.orange),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.orange, width: 1.5),
      ),
      filled: true,
      fillColor: p.card,
    );
  }
}
