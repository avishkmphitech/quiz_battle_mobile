import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] to re-run redirects (e.g. after login/logout).
final class RouterRefreshNotifier extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}
