# Quiz Battle (Flutter)

Clean architecture scaffold: Riverpod, Dio (`/api/v1`), secure JWT storage, FCM device token, `go_router`, and `flutter_dotenv`.

## Prerequisites

Install the [latest stable Flutter](https://docs.flutter.dev/get-started/install) and ensure `flutter` / `dart` are on your `PATH`.

## First-time setup

1. From this directory:

   ```bash
   flutter pub get
   ```

2. Environment file: copy `assets/env/.env.example` to `assets/env/.env` and set `API_BASE_URL` to your API host (no `/api/v1` suffix; that path is appended in `lib/core/config/env_config.dart` only).

   REST contracts should match `../backend/` (see `.cursor/rules/mobile-flutter-backend-api.mdc`).

3. Auth uses **secure storage** for JWTs and sends `x-app-version` / `x-device-type` on every request (required by the backend). App version comes from `pubspec.yaml` via `package_info_plus`.

4. If `android/` or `ios/` folders are missing (manual scaffold), generate platform projects:

   ```bash
   flutter create . --project-name quiz_battle
   ```

5. **Firebase Cloud Messaging (required for real push tokens):**

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   That regenerates `lib/firebase_options.dart` and platform config files. Then:

   - **Android:** add `google-services.json` under `android/app/` and apply the [FlutterFire Android Gradle steps](https://firebase.google.com/docs/flutter/setup?platform=android) (Google services plugin). On Android 13+, notification permission is requested at runtime via `FirebaseMessaging.requestPermission`.
   - **iOS:** add `GoogleService-Info.plist` in Xcode, enable **Push Notifications**, and set up APNs in the Firebase console.

   Until Firebase is configured, the app still sends a non-empty `deviceToken` using a persisted client fallback (`StorageKeys.clientDevicePushKey`) so auth APIs validate.

6. **App icon (optional):** after `flutter create .` generates `android/` / `ios/`, run:

   ```bash
   dart run flutter_launcher_icons
   ```

   This uses `assets/branding/app_logo.png` (same asset as the splash screen).

7. Run:

   ```bash
   flutter run
   ```

## Layout

See `lib/` for `core/`, `features/{auth,home,quiz,attempt}/`, and `routes/`. Auth (login/signup) and a minimal home shell are implemented; quiz flows are still stubs.

Design constraints: `UI_DESIGN_RULES.md`.
