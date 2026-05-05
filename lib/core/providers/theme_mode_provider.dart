import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.read(appPreferencesProvider).themeMode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(appPreferencesProvider).setThemeMode(mode);
    state = mode;
  }
}
