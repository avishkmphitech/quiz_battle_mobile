import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/providers/core_providers.dart';
import 'package:quiz_battle/features/auth/presentation/screens/intro_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/login_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/onboard_screen.dart';
import 'package:quiz_battle/features/auth/presentation/models/auth_flow_extras.dart';
import 'package:quiz_battle/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/reset_password_otp_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/signup_otp_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/signup_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/splash_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/legal_document_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/profile_edit_screen.dart';
import 'package:quiz_battle/features/auth/presentation/screens/user_profile_screen.dart';
import 'package:quiz_battle/features/home/presentation/screens/active_quizzes_screen.dart';
import 'package:quiz_battle/features/home/presentation/screens/dashboard_screen.dart';
import 'package:quiz_battle/features/home/presentation/screens/main_shell_screen.dart';
import 'package:quiz_battle/features/home/presentation/screens/profile_hub_screen.dart';
import 'package:quiz_battle/features/home/presentation/screens/quiz_stats_screen.dart';
import 'package:quiz_battle/features/attempt/presentation/models/quiz_result_args.dart';
import 'package:quiz_battle/features/attempt/presentation/screens/quiz_result_screen.dart';
import 'package:quiz_battle/features/quiz/data/models/active_quiz.dart';
import 'package:quiz_battle/features/quiz/presentation/screens/quiz_play_screen.dart';
import 'package:quiz_battle/routes/route_paths.dart';
import 'package:quiz_battle/routes/router_refresh_provider.dart';

final _publicPaths = <String>{
  RoutePaths.splash,
  RoutePaths.intro,
  RoutePaths.login,
  RoutePaths.signup,
  RoutePaths.signupOtp,
  RoutePaths.forgotPassword,
  RoutePaths.forgotPasswordReset,
  RoutePaths.onboard,
};

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshNotifierProvider);
  final tokens = ref.watch(authTokenStoreProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) async {
      final path = state.matchedLocation;
      final token = await tokens.readAccessToken();
      final loggedIn = token != null && token.isNotEmpty;
      final isLogin = path == RoutePaths.login;
      final isSignup = path == RoutePaths.signup;
      final isSignupOtp = path == RoutePaths.signupOtp;
      final isForgot = path == RoutePaths.forgotPassword;
      final isForgotReset = path == RoutePaths.forgotPasswordReset;
      final isOnboard = path == RoutePaths.onboard;

      if (!loggedIn && !_publicPaths.contains(path)) {
        return RoutePaths.login;
      }
      if (loggedIn &&
          (isLogin ||
              isSignup ||
              isSignupOtp ||
              isForgot ||
              isForgotReset ||
              isOnboard)) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.intro,
        name: RouteNames.intro,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.signupOtp,
        name: RouteNames.signupOtp,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! SignupOtpArgs) {
            return const _MissingAuthFlowScreen(
              title: 'Verification',
              message: 'Go back and tap Create account again.',
            );
          }
          return SignupOtpScreen(args: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPasswordReset,
        name: RouteNames.forgotPasswordReset,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! PasswordResetOtpArgs) {
            return const _MissingAuthFlowScreen(
              title: 'Reset password',
              message: 'Start again from Forgot password.',
            );
          }
          return ResetPasswordOtpScreen(args: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.onboard,
        name: RouteNames.onboard,
        builder: (context, state) => const OnboardScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.activeQuizzes,
                name: RouteNames.activeQuizzes,
                builder: (context, state) => const ActiveQuizzesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.profileHub,
                name: RouteNames.profileHub,
                builder: (context, state) => const ProfileHubScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.stats,
        name: RouteNames.stats,
        builder: (context, state) => const QuizStatsScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEdit,
        name: RouteNames.profileEdit,
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: RoutePaths.legalDocument,
        name: RouteNames.legalDocument,
        builder: (context, state) {
          final extra = state.extra;
          final kind = extra is LegalDocumentKind ? extra : LegalDocumentKind.terms;
          return LegalDocumentScreen(kind: kind);
        },
      ),
      GoRoute(
        path: RoutePaths.quizPlay,
        name: RouteNames.quizPlay,
        builder: (context, state) {
          final id = state.pathParameters['quizId'] ?? '';
          final extra = state.extra;
          final quiz = extra is ActiveQuiz ? extra : null;
          final title = quiz?.title ?? (extra is String ? extra : null);
          return QuizPlayScreen(
            quizId: id,
            quizTitle: title,
            initialQuiz: quiz != null && quiz.id == id ? quiz : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.quizResult,
        name: RouteNames.quizResult,
        builder: (context, state) {
          final id = state.pathParameters['quizId'] ?? '';
          if (id.isEmpty) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Missing quiz id.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            );
          }
          final extra = state.extra;
          final args = extra is QuizResultArgs
              ? extra
              : QuizResultArgs(
                  quizId: id,
                  quizTitle: 'Your result',
                  totalQuestions: 0,
                );
          return QuizResultScreen(args: args);
        },
      ),
    ],
  );
});

class _MissingAuthFlowScreen extends StatelessWidget {
  const _MissingAuthFlowScreen({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go(RoutePaths.login),
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
