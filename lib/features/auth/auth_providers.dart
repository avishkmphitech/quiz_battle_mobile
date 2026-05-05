import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/features/auth/data/models/auth_user.dart';
import 'package:quiz_battle/features/auth/data/repositories/auth_repository.dart';
import 'package:quiz_battle/features/auth/data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(dioProvider),
    devicePushToken: ref.watch(devicePushTokenProvider),
  );
});

/// Live server profile (`GET /auth/me`). Invalidate after updating account server-side.
final currentUserProfileProvider = FutureProvider.autoDispose<AuthUser>((ref) {
  return ref.watch(authRepositoryProvider).fetchCurrentUser();
});
