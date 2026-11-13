import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/auth_provider.dart';
import '../../features/authentication/presentation/auth_page.dart';
import '../../features/authentication/presentation/profile_setup_page.dart';
import '../../features/authentication/presentation/splash_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/device/presentation/device_page.dart';
import '../../features/monitoring/presentation/monitoring_page.dart';
import '../../features/predictions/presentation/prediction_page.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/history/presentation/session_detail_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';
import '../theme/app_colors.dart';
import 'app_routes.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    redirect: _globalRedirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const ProfileSetupPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.device,
            builder: (context, state) => const DevicePage(),
          ),
          GoRoute(
            path: AppRoutes.monitoring,
            builder: (context, state) => const MonitoringPage(),
          ),
          GoRoute(
            path: AppRoutes.predictions,
            builder: (context, state) => const PredictionPage(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryPage(),
            routes: [
              GoRoute(
                path: ':sessionId',
                builder: (context, state) => SessionDetailPage(
                  sessionId: state.pathParameters['sessionId'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.errorText),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );

  GoRouter get router => _router;

  String? _globalRedirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final status = authProvider.status;

    final isOnSplash = path == AppRoutes.splash;
    final isOnLogin = path == AppRoutes.login;
    final isOnOnboarding = path == AppRoutes.onboarding;

    if (status == AuthStatus.unknown || status == AuthStatus.loading) {
      return isOnSplash ? null : AppRoutes.splash;
    }

    if (status == AuthStatus.authenticated) {
      if (!authProvider.isProfileComplete) {
        return isOnOnboarding ? null : AppRoutes.onboarding;
      }

      if (isOnSplash || isOnLogin || isOnOnboarding) {
        return AppRoutes.dashboard;
      }

      return null;
    }

    return isOnLogin ? null : AppRoutes.login;
  }
}

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  static const List<AppNavDestination> _destinations = [
    AppNavDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Home',
    ),
    AppNavDestination(
      icon: Icons.bluetooth_outlined,
      selectedIcon: Icons.bluetooth,
      label: 'Device',
    ),
    AppNavDestination(
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart,
      label: 'Monitor',
    ),
    AppNavDestination(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Results',
    ),
    AppNavDestination(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'History',
    ),
    AppNavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: _destinations,
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location == AppRoutes.dashboard) return 0;
    if (location == AppRoutes.device) return 1;
    if (location == AppRoutes.monitoring) return 2;
    if (location == AppRoutes.predictions) return 3;
    if (location.startsWith(AppRoutes.history)) return 4;
    if (location == AppRoutes.settings) return 5;

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.device);
        break;
      case 2:
        context.go(AppRoutes.monitoring);
        break;
      case 3:
        context.go(AppRoutes.predictions);
        break;
      case 4:
        context.go(AppRoutes.history);
        break;
      case 5:
        context.go(AppRoutes.settings);
        break;
    }
  }
}
