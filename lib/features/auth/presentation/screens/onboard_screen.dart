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
import 'package:quiz_battle/routes/router_refresh_provider.dart';

/// Name + email **or** mobile (matches `POST /auth/onboard`); alternative to full register.
class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({super.key});

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Name is required.';
    if (s.length < 2) return 'Name must be at least 2 characters.';
    if (s.length > 50) return 'Name must be at most 50 characters.';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!email.hasMatch(s)) return 'Please enter a valid email.';
    return null;
  }

  String? _validateMobile(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    final ok = RegExp(r'^[0-9]{10,15}$').hasMatch(s);
    if (!ok) return 'Mobile must be 10–15 digits.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _email.text.trim();
    final mobile = _mobile.text.trim();
    if (email.isEmpty && mobile.isEmpty) {
      showAppErrorSnackBar(
        context,
        'Enter an email or a mobile number so we can reach you.',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final session = await ref.read(authRepositoryProvider).onboard(
            name: _name.text,
            email: email.isEmpty ? null : email,
            mobile: mobile.isEmpty ? null : mobile,
          );
      await ref.read(authTokenStoreProvider).writeTokens(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
          );
      await ref
          .read(appPreferencesProvider)
          .setCachedAuthUserJson(jsonEncode(session.user.toJson()));
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Quick sign-in'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Name & email or phone',
                      style: textTheme.headlineSmall?.copyWith(
                        color: context.palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use this if you prefer not to create a password. You still need to sign in before joining a quiz.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: context.palette.textPrimary),
                      decoration: _fieldDecoration(context, 'Name'),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: context.palette.textPrimary),
                      decoration: _fieldDecoration(context, 'Email (optional if you add mobile)'),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mobile,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: TextStyle(color: context.palette.textPrimary),
                      decoration: _fieldDecoration(context, 'Mobile (optional if you add email)'),
                      validator: _validateMobile,
                    ),
                    const SizedBox(height: 28),
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
                              'Continue',
                              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.login),
                      child: Text(
                        'Use email & password instead',
                        style: textTheme.labelLarge?.copyWith(color: context.palette.emerald),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
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
