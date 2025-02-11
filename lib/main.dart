import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/providers/connection_provider.dart';
import 'package:cookethflow/providers/dashboard_provider.dart';
import 'package:cookethflow/providers/node_provider.dart';
import 'package:cookethflow/screens/dashboard.dart';
import 'package:cookethflow/screens/flow_builder.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<NodeProvider>(create: (_) => NodeProvider(ProviderState.loaded)),
      ChangeNotifierProvider<ConnectionProvider>(create: (_)=> ConnectionProvider()),
      ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider())
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
      home: LoginPage(),
    );
  }
}
