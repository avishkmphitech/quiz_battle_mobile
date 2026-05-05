import 'dart:io' show Platform;

import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiz_battle/core/constants/http_headers.dart';

/// Values for `x-app-version` and `x-device-type` (see backend appVersion middleware).
final class AppHeaderValues {
  AppHeaderValues._({
    required this.appVersion,
    required this.deviceType,
  });

  final String appVersion;

  /// `android` or `ios` (lowercase).
  final String deviceType;

  static Future<AppHeaderValues> fromPackageInfo(PackageInfo info) async {
    final deviceType = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : 'android';
    return AppHeaderValues._(
      appVersion: info.version,
      deviceType: deviceType,
    );
  }

  Map<String, String> toHeaders() => {
        AppHttpHeaders.xAppVersion: appVersion,
        AppHttpHeaders.xDeviceType: deviceType,
      };
}
