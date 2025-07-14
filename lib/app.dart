import 'package:cookethflow/core/router/app_route_config.dart';
import 'package:cookethflow/core/theme/app_theme.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: dashboardProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouteConfig.returnRouter(),
          );
        },
      ),
    );
  }
}