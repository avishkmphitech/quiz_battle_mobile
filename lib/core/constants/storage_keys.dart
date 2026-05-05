/// Keys for [SharedPreferences] values owned by the app shell.
abstract final class StorageKeys {
  static const String introSeen = 'app.intro_seen';

  /// Stable client id used as `deviceToken` when FCM is unavailable (backend requires non-empty).
  static const String clientDevicePushKey = 'app.client_device_token';

  /// Last FCM registration token from [FirebaseMessaging.getToken] / [onTokenRefresh].
  static const String fcmToken = 'push.fcm_token';

  /// JSON map of last logged-in user (name, email, role) from login/register.
  static const String cachedAuthUser = 'auth.cached_user_json';

  /// `system` | `light` | `dark` — default when unset: system.
  static const String themeMode = 'app.theme_mode';
}
