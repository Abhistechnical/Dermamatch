import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/main_scaffold.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../screens/analysis/analysis_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/history/history_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (ctx, state) {
        final isAuth = authProvider.isAuthenticated;
        final loc = state.matchedLocation;

        final publicRoutes = ['/login', '/register'];
        final isPublic = publicRoutes.contains(loc);

        if (!isAuth && !isPublic) return '/login';
        if (isAuth && isPublic) return '/';
        return null;
      },
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (context, state) => const HistoryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/upload',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const UploadScreen(),
        ),
        GoRoute(
          path: '/analysis',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AnalysisScreen(),
        ),
        GoRoute(
          path: '/result',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ResultScreen(),
        ),
      ],
    );
  }
}
