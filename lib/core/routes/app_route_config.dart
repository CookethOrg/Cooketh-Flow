import 'package:cookethflow/core/routes/app_route_const.dart';
import 'package:cookethflow/presentation/auth_screens/log_in.dart';
import 'package:cookethflow/presentation/auth_screens/sign_up.dart';
import 'package:cookethflow/presentation/auth_screens/splash_screen.dart';
import 'package:cookethflow/presentation/dashboard_screens/dashboard.dart';
import 'package:cookethflow/presentation/workspace_screens/workspace.dart';
import 'package:go_router/go_router.dart';

class AppRouteConfig {
  static GoRouter returnRouter() {
    GoRouter routes = GoRouter(routes: [
      GoRoute(
        path: RoutesPath.splashScreen,
        name: RouteName.splashScreen,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: RoutesPath.signUpScreen,
        name: RouteName.signUpScreen,
        builder: (context, state) => SignupPage(),
      ),
      GoRoute(
        path: RoutesPath.loginScreen,
        name: RouteName.loginScreen,
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: RoutesPath.dashboard,
        name: RouteName.dashboard,
        builder: (context, state) => Dashboard(),
      ),
      GoRoute(
          path: '${RoutesPath.workspace}/:flowId',
          name: RouteName.workspace,
          builder: (context, state) {
            final flowId = state.pathParameters['flowId'] ?? '';
            return Workspace(flowId: flowId);
          }),
    ]);
    return routes;
  }
}
