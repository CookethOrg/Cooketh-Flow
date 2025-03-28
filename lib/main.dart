import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/utils/update_manager.dart';
import 'package:cookethflow/providers/dashboard_provider.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/loading_provider.dart';
import 'package:cookethflow/screens/discarded/node_provider.dart';
import 'package:cookethflow/screens/dashboard.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/loading.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:cookethflow/screens/sign_up.dart';
import 'package:cookethflow/screens/workspace.dart';
import 'package:cookethflow/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  String supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "Url";
  String supabaseApiKey = dotenv.env["SUPABASE_KEY"] ?? "your_api_key";

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
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UpdateManager _updateManager = UpdateManager();
  bool _hasCheckedForUpdates = false;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }
  
  Future<void> _checkForUpdates() async {
    if (!_hasCheckedForUpdates) {
      _hasCheckedForUpdates = true;
      // Wait a short time to let the app finish initializing
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _updateManager.checkAndPromptForUpdate(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPage(),
    );
  }
}