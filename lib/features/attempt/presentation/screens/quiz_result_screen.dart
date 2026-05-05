import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/network/api_error_formatter.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/core/theme/result_semantic_colors.dart';
import 'package:quiz_battle/features/attempt/attempt_providers.dart';
import 'package:quiz_battle/features/attempt/data/models/attempt_answer_breakdown.dart';
import 'package:quiz_battle/features/attempt/data/models/quiz_result_bundle.dart';
import 'package:quiz_battle/features/attempt/presentation/models/quiz_result_args.dart';
import 'package:quiz_battle/routes/route_paths.dart';

/// Shown after a quiz is submitted, on conflict, or when opening the result route.
class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key, required this.args});

  final QuizResultArgs args;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(quizResultBundleProvider(args.quizId));
    await ref.read(quizResultBundleProvider(args.quizId).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    if (args.isConflict) {
      return Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          title: const Text('Result'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  args.quizTitle,
                  style: textTheme.titleLarge?.copyWith(
                    color: context.palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  Icons.info_outline_rounded,
                  size: 48,
                  color: context.palette.orange.withOpacity(0.9),
                ),
                const SizedBox(height: 16),
                Text(
                  args.conflictMessage!,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.go(RoutePaths.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.orange,
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Back to quizzes'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final async = ref.watch(quizResultBundleProvider(args.quizId));

    return async.when(
      loading: () => Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          title: const Text('Result'),
          automaticallyImplyLeading: false,
        ),
        body: const AppLoadingIndicator(message: 'Loading your results…'),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          title: const Text('Result'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  args.quizTitle,
                  style: textTheme.titleLarge?.copyWith(
                    color: context.palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  formatAnyApiError(e),
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => _refresh(ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.orange,
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Try again'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go(RoutePaths.home),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.palette.textSecondary,
                    side: BorderSide(color: context.palette.textMuted),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Back to quizzes'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (bundle) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: context.palette.background,
          appBar: AppBar(
            title: const Text('Result'),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              indicatorColor: context.palette.orange,
              labelColor: context.palette.textPrimary,
              unselectedLabelColor: context.palette.textMuted,
              tabs: const [
                Tab(text: 'Summary'),
                Tab(text: 'Review'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _SummaryTab(
                args: args,
                bundle: bundle,
                onRefresh: () => _refresh(ref),
              ),
              _ReviewTab(
                answers: bundle.detailed.answers,
                onRefresh: () => _refresh(ref),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: FilledButton(
                onPressed: () => context.go(RoutePaths.home),
                style: FilledButton.styleFrom(
                  backgroundColor: context.palette.orange,
                  foregroundColor: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Back to quizzes'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({
    required this.args,
    required this.bundle,
    required this.onRefresh,
  });

  final QuizResultArgs args;
  final QuizResultBundle bundle;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final d = bundle.detailed;

    return RefreshIndicator(
      color: context.palette.orange,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            args.quizTitle,
            style: textTheme.titleMedium?.copyWith(
              color: context.palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (d.submittedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              _formatSubmitted(d.submittedAt!),
              style: textTheme.bodySmall?.copyWith(color: context.palette.textMuted),
            ),
          ],
          const SizedBox(height: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.palette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.palette.textMuted.withOpacity(0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total score',
                    style: textTheme.labelLarge?.copyWith(color: context.palette.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${d.score}',
                    style: textTheme.displaySmall?.copyWith(
                      color: context.palette.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'out of ${d.totalQuestions} questions',
                    style: textTheme.bodyMedium?.copyWith(color: context.palette.textMuted),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Correct',
                          value: '${d.correctCount}',
                          accent: ResultSemanticColors.correct,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Wrong',
                          value: '${d.wrongCount}',
                          accent: ResultSemanticColors.wrong,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSubmitted(DateTime dt) {
    final local = dt.toLocal();
    final d = '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final t =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return 'Submitted $d · $t';
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(color: context.palette.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab({
    required this.answers,
    required this.onRefresh,
  });

  final List<AttemptAnswerBreakdown> answers;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) {
      return RefreshIndicator(
        color: context.palette.orange,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                'No answers to review.',
                style: TextStyle(color: context.palette.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.palette.orange,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: answers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _AnswerReviewCard(answer: answers[i], index: i + 1),
      ),
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  const _AnswerReviewCard({
    required this.answer,
    required this.index,
  });

  final AttemptAnswerBreakdown answer;
  final int index;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ok = answer.isCorrect;
    final border = ok ? ResultSemanticColors.correct : ResultSemanticColors.wrong;
    final badgeBg = ok
        ? ResultSemanticColors.correct.withOpacity(0.18)
        : ResultSemanticColors.wrong.withOpacity(0.18);
    final badgeFg = ok ? ResultSemanticColors.correctMuted : ResultSemanticColors.wrongMuted;

    final title = answer.questionText.trim().isEmpty
        ? 'Question $index'
        : answer.questionText;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withOpacity(0.55), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      color: context.palette.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      ok ? 'Correct' : 'Wrong',
                      style: textTheme.labelMedium?.copyWith(
                        color: badgeFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AnswerRow(
              label: 'Your answer',
              value: answer.userAnswerLabel,
              valueColor: ok ? ResultSemanticColors.correct : ResultSemanticColors.wrong,
            ),
            const SizedBox(height: 10),
            _AnswerRow(
              label: 'Correct answer',
              value: answer.correctAnswerLabel,
              valueColor: ResultSemanticColors.correct,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: context.palette.textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
