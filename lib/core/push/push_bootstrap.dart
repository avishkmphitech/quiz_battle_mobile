import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_battle/core/constants/storage_keys.dart';
import 'package:quiz_battle/core/device/client_device_token_service.dart';
import 'package:quiz_battle/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase init, permission, first FCM token, and persistence.
///
/// On failure (missing `firebase_options`, misconfiguration, emulator), returns
/// the stable client fallback so auth payloads stay valid.
abstract final class PushBootstrap {
  /// Ensures Firebase is initialized (when possible), requests notification
  /// permission, reads FCM token, persists under [StorageKeys.fcmToken], and
  /// returns the token to use for `deviceToken` (FCM or client fallback).
  static Future<String> resolveDeviceToken(SharedPreferences prefs) async {
    final clientFallback = await ClientDeviceTokenService(prefs).ensureToken();

    if (!DefaultFirebaseOptions.isCurrentPlatformConfigured) {
      if (kDebugMode) {
        debugPrint(
          '[push] Firebase options are placeholders; '
          'run `flutterfire configure` for FCM. Using client id for deviceToken.',
        );
      }
      return clientFallback;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final messaging = FirebaseMessaging.instance;

      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        if (kDebugMode) {
          debugPrint('[push] notification permission denied; using client id');
        }
        await prefs.remove(StorageKeys.fcmToken);
        return clientFallback;
      }

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await prefs.setString(StorageKeys.fcmToken, token);
        return token;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[push] FCM bootstrap failed: $e\n$st');
      }
    }

    return clientFallback;
  }
}
