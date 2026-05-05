import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/presentation/widgets/app_error_state.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/attempt/attempt_providers.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/features/quiz/quiz_providers.dart';
import 'package:quiz_battle/routes/route_paths.dart';

/// Home hub: overview and shortcuts (not the full quiz list).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(activeQuizzesProvider.notifier).refresh();
    ref.invalidate(myQuizStatsProvider);
    try {
      await ref.read(myQuizStatsProvider.future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final asyncQuizzes = ref.watch(activeQuizzesProvider);
    final asyncStats = ref.watch(myQuizStatsProvider);
    final asyncUser = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        color: p.orange,
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            asyncUser.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (user) {
                final name = user.name.trim().isEmpty ? 'there' : user.name.trim();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Hi, $name',
                    style: textTheme.headlineSmall?.copyWith(
                      color: p.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
            Text(
              'Overview',
              style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
            ),
            const SizedBox(height: 12),
            asyncQuizzes.when(
              skipLoadingOnReload: true,
              data: (quizzes) {
                return _DashboardCard(
                  icon: Icons.quiz_outlined,
                  accent: p.emerald,
                  title: 'Active quizzes',
                  subtitle:
                      '${quizzes.length} live ${quizzes.length == 1 ? 'quiz' : 'quizzes'} right now',
                  onTap: () => context.go(RoutePaths.activeQuizzes),
                );
              },
              loading: () => const _CardPlaceholder(),
              error: (e, _) => AppErrorStateView(
                title: 'Could not load quizzes',
                error: e,
                onRetry: () async {
                  await ref.read(activeQuizzesProvider.notifier).refresh();
                },
              ),
            ),
            const SizedBox(height: 14),
            asyncStats.when(
              skipLoadingOnReload: true,
              data: (stats) {
                return _DashboardCard(
                  icon: Icons.bar_chart_rounded,
                  accent: p.orange,
                  title: 'Your performance',
                  subtitle:
                      '${stats.totalQuizzesParticipated} quizzes · ${stats.totalCorrectAnswers} correct · ${stats.totalWrongAnswers} wrong',
                  onTap: () => context.pushNamed(RouteNames.stats),
                );
              },
              loading: () => const _CardPlaceholder(),
              error: (e, _) => AppErrorStateView(
                title: 'Could not load stats',
                error: e,
                onRetry: () async {
                  ref.invalidate(myQuizStatsProvider);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Shortcuts',
              style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(RoutePaths.activeQuizzes),
              icon: Icon(Icons.play_circle_outline_rounded, color: p.emerald),
              label: const Text('Open quiz list'),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.emerald,
                side: BorderSide(color: p.emerald),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.stats),
              icon: Icon(Icons.insights_rounded, color: p.orange),
              label: const Text('Full stats'),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.orange,
                side: BorderSide(color: p.orange),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.textMuted.withValues(alpha: 0.85)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 88,
      child: Center(child: AppLoadingIndicator(message: null)),
    );
  }
}
