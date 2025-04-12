import 'dart:io';

import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/providers/dashboard_provider.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/loading_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/auth_screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file only in development (when environment variables are not set)
  String supabaseUrl;
  String supabaseApiKey;

  // Check if running in a production build (e.g., GitHub Actions) with environment variables
  if(kIsWeb || !(Platform.environment.containsKey('SUPABASE_URL') &&
      Platform.environment.containsKey('SUPABASE_KEY'))){
        // Fallback to .env file for local development
    await dotenv.load(fileName: '.env');
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'Url';
    supabaseApiKey = dotenv.env['SUPABASE_KEY'] ?? 'your_api_key';
  }
  else {
    supabaseUrl = Platform.environment['SUPABASE_URL']!;
    supabaseApiKey = Platform.environment['SUPABASE_KEY']!;
  }

  final instance = await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseApiKey,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<SupabaseService>(
          create: (_) => SupabaseService(instance.client)),
      ChangeNotifierProxyProvider<SupabaseService, AuthenticationProvider>(
        create: (ctx) => AuthenticationProvider(
            Provider.of<SupabaseService>(ctx, listen: false)),
        update: (context, supabaseService, previousAuth) =>
            previousAuth ?? AuthenticationProvider(supabaseService),
      ),
      ChangeNotifierProxyProvider<SupabaseService, FlowmanageProvider>(
          create: (context) => FlowmanageProvider(
              Provider.of<SupabaseService>(context, listen: false)),
          update: (context, supabaseService, previousFlowProvider) =>
              previousFlowProvider ?? FlowmanageProvider(supabaseService)),
      ChangeNotifierProxyProvider<FlowmanageProvider, WorkspaceProvider>(
        create: (context) => WorkspaceProvider(
            Provider.of<FlowmanageProvider>(context, listen: false)),
        update: (context, flowManage, previousWorkspace) =>
            previousWorkspace ?? WorkspaceProvider(flowManage),
      ),
      ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider()),
      ChangeNotifierProvider<LoadingProvider>(create: (_) => LoadingProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}