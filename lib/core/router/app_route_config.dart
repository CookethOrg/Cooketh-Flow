import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/features/auth/pages/login.dart';
import 'package:cookethflow/features/auth/pages/signup.dart';
import 'package:cookethflow/features/dashboard/pages/dashboard.dart';
import 'package:cookethflow/features/workspace/pages/workspace.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouteConfig {
  static GoRouter returnRouter() {
    return GoRouter(
      initialLocation: RoutesPath.loginScreen,
      routes: [
        GoRoute(
          path: RoutesPath.loginScreen,
          name: RouteName.loginScreen,
          pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
        ),
        GoRoute(
          path: RoutesPath.signUpScreen,
          name: RouteName.signUpScreen,
          pageBuilder:
              (context, state) => NoTransitionPage(child: SignupPage()),
        ),
        GoRoute(
          path: '${RoutesPath.dashboard}/u/:username',
          name: RouteName.dashboard,
          pageBuilder: (context, state) {
            final username = state.pathParameters["username"];
            return NoTransitionPage(child: DashboardPage());
          },
        ),
        GoRoute(
          path: '${RoutesPath.workspace}/:workspace_id',
          name: RouteName.workspace,
          pageBuilder: (context, state) {
            final workspace_id = state.pathParameters['workspace_id'];
            return NoTransitionPage(child: WorkspacePage());
          },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        // Add your authentication logic here if needed
        return null;
      },
    );
  }
}
