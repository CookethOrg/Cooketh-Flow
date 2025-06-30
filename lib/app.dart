import 'package:cookethflow/core/router/app_route_config.dart';
import 'package:cookethflow/features/auth/pages/login.dart';
import 'package:cookethflow/features/auth/pages/signup.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
    routerConfig: AppRouteConfig.returnRouter(),
    );
  }
}