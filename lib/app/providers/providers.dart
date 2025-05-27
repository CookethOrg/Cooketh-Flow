import 'package:cookethflow/data/services/supabase_service.dart';
import 'package:cookethflow/app/providers/authentication_provider.dart';
import 'package:cookethflow/app/providers/flowmanage_provider.dart';
import 'package:cookethflow/app/providers/loading_provider.dart';
import 'package:cookethflow/app/providers/workspace_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalProviders {
  //TODO: find a way to get rid of the supabase client object and turn this into a getter instead of a function
  List<SingleChildWidget> providers(SupabaseClient client) => [
        ChangeNotifierProvider<SupabaseService>(
            create: (_) => SupabaseService(client)),
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
        ChangeNotifierProvider<LoadingProvider>(
            create: (_) => LoadingProvider()),
      ];
}
