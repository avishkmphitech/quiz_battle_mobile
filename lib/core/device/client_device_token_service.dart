import 'package:quiz_battle/core/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Supplies a **non-empty** fallback `deviceToken` when FCM is unavailable.
///
/// [PushBootstrap] prefers FCM; this id is persisted as a last resort so Joi
/// `deviceToken` validation in `backend` still passes.
final class ClientDeviceTokenService {
  ClientDeviceTokenService(this._prefs);

  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  Future<String> ensureToken() async {
    final existing = _prefs.getString(StorageKeys.clientDevicePushKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = 'client_${_uuid.v4()}';
    await _prefs.setString(StorageKeys.clientDevicePushKey, created);
    return created;
  }

  String? get currentToken => _prefs.getString(StorageKeys.clientDevicePushKey);
}
