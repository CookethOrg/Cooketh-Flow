import 'package:cookethflow/app.dart';
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/auth/providers/auth_provider.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/js.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String supabaseUrl;
  String supabaseApiKey;

  //  Load environment variables
  if (kIsWeb) {
    // For web, use --dart-define values
    supabaseUrl = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    supabaseApiKey = const String.fromEnvironment(
      'SUPABASE_KEY',
      defaultValue: '',
    );
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SupabaseService>(
          create: (_) => SupabaseService(instance.client),
        ),
        ChangeNotifierProxyProvider<SupabaseService, AuthenticationProvider>(
          create:
              (ctx) => AuthenticationProvider(
                Provider.of<SupabaseService>(ctx, listen: false),
              ),
          update:
              (context, supabaseService, previousAuth) =>
                  previousAuth ?? AuthenticationProvider(supabaseService),
        ),
        ChangeNotifierProvider(
          create:
              (ctx) => DashboardProvider(
                instance.client,
                Provider.of<SupabaseService>(ctx, listen: false),
              ),
          // update:
          //     (context, auth, previous) => previous ?? DashboardProvider(auth),
        ),
        ChangeNotifierProvider<WorkspaceProvider>(
          create:
              (context) => WorkspaceProvider(
                Provider.of<SupabaseService>(context, listen: false),
                Provider.of<DashboardProvider>(context, listen: false),
              ),
        ),
        ChangeNotifierProvider<CanvasProvider>(
          create:
              (context) => CanvasProvider(
                Provider.of<WorkspaceProvider>(context, listen: false),
              ),
        ),
        ChangeNotifierProvider(create: (context)=>ShortcutManagerr())
      ],
      child: const MyApp(),
    ),
  );
}
