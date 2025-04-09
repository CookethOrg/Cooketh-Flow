import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/providers/dashboard_provider.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/loading_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/auth_screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: '.env');

  // Get environment variables with fallback
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://default.supabase.co'; // Fallback URL
  String supabaseApiKey = dotenv.env['SUPABASE_KEY'] ?? 'your_api_key';

  // Ensure the URL starts with a scheme (e.g., https://)
  if (!supabaseUrl.startsWith('http://') && !supabaseUrl.startsWith('https://')) {
    supabaseUrl = 'https://$supabaseUrl';
  }

  try {
    final instance = await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseApiKey,
      debug: true, // Enable debug logs to trace issues
    );

    print('Supabase initialized with URL: $supabaseUrl');

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
      child: MyApp(),
    ));
  } catch (e) {
    print('Error initializing Supabase: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    ));
  }
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