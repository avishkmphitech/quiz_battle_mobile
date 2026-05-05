import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/features/home/data/repositories/home_repository.dart';
import 'package:quiz_battle/features/home/data/repositories/home_repository_impl.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(dioProvider));
});
