import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/presentation/app_snackbar.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/features/auth/data/models/auth_user.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  bool _loading = false;
  bool _seeded = false;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  void _applyUser(AuthUser u) {
    _name.text = u.name;
    _mobile.text = u.mobile ?? '';
  }

  static const _guestEmailSuffix = '@guest.quizbattle.local';

  static String _displayEmail(AuthUser u) {
    final e = u.email.trim();
    if (e.isEmpty) return '—';
    if (e.endsWith(_guestEmailSuffix)) return 'Not set (phone sign-in)';
    return e;
  }

  String? _validateName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Name is required.';
    if (s.length < 2) return 'Name must be at least 2 characters.';
    if (s.length > 50) return 'Name must be at most 50 characters.';
    return null;
  }

  String? _validateMobile(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    final ok = RegExp(r'^[0-9]{10,15}$').hasMatch(s);
    if (!ok) return 'Mobile must be 10–15 digits.';
    return null;
  }

  Future<void> _save(AuthUser current) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _name.text.trim();
    final mobile = _mobile.text.trim();

    final nameChanged = name != current.name;
    final mobileChanged = mobile != (current.mobile ?? '');

    if (!nameChanged && !mobileChanged) {
      showTonedSnackBar(context, 'Nothing to update.', tone: AppSnackBarTone.warning);
      return;
    }

    setState(() => _loading = true);
    try {
      final updated = await ref.read(authRepositoryProvider).updateProfile(
            name: nameChanged ? name : null,
            mobile: mobileChanged ? mobile : null,
          );
      await ref.read(appPreferencesProvider).setCachedAuthUserJson(jsonEncode(updated.toJson()));
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        showTonedSnackBar(context, 'Profile updated.', tone: AppSnackBarTone.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) showAppErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final async = ref.watch(currentUserProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Update profile'),
      ),
      body: async.when(
        loading: () => const AppLoadingIndicator(message: 'Loading…'),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load profile: $e',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
            ),
          ),
        ),
        data: (user) {
          if (!_seeded) {
            _seeded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _applyUser(user);
            });
          }
          return AbsorbPointer(
            absorbing: _loading,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  Text(
                    'Email',
                    style: textTheme.labelMedium?.copyWith(color: p.textMuted),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.textMuted.withValues(alpha: 0.35)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 20, color: p.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _displayEmail(user),
                              style: textTheme.bodyLarge?.copyWith(
                                color: p.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email cannot be changed here.',
                    style: textTheme.bodySmall?.copyWith(color: p.textMuted, height: 1.35),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mobile,
                    decoration: const InputDecoration(
                      labelText: 'Mobile (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Clear to remove',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validateMobile,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _loading ? null : () => _save(user),
                    style: FilledButton.styleFrom(
                      backgroundColor: p.orange,
                      foregroundColor: const Color(0xFFFFFFFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
