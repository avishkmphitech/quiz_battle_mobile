import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/routes/router_refresh.dart';

final routerRefreshNotifierProvider =
    Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
