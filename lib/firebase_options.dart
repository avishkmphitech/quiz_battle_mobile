// ignore_for_file: lines_longer_than_80_chars
//
// Replace this file by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Until then, [DefaultFirebaseOptions.isCurrentPlatformConfigured] is false and
// push bootstrap skips FCM so invalid keys are never sent to native Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for `Firebase.initializeApp`.
class DefaultFirebaseOptions {
  /// Whether [currentPlatform] was replaced with real values from
  /// `flutterfire configure` (template placeholders are still present otherwise).
  static bool get isCurrentPlatformConfigured {
    final FirebaseOptions o = currentPlatform;
    if (o.apiKey.isEmpty || o.apiKey == 'REPLACE_ME') return false;
    if (o.projectId.isEmpty || o.projectId == 'replace-with-your-project-id') {
      return false;
    }
    if (o.messagingSenderId == '000000000000') return false;
    return true;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-project-id',
    storageBucket: 'replace-with-your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-project-id',
    storageBucket: 'replace-with-your-project-id.appspot.com',
    iosBundleId: 'com.quiz.battle',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-project-id',
    storageBucket: 'replace-with-your-project-id.appspot.com',
  );
}
