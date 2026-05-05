import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_battle/core/providers/theme_mode_provider.dart';
import 'package:quiz_battle/core/theme/app_theme.dart';
import 'package:quiz_battle/routes/app_router.dart';

class QuizBattleApp extends ConsumerWidget {
  const QuizBattleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }
}
