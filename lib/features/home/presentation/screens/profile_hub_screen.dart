import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/presentation/app_snackbar.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/providers/theme_mode_provider.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/auth/application/logout_user.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/features/auth/presentation/screens/legal_document_screen.dart';
import 'package:quiz_battle/routes/route_paths.dart';
import 'package:quiz_battle/routes/router_refresh_provider.dart';

/// Single hub listing all account actions; sub-screens open on top via the router.
class ProfileHubScreen extends ConsumerWidget {
  const ProfileHubScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final d = ctx.palette;
        return AlertDialog(
          backgroundColor: d.card,
          title: Text(
            'Delete account?',
            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(color: d.textPrimary),
          ),
          content: Text(
            'This permanently removes your profile and all quiz attempts. You cannot undo this.',
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: d.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: d.snackBarError),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (ok != true || !context.mounted) return;

    try {
      await ref.read(authRepositoryProvider).deleteAccount();
    } catch (e) {
      if (context.mounted) showAppErrorSnackBar(context, e);
      return;
    }

    await ref.read(authTokenStoreProvider).clear();
    await ref.read(appPreferencesProvider).clearCachedAuthUser();
    ref.invalidate(currentUserProfileProvider);
    ref.read(routerRefreshNotifierProvider).notifyAuthChanged();

    if (context.mounted) {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            'Account',
            style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.visibility_outlined,
            label: 'See profile',
            onTap: () => context.pushNamed(RouteNames.profile),
          ),
          _HubTile(
            icon: Icons.edit_outlined,
            label: 'Update profile',
            onTap: () => context.pushNamed(RouteNames.profileEdit),
          ),
          const SizedBox(height: 20),
          Text(
            'Appearance',
            style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined, size: 18),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined, size: 18),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined, size: 18),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (Set<ThemeMode> next) {
                ref.read(themeModeProvider.notifier).setThemeMode(next.first);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Legal',
            style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.article_outlined,
            label: 'Terms & conditions',
            onTap: () => context.pushNamed(
              RouteNames.legalDocument,
              extra: LegalDocumentKind.terms,
            ),
          ),
          _HubTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy policy',
            onTap: () => context.pushNamed(
              RouteNames.legalDocument,
              extra: LegalDocumentKind.privacy,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Session',
            style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.logout_rounded,
            label: 'Log out',
            onTap: () => logoutUser(ref, context),
          ),
          _HubTile(
            icon: Icons.delete_forever_outlined,
            label: 'Delete account',
            danger: true,
            onTap: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final accent = danger ? p.snackBarError : p.emerald;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.titleSmall?.copyWith(
                      color: p.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.textMuted.withValues(alpha: 0.85)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
