import 'package:flutter/material.dart';
import 'package:quiz_battle/core/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive app preferences (onboarding, flags).
final class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  bool get hasSeenIntro =>
      _prefs.getBool(StorageKeys.introSeen) ?? false;

  Future<void> setIntroSeen() async {
    await _prefs.setBool(StorageKeys.introSeen, true);
  }

  /// Raw JSON string from [AuthUser.toJson].
  String? get cachedAuthUserJson => _prefs.getString(StorageKeys.cachedAuthUser);

  Future<void> setCachedAuthUserJson(String json) async {
    await _prefs.setString(StorageKeys.cachedAuthUser, json);
  }

  Future<void> clearCachedAuthUser() async {
    await _prefs.remove(StorageKeys.cachedAuthUser);
  }

  /// Unset or unknown → [ThemeMode.system].
  ThemeMode get themeMode {
    final raw = _prefs.getString(StorageKeys.themeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(StorageKeys.themeMode, value);
  }
}