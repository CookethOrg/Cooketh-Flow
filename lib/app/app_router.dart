import 'package:cookethflow/presentation/auth_screens/log_in.dart';
import 'package:cookethflow/presentation/auth_screens/sign_up.dart';
import 'package:cookethflow/presentation/auth_screens/splash_screen.dart';
import 'package:cookethflow/presentation/dashboard_screens/dashboard.dart';
import 'package:cookethflow/presentation/workspace_screens/workspace.dart';
import 'package:cookethflow/utilities/enums/app_view.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  GoRouter get router => GoRouter(
        initialLocation: AppView.splash.path,
        routes: [
          _splashScreenRoute,
          _signUpRoute,
          _logInRoute,
          _dashboardRoute,
          _workspaceRoute,
        ],
      );
  //---------------------------------------------------------------------------------
  // splash screen route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _splashScreenRoute = GoRoute(
    path: AppView.splash.path,
    name: AppView.splash.name,
    builder: (context, state) => const SplashScreen(),
  );
  //---------------------------------------------------------------------------------
  // sign up route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _signUpRoute = GoRoute(
    path: AppView.signUp.path,
    name: AppView.signUp.name,
    builder: (context, state) => const SignupPage(),
  );
  //---------------------------------------------------------------------------------
  // log in route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _logInRoute = GoRoute(
    path: AppView.logIn.path,
    name: AppView.logIn.name,
    builder: (context, state) => const LoginPage(),
  );
  //---------------------------------------------------------------------------------
  // dashboard route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _dashboardRoute = GoRoute(
    path: AppView.dashboard.path,
    name: AppView.dashboard.name,
    builder: (context, state) => const Dashboard(),
  );
  //---------------------------------------------------------------------------------
  // workspace route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _workspaceRoute = GoRoute(
      path: "${AppView.workspace.path}/:flowId",
      name: AppView.workspace.name,
      builder: (context, state) => Workspace(
            flowId: state.pathParameters['flowId'] ?? '',
          ));
}
