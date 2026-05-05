import 'package:flutter/material.dart';
import 'package:quiz_battle/core/network/api_error_formatter.dart';
import 'package:quiz_battle/core/network/api_exception.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';

enum AppSnackBarTone {
  error,
  warning,
  success,
}

void showTonedSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarTone tone = AppSnackBarTone.error,
  Duration duration = const Duration(seconds: 8),
}) {
  final p = context.palette;
  final Color bg;
  final Color fg;
  switch (tone) {
    case AppSnackBarTone.error:
      bg = p.snackBarError;
      fg = const Color(0xFFFFFFFF);
    case AppSnackBarTone.warning:
      bg = p.snackBarWarning;
      fg = p.snackBarWarningText;
    case AppSnackBarTone.success:
      bg = p.snackBarSuccess;
      fg = const Color(0xFFFFFFFF);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          height: 1.35,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      duration: duration,
    ),
  );
}

void showAppErrorSnackBar(BuildContext context, Object error) {
  showTonedSnackBar(context, formatAnyApiError(error));
}

/// Prefer this for [ApiException] so validation lines stay readable.
void showApiExceptionSnackBar(BuildContext context, ApiException e) {
  showTonedSnackBar(context, formatApiException(e));
}
