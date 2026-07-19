import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/leaves/presentation/screens/leaves_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/chatbot/presentation/screens/chatbot_screen.dart';
import '../../features/enterprise/presentation/screens/enterprise_hub_screen.dart';
import '../../features/enterprise/presentation/screens/ai_assistant_screen.dart';
import '../../features/enterprise/presentation/screens/project_management_screen.dart';
import '../../features/enterprise/presentation/screens/collaboration_screen.dart';
import '../../features/enterprise/presentation/screens/document_management_screen.dart';
import '../../features/enterprise/presentation/screens/visitor_management_screen.dart';
import '../../features/enterprise/presentation/screens/asset_management_screen.dart';
import '../../features/enterprise/presentation/screens/finance_payroll_screen.dart';
import '../../features/enterprise/presentation/screens/learning_helpdesk_screen.dart';
import '../../features/enterprise/presentation/screens/wellness_recognition_screen.dart';
import '../../features/enterprise/presentation/screens/enterprise_settings_screen.dart';
import '../../shared/widgets/navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes to trigger GoRouter redirects
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState is AuthLoading || authState is AuthInitial;
      if (isLoading) return null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isLoggedIn = authState is AuthAuthenticated;

      if (!isLoggedIn) {
        // Force redirect to login if not logged in
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        // Redirect to dashboard if logged in and trying to access login
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return NavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/leaves',
            builder: (context, state) => const LeavesScreen(),
          ),
          GoRoute(
            path: '/chatbot',
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/enterprise',
            builder: (context, state) => const EnterpriseHubScreen(),
          ),
          GoRoute(
            path: '/enterprise/ai-assistant',
            builder: (context, state) => const AiAssistantScreen(),
          ),
          GoRoute(
            path: '/enterprise/projects',
            builder: (context, state) => const ProjectManagementScreen(),
          ),
          GoRoute(
            path: '/enterprise/collaboration',
            builder: (context, state) => const CollaborationScreen(),
          ),
          GoRoute(
            path: '/enterprise/documents',
            builder: (context, state) => const DocumentManagementScreen(),
          ),
          GoRoute(
            path: '/enterprise/visitors',
            builder: (context, state) => const VisitorManagementScreen(),
          ),
          GoRoute(
            path: '/enterprise/assets',
            builder: (context, state) => const AssetManagementScreen(),
          ),
          GoRoute(
            path: '/enterprise/finance',
            builder: (context, state) => const FinancePayrollScreen(),
          ),
          GoRoute(
            path: '/enterprise/learning-wellness',
            builder: (context, state) => const LearningHelpdeskScreen(),
          ),
          GoRoute(
            path: '/enterprise/wellness',
            builder: (context, state) => const WellnessRecognitionScreen(),
          ),
          GoRoute(
            path: '/enterprise/settings',
            builder: (context, state) => const EnterpriseSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

