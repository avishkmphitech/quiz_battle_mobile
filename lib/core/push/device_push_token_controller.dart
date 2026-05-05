import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/constants/storage_keys.dart';
import 'package:quiz_battle/core/providers/prefs_provider.dart';

/// Holds the `deviceToken` sent with register / login / refresh-token.
///
/// [onTokenRefresh] updates [SharedPreferences] and this state so [dioProvider]
/// rebuilds interceptors with the new value.
final class DevicePushTokenController extends StateNotifier<String> {
  DevicePushTokenController(this._ref, String initial) : super(initial) {
    _attachTokenRefresh();
  }

  final Ref _ref;
  StreamSubscription<String>? _refreshSub;

  void _attachTokenRefresh() {
    try {
      if (Firebase.apps.isEmpty) return;
      _refreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(
        (newToken) async {
          if (newToken.isEmpty) return;
          final prefs = _ref.read(sharedPreferencesProvider);
          await prefs.setString(StorageKeys.fcmToken, newToken);
          state = newToken;
          if (kDebugMode) {
            debugPrint('[push] FCM token refreshed');
          }
        },
        onError: (Object e, StackTrace st) {
          if (kDebugMode) {
            debugPrint('[push] onTokenRefresh error: $e $st');
          }
        },
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[push] could not subscribe to onTokenRefresh: $e $st');
      }
    }
  }

  @override
  void dispose() {
    unawaited(_refreshSub?.cancel() ?? Future<void>.value());
    super.dispose();
  }
}

/// Overridden from [main] with the bootstrapped token.
final devicePushTokenControllerProvider =
    StateNotifierProvider<DevicePushTokenController, String>((ref) {
  throw StateError(
    'devicePushTokenControllerProvider must be overridden in ProviderScope (main.dart).',
  );
});

/// Resolves the current `deviceToken` for repositories and Dio interceptors.
final devicePushTokenProvider = Provider<String>((ref) {
  return ref.watch(devicePushTokenControllerProvider);
});
