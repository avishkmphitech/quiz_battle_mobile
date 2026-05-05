import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/presentation/widgets/app_error_state.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/attempt/presentation/models/quiz_result_args.dart';
import 'package:quiz_battle/features/home/presentation/widgets/active_quiz_card.dart';
import 'package:quiz_battle/features/quiz/data/models/active_quiz.dart';
import 'package:quiz_battle/features/quiz/quiz_providers.dart';
import 'package:quiz_battle/routes/route_paths.dart';

/// Full list of active quizzes (same behaviour as the former home list).
class ActiveQuizzesScreen extends ConsumerWidget {
  const ActiveQuizzesScreen({super.key});

  void _openQuiz(BuildContext context, ActiveQuiz quiz) {
    if (quiz.hasCompletedAttempt) {
      context.pushNamed(
        RouteNames.quizResult,
        pathParameters: {'quizId': quiz.id},
        extra: QuizResultArgs(
          quizId: quiz.id,
          quizTitle: quiz.title,
          totalQuestions: quiz.questions.length,
          score: quiz.myAttempt!.score,
        ),
      );
      return;
    }
    context.pushNamed(
      RouteNames.quizPlay,
      pathParameters: {'quizId': quiz.id},
      extra: quiz,
    );
  }

  Future<void> _refresh(WidgetRef ref) {
    return ref.read(activeQuizzesProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncQuizzes = ref.watch(activeQuizzesProvider);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: const Text('Active quizzes'),
      ),
      body: RefreshIndicator(
        color: context.palette.orange,
        onRefresh: () => _refresh(ref),
        child: asyncQuizzes.when(
          skipLoadingOnReload: true,
          data: (quizzes) {
            if (quizzes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                children: [
                  _EmptyQuizzes(onBrowse: () => _refresh(ref)),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              itemCount: quizzes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final q = quizzes[i];
                return ActiveQuizCard(
                  quiz: q,
                  onPressed: () => _openQuiz(context, q),
                );
              },
            );
          },
          loading: () {
            final h = MediaQuery.sizeOf(context).height;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: h * 0.28),
                const AppLoadingIndicator(message: 'Loading quizzes…'),
              ],
            );
          },
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              AppErrorStateView(
                title: 'Could not load quizzes',
                error: err,
                onRetry: () async {
                  await _refresh(ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyQuizzes extends StatelessWidget {
  const _EmptyQuizzes({required this.onBrowse});

  final Future<void> Function() onBrowse;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.quiz_outlined,
          size: 56,
          color: context.palette.textMuted.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 20),
        Text(
          'No active quizzes',
          style: textTheme.titleMedium?.copyWith(
            color: context.palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Check back soon — new quizzes will show up here.',
          style: textTheme.bodyMedium?.copyWith(color: context.palette.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => onBrowse(),
          icon: Icon(Icons.refresh_rounded, color: context.palette.emerald),
          label: const Text('Refresh'),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.palette.emerald,
            side: BorderSide(color: context.palette.emerald),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
