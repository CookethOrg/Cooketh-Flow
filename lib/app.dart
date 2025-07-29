import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/router/app_route_config.dart';
import 'package:cookethflow/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
      child: Consumer<SupabaseService>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouteConfig.returnRouter(),
            localizationsDelegates: const [
              // GlobalMaterialLocalizations.delegate,
              // GlobalWidgetsLocalizations.delegate,
              // GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate, // REQUIRED for flutter_quill
            ],
            // NEW: Define supported locales (at least English for now)
            supportedLocales: const [
              Locale('en', ''), // English
              // Add other locales your app supports if needed, e.g., Locale('es', '') for Spanish
            ],
          );
        },
      ),
    );
  }
}