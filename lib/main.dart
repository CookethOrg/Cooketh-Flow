import 'dart:io';

import 'package:cookethflow/core/services/supabase_service.dart';
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

  String supabaseUrl = 'https://dowultdujeltbsocghrt.supabase.co';
  // below is the public api key.
  String supabaseApiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvd3VsdGR1amVsdGJzb2NnaHJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2MjkyNzAsImV4cCI6MjA1NTIwNTI3MH0.tvkdm5klmbB4JvNPfZTcP5Z1AOtwpp1QGGvsnqwM2dk";

  // if (kIsWeb) {
  //   await dotenv.load(fileName: './dotenv');
  //   supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'Url';
  //   supabaseApiKey = dotenv.env['SUPABASE_KEY'] ?? 'your_api_key';
  // } else if (Platform.environment.containsKey('SUPABASE_URL') &&
  //     Platform.environment.containsKey('SUPABASE_KEY')) {
  //   supabaseUrl = Platform.environment['SUPABASE_URL']!;
  //   supabaseApiKey = Platform.environment['SUPABASE_KEY']!;
  // } else {
  //   await dotenv.load(fileName: '.env');
  //   supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'Url';
  //   supabaseApiKey = dotenv.env['SUPABASE_KEY'] ?? 'your_api_key';
  // }

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
