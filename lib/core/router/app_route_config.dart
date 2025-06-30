import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/features/auth/pages/login.dart';
import 'package:cookethflow/features/auth/pages/signup.dart';
import 'package:cookethflow/features/dashboard/pages/dashboard.dart';
import 'package:go_router/go_router.dart';

class AppRouteConfig {
  static GoRouter returnRouter() {
    GoRouter routes = GoRouter(
      routes: [
        GoRoute(
          path: RoutesPath.loginScreen,
          name: RouteName.loginScreen,
          builder: (context, state) {
            return LoginPage();
          },
        ),
        GoRoute(
          path: RoutesPath.signUpScreen,
          name: RouteName.signUpScreen,
          builder: (context, state) {
            return SignupPage();
          },
        ),
        GoRoute(path: RoutesPath.dashboard,name: RouteName.dashboard,builder: (context, state) => DashboardPage(),)
      ],
    );
    return routes;
  }
}
