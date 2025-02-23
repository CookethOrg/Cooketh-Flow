// import 'package:cookethflow/core/services/hive_auth_storage.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  String supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "Url";
  String supabaseApiKey = dotenv.env["SUPABASE_KEY"] ?? "your_api_key";
  // await Hive.initFlutter();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseApiKey,
  );
  runApp(MultiProvider(
    providers: [

      ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider()),
      ChangeNotifierProvider<FlowmanageProvider>(
          create: (_) => FlowmanageProvider(AuthenticationProvider())),
      // ChangeNotifierProvider<NodeProvider>(
      //     create: (_) => NodeProvider(ProviderState.loaded)),
      ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider()),
      ChangeNotifierProvider<WorkspaceProvider>(
          create: (_) => WorkspaceProvider(ProviderState.loaded)),
      ChangeNotifierProvider<LoadingProvider>(create: (_) => LoadingProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: Workspace(flowId: "1"),
      home: SignupPage(),
      // home: Dashboard(),
      // home: TestScreen(),
    );
  }
}
