import 'package:cookethflow/app.dart';
import 'package:cookethflow/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider())
  ],child: const MyApp(),));
}
