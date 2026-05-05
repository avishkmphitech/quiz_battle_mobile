import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/presentation/widgets/app_loading.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';
import 'package:quiz_battle/routes/route_paths.dart';

/// Short onboarding (1–2 slides) before login/home. Shown once until reset.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _finishing = false;

  List<_SlideData> _slides(AppPalette p) => [
        _SlideData(
          title: 'Pick a quiz',
          body: 'Browse active quizzes and jump in when you are ready.',
          icon: Icons.quiz_outlined,
          accent: p.orange,
        ),
        _SlideData(
          title: 'Climb the scoreboard',
          body: 'Each correct answer counts. Submit once and see how you did.',
          icon: Icons.emoji_events_outlined,
          accent: p.emerald,
        ),
      ];

  Future<void> _finish() async {
    setState(() => _finishing = true);
    try {
      await ref.read(appPreferencesProvider).setIntroSeen();
      if (!mounted) return;
      final token = await ref.read(authTokenStoreProvider).readAccessToken();
      if (!mounted) return;
      final loggedIn = token != null && token.isNotEmpty;
      context.go(loggedIn ? RoutePaths.home : RoutePaths.login);
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _onNext() {
    if (_finishing) return;
    final slides = _slides(context.palette);
    if (_page < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      unawaited(_finish());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final slides = _slides(p);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _finishing ? null : () => unawaited(_finish()),
            child: Text(
              'Skip',
              style: textTheme.labelLarge?.copyWith(color: p.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final s = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: p.card,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: s.accent.withOpacity(0.35),
                            ),
                          ),
                          child: Icon(s.icon, size: 48, color: s.accent),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          s.title,
                          style: textTheme.headlineSmall?.copyWith(
                            color: p.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s.body,
                          style: textTheme.bodyLarge?.copyWith(
                            color: p.textSecondary,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? p.orange : p.textMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _finishing ? null : _onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: p.orange,
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _finishing
                      ? const AppButtonProgress()
                      : Text(
                          _page < slides.length - 1 ? 'Next' : 'Get started',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SlideData {
  const _SlideData({
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accent;
}
