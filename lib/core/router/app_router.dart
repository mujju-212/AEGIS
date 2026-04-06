import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:privacy_ai/features/onboarding/presentation/screens/device_scan_screen.dart';
import 'package:privacy_ai/features/onboarding/presentation/screens/model_selection_screen.dart';
import 'package:privacy_ai/features/onboarding/presentation/screens/model_download_screen.dart';
import 'package:privacy_ai/features/onboarding/presentation/screens/setup_questions_screen.dart';
import 'package:privacy_ai/features/onboarding/presentation/screens/permission_setup_screen.dart';
import 'package:privacy_ai/features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import 'package:privacy_ai/features/home/presentation/screens/home_screen.dart';
import 'package:privacy_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:privacy_ai/features/wellbeing/presentation/screens/wellbeing_screen.dart';
import 'package:privacy_ai/features/agents/presentation/screens/agents_screen.dart';
import 'package:privacy_ai/features/transparency/presentation/screens/transparency_screen.dart';
import 'package:privacy_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:privacy_ai/features/rigorous_mode/presentation/screens/rigorous_mode_screen.dart';
import 'package:privacy_ai/features/memory/presentation/screens/memory_screen.dart';
import 'package:privacy_ai/core/router/app_shell.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    routes: [
      // ─── Onboarding Flow ───────────────────────────
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/device-scan',
        builder: (context, state) => const DeviceScanScreen(),
      ),
      GoRoute(
        path: '/model-selection',
        builder: (context, state) => const ModelSelectionScreen(),
      ),
      GoRoute(
        path: '/model-download',
        builder: (context, state) => const ModelDownloadScreen(),
      ),
      GoRoute(
        path: '/setup-questions',
        builder: (context, state) => const SetupQuestionsScreen(),
      ),
      GoRoute(
        path: '/permission-setup',
        builder: (context, state) => const PermissionSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding-complete',
        builder: (context, state) => const OnboardingCompleteScreen(),
      ),

      // ─── Main App Shell with Bottom Nav ────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/wellbeing',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WellbeingScreen(),
            ),
          ),
          GoRoute(
            path: '/agents',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AgentsScreen(),
            ),
          ),
          GoRoute(
            path: '/transparency',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransparencyScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // ─── Standalone Screens ────────────────────────
      GoRoute(
        path: '/rigorous-mode',
        builder: (context, state) => const RigorousModeScreen(),
      ),
      GoRoute(
        path: '/memory',
        builder: (context, state) => const MemoryScreen(),
      ),
    ],
  );
}
