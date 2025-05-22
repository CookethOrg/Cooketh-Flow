import 'package:cookethflow/core/routes/app_route_config.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouteConfig.returnRouter(),
      // home: const SplashScreen(),
    );
  }
}
