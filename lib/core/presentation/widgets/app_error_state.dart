import 'package:flutter/material.dart';
import 'package:quiz_battle/core/network/api_error_formatter.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';

/// Full-width error panel with optional retry (lists, scaffolds).
class AppErrorStateView extends StatelessWidget {
  const AppErrorStateView({
    super.key,
    required this.error,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = Icons.cloud_off_outlined,
  });

  final Object error;
  final String title;
  final Future<void> Function()? onRetry;
  final String retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final message = formatAnyApiError(error);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 52, color: p.textMuted.withOpacity(0.9)),
        const SizedBox(height: 16),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: p.textSecondary,
            height: 1.35,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await onRetry!();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(retryLabel),
            style: FilledButton.styleFrom(
              backgroundColor: p.orange,
              foregroundColor: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }
}
