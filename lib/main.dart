import 'package:cookethflow/app/app.dart';
import 'package:cookethflow/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

//TODO: most/all of this code needs to go away somewhere else
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
    providers: GlobalProviders().providers(instance.client),
    child: const App(),
  ));
}
