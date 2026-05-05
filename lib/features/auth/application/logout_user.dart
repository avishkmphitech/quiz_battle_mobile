import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/network/api_exception.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/features/auth/auth_providers.dart';
import 'package:quiz_battle/routes/route_paths.dart';
import 'package:quiz_battle/routes/router_refresh_provider.dart';

/// Clears tokens and cached profile, notifies router, navigates to login.
Future<void> logoutUser(WidgetRef ref, BuildContext context) async {
  try {
    await ref.read(authRepositoryProvider).logout();
  } on ApiException {
    // Continue clearing local session.
  } catch (_) {}
  await ref.read(authTokenStoreProvider).clear();
  await ref.read(appPreferencesProvider).clearCachedAuthUser();
  ref.invalidate(currentUserProfileProvider);
  ref.read(routerRefreshNotifierProvider).notifyAuthChanged();
  if (context.mounted) context.go(RoutePaths.login);
}
