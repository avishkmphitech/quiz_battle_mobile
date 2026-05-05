import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/features/auth/presentation/widgets/app_logo.dart';
import 'package:quiz_battle/routes/route_paths.dart';

/// Branded splash: logo asset, app name, ~2.5s, then intro (first launch) or home/login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const Duration displayDuration = Duration(milliseconds: 2500);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _resolvingAuth = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    unawaited(_controller.forward());
    unawaited(_runFlow());
  }

  Future<void> _runFlow() async {
    await Future<void>.delayed(SplashScreen.displayDuration);
    if (!mounted) return;

    final prefs = ref.read(appPreferencesProvider);
    if (!prefs.hasSeenIntro) {
      context.go(RoutePaths.intro);
      return;
    }

    await _goHomeOrLogin();
  }

  Future<void> _goHomeOrLogin() async {
    if (!mounted) return;
    setState(() => _resolvingAuth = true);
    final token = await ref.read(authTokenStoreProvider).readAccessToken();
    if (!mounted) return;
    setState(() => _resolvingAuth = false);
    final loggedIn = token != null && token.isNotEmpty;
    context.go(loggedIn ? RoutePaths.home : RoutePaths.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 220),
                const SizedBox(height: 32),
                Text(
                  'Quiz Battle App',
                  style: textTheme.headlineSmall?.copyWith(
                    color: context.palette.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Quick quizzes. Clear scores.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_resolvingAuth) ...[
                  const SizedBox(height: 36),
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: context.palette.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Checking session…',
                    style: textTheme.bodySmall?.copyWith(color: context.palette.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
