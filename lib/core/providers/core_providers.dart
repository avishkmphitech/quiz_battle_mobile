import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/device/client_device_token_service.dart';
import 'package:quiz_battle/core/network/app_header_values.dart';
import 'package:quiz_battle/core/providers/prefs_provider.dart';
import 'package:quiz_battle/core/network/dio_client.dart';
import 'package:quiz_battle/core/push/device_push_token_controller.dart';
import 'package:quiz_battle/core/utils/app_preferences.dart';
import 'package:quiz_battle/core/utils/auth_token_store.dart';
import 'package:quiz_battle/routes/router_refresh_provider.dart';

export 'package:quiz_battle/core/providers/prefs_provider.dart';
export 'package:quiz_battle/core/push/device_push_token_controller.dart';

final appHeaderValuesProvider = Provider<AppHeaderValues>((ref) {
  throw StateError('appHeaderValuesProvider must be overridden in ProviderScope');
});

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return SecureAuthTokenStore();
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppPreferences(prefs);
});

final clientDeviceTokenServiceProvider =
    Provider<ClientDeviceTokenService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ClientDeviceTokenService(prefs);
});

final dioProvider = Provider<Dio>((ref) {
  final authTokenStore = ref.watch(authTokenStoreProvider);
  final headers = ref.watch(appHeaderValuesProvider);
  final deviceTok = ref.watch(devicePushTokenProvider);
  final refresh = ref.watch(routerRefreshNotifierProvider);

  final dio = DioClient.create(
    authTokenStore: authTokenStore,
    headerValues: headers,
    devicePushToken: deviceTok,
    onSessionExpired: () async {
      refresh.notifyAuthChanged();
    },
  );
  ref.onDispose(dio.close);
  return dio;
});
