import 'package:cookethflow/app.dart';
import 'package:cookethflow/core/routes/app_route_config.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/loading_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/auth_screens/splash_screen.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl;
  String supabaseApiKey;

  //  Load environment variables
  if (kIsWeb) {
    // For web, use --dart-define values
    supabaseUrl =
        const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    supabaseApiKey =
        const String.fromEnvironment('SUPABASE_KEY', defaultValue: '');
  } else {
    // For non-web platforms, load from .env
    await dotenv.load(fileName: '.env');
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseApiKey = dotenv.env['SUPABASE_KEY'] ?? '';
  }

  // Validate environment variables
  if (supabaseUrl.isEmpty || supabaseApiKey.isEmpty) {
    throw Exception('SUPABASE_URL and SUPABASE_KEY must be provided');
  }

  final instance = await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseApiKey,
  );
  usePathUrlStrategy();

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
      ChangeNotifierProvider<LoadingProvider>(create: (_) => LoadingProvider()),
    ],
    child: const MyApp(),
  ));
}