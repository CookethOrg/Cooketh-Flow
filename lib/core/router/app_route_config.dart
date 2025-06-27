import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/features/auth/pages/login.dart';
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
      ],
    );
    return routes;
  }
}
