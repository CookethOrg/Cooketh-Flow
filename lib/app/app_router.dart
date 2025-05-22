import 'package:cookethflow/presentation/dashboard/view_model.dart';
import 'package:cookethflow/presentation/log_in/view.dart';
import 'package:cookethflow/presentation/log_in/view_model.dart';
import 'package:cookethflow/presentation/sign_up/view.dart';
import 'package:cookethflow/presentation/sign_up/view_model.dart';
import 'package:cookethflow/presentation/slash_screen/view.dart';
import 'package:cookethflow/presentation/dashboard/view.dart';
import 'package:cookethflow/presentation/slash_screen/view_model.dart';
import 'package:cookethflow/presentation/workspace/view.dart';
import 'package:cookethflow/presentation/workspace/view_model.dart';
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
    builder: (context, state) => SplashScreenView(
      viewModel: SplashScreenViewModel(),
    ),
  );
  //---------------------------------------------------------------------------------
  // sign up route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _signUpRoute = GoRoute(
    path: AppView.signUp.path,
    name: AppView.signUp.name,
    builder: (context, state) => SignUpView(
      viewModel: SignUpViewModel(),
    ),
  );
  //---------------------------------------------------------------------------------
  // log in route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _logInRoute = GoRoute(
    path: AppView.logIn.path,
    name: AppView.logIn.name,
    builder: (context, state) => LogInView(
      viewModel: LogInViewModel(),
    ),
  );
  //---------------------------------------------------------------------------------
  // dashboard route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _dashboardRoute = GoRoute(
    path: AppView.dashboard.path,
    name: AppView.dashboard.name,
    builder: (context, state) => DashboardView(
      viewModel: DashboardViewModel(),
    ),
  );
  //---------------------------------------------------------------------------------
  // workspace route --------------------------------------------------------------
  //---------------------------------------------------------------------------------
  final _workspaceRoute = GoRoute(
      path: "${AppView.workspace.path}/:flowId",
      name: AppView.workspace.name,
      builder: (context, state) => WorkspaceView(
            viewModel: WorkspaceViewModel(),
            flowId: state.pathParameters['flowId'] ?? '',
          ));
}
