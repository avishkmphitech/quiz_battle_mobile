import 'package:flutter/material.dart';

/// Theme-aware palette (see `UI_DESIGN_RULES.md`). Use `context.palette` in widgets.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.card,
    required this.orange,
    required this.emerald,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.snackBarError,
    required this.snackBarWarning,
    required this.snackBarWarningText,
    required this.snackBarSuccess,
  });

  final Color background;
  final Color card;
  final Color orange;
  final Color emerald;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color snackBarError;
  final Color snackBarWarning;
  final Color snackBarWarningText;
  final Color snackBarSuccess;

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0F0F0F),
    card: Color(0xFF1C1C1C),
    orange: Color(0xFFF97316),
    emerald: Color(0xFF10B981),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA3A3A3),
    textMuted: Color(0xFF737373),
    snackBarError: Color(0xFFDC2626),
    snackBarWarning: Color(0xFFF59E0B),
    snackBarWarningText: Color(0xFF111827),
    snackBarSuccess: Color(0xFF059669),
  );

  static const AppPalette light = AppPalette(
    background: Color(0xFFF5F5F5),
    card: Color(0xFFFFFFFF),
    orange: Color(0xFFF97316),
    emerald: Color(0xFF10B981),
    textPrimary: Color(0xFF171717),
    textSecondary: Color(0xFF525252),
    textMuted: Color(0xFF737373),
    snackBarError: Color(0xFFDC2626),
    snackBarWarning: Color(0xFFF59E0B),
    snackBarWarningText: Color(0xFF111827),
    snackBarSuccess: Color(0xFF059669),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? orange,
    Color? emerald,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? snackBarError,
    Color? snackBarWarning,
    Color? snackBarWarningText,
    Color? snackBarSuccess,
  }) {
    return AppPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      orange: orange ?? this.orange,
      emerald: emerald ?? this.emerald,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      snackBarError: snackBarError ?? this.snackBarError,
      snackBarWarning: snackBarWarning ?? this.snackBarWarning,
      snackBarWarningText: snackBarWarningText ?? this.snackBarWarningText,
      snackBarSuccess: snackBarSuccess ?? this.snackBarSuccess,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      emerald: Color.lerp(emerald, other.emerald, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      snackBarError: Color.lerp(snackBarError, other.snackBarError, t)!,
      snackBarWarning: Color.lerp(snackBarWarning, other.snackBarWarning, t)!,
      snackBarWarningText: Color.lerp(snackBarWarningText, other.snackBarWarningText, t)!,
      snackBarSuccess: Color.lerp(snackBarSuccess, other.snackBarSuccess, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
