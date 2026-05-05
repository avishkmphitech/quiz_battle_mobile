import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/presentation/widgets/app_error_state.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/attempt/attempt_providers.dart';

class QuizStatsScreen extends ConsumerWidget {
  const QuizStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myQuizStatsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Your stats'),
      ),
      body: async.when(
        loading: () => const AppLoadingIndicator(message: 'Loading stats…'),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppErrorStateView(
            title: 'Could not load stats',
            error: e,
            onRetry: () async {
              ref.invalidate(myQuizStatsProvider);
            },
          ),
        ),
        data: (stats) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text(
                'Lifetime totals',
                style: textTheme.titleMedium?.copyWith(
                  color: context.palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Across every quiz you have submitted.',
                style: textTheme.bodySmall?.copyWith(color: context.palette.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              _StatTile(
                label: 'Quizzes participated',
                value: stats.totalQuizzesParticipated.toString(),
                icon: Icons.quiz_outlined,
                accent: context.palette.orange,
              ),
              const SizedBox(height: 12),
              _StatTile(
                label: 'Questions answered',
                value: stats.totalQuestionsParticipated.toString(),
                icon: Icons.help_outline_rounded,
                accent: context.palette.emerald,
              ),
              const SizedBox(height: 12),
              _StatTile(
                label: 'Correct answers',
                value: stats.totalCorrectAnswers.toString(),
                icon: Icons.check_circle_outline_rounded,
                accent: context.palette.emerald,
              ),
              const SizedBox(height: 12),
              _StatTile(
                label: 'Wrong answers',
                value: stats.totalWrongAnswers.toString(),
                icon: Icons.cancel_outlined,
                accent: context.palette.orange,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.textMuted.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(color: context.palette.textSecondary),
              ),
            ),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: context.palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
