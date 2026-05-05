import 'package:flutter/material.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/core/theme/result_semantic_colors.dart';
import 'package:quiz_battle/features/quiz/data/models/active_quiz.dart';

class ActiveQuizCard extends StatelessWidget {
  const ActiveQuizCard({
    super.key,
    required this.quiz,
    required this.onPressed,
  });

  final ActiveQuiz quiz;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final desc = quiz.description.isEmpty ? 'No description.' : quiz.description;
    final attempted = quiz.hasCompletedAttempt;
    final total = quiz.questions.length;
    final score = quiz.myAttempt?.score;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    quiz.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: context.palette.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                if (attempted && total > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ResultSemanticColors.correct.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ResultSemanticColors.correct.withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      'Score $score / $total',
                      style: textTheme.labelMedium?.copyWith(
                        color: ResultSemanticColors.correctMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
                height: 1.45,
              ),
            ),
            if (attempted) ...[
              const SizedBox(height: 10),
              Text(
                'You already played this quiz. Tap to review your answers.',
                style: textTheme.bodySmall?.copyWith(
                  color: context.palette.textMuted,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: context.palette.orange,
                  foregroundColor: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(attempted ? 'View results' : 'Join'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
