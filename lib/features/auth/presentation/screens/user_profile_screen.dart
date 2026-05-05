import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/presentation/widgets/app_error_state.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/features/auth/data/models/auth_user.dart';

/// Live profile from `GET /auth/me` (name, email, mobile).
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  static const _guestEmailSuffix = '@guest.quizbattle.local';

  static String _displayEmail(AuthUser u) {
    final e = u.email.trim();
    if (e.isEmpty) return '—';
    if (e.endsWith(_guestEmailSuffix)) return 'Not set (phone sign-in)';
    return e;
  }

  static String _displayMobile(AuthUser u) {
    final m = u.mobile?.trim();
    if (m == null || m.isEmpty) return '—';
    return m;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final async = ref.watch(currentUserProfileProvider);

    ref.listen(currentUserProfileProvider, (_, next) {
      next.whenData((user) {
        unawaited(
          ref.read(appPreferencesProvider).setCachedAuthUserJson(jsonEncode(user.toJson())),
        );
      });
    });

    Future<void> onRefresh() async {
      ref.invalidate(currentUserProfileProvider);
      await ref.read(currentUserProfileProvider.future);
    }

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Your info'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const AppLoadingIndicator(message: 'Loading profile…'),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppErrorStateView(
                  title: 'Could not load profile',
                  error: e,
                  onRetry: onRefresh,
                ),
              ],
            ),
          ),
          data: (user) => RefreshIndicator(
            color: p.orange,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Account',
                  style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  rows: [
                    _Row('Name', user.name.isEmpty ? '—' : user.name),
                    _Row('Email', _displayEmail(user)),
                    _Row('Mobile', _displayMobile(user)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Details load from the server each time you open this screen.',
                  style: textTheme.bodySmall?.copyWith(color: p.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.textMuted.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: p.textMuted.withOpacity(0.25)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 88,
                      child: Text(
                        rows[i].label,
                        style: textTheme.labelMedium?.copyWith(color: p.textMuted),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rows[i].value,
                        style: textTheme.bodyLarge?.copyWith(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
}
