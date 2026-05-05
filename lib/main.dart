import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiz_battle/app.dart';
import 'package:quiz_battle/core/network/app_header_values.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/push/push_bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env/.env');

  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();
  final headerValues = await AppHeaderValues.fromPackageInfo(packageInfo);
  final deviceToken = await PushBootstrap.resolveDeviceToken(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appHeaderValuesProvider.overrideWithValue(headerValues),
        devicePushTokenControllerProvider.overrideWith(
          (ref) => DevicePushTokenController(ref, deviceToken),
        ),
      ],
      child: const QuizBattleApp(),
    ),
  );
}
