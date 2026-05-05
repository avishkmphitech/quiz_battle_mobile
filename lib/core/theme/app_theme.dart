import 'package:flutter/material.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      surface: AppPalette.dark.background,
      onSurface: AppPalette.dark.textPrimary,
      primary: AppPalette.dark.orange,
      onPrimary: AppPalette.dark.textPrimary,
      secondary: AppPalette.dark.emerald,
      onSecondary: AppPalette.dark.textPrimary,
      surfaceContainerHighest: AppPalette.dark.card,
      onSurfaceVariant: AppPalette.dark.textSecondary,
      outline: AppPalette.dark.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppPalette.dark.background,
      colorScheme: scheme,
      extensions: const [AppPalette.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.dark.background,
        foregroundColor: AppPalette.dark.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.dark.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.light(
      surface: AppPalette.light.background,
      onSurface: AppPalette.light.textPrimary,
      primary: AppPalette.light.orange,
      onPrimary: const Color(0xFFFFFFFF),
      secondary: AppPalette.light.emerald,
      onSecondary: const Color(0xFFFFFFFF),
      surfaceContainerHighest: AppPalette.light.card,
      onSurfaceVariant: AppPalette.light.textSecondary,
      outline: AppPalette.light.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppPalette.light.background,
      colorScheme: scheme,
      extensions: const [AppPalette.light],
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.light.background,
        foregroundColor: AppPalette.light.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.light.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
