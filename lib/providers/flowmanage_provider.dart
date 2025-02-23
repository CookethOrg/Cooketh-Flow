import 'dart:io';

import 'package:cookethflow/core/utils/utils.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/user.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlowmanageProvider extends StateHandler {
  UserModel user = UserModel();
  late AuthenticationProvider auth;
  late final SupabaseClient supabase;
  String supabaseUrl;
  String supabaseApiKey;
  Map<String, FlowManager> _flowList = {"1": FlowManager(flowId: "1")};
  String _newFlowId = "";

  FlowmanageProvider(this.auth)
      : supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "Url",
        supabaseApiKey = dotenv.env["SUPABASE_KEY"] ?? "your_api_key",
        super() {
    // HttpOverrides.global = MyHttpOverrides();
    supabase = SupabaseClient(
      supabaseUrl,
      supabaseApiKey,
      authOptions: AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    _initializeUser();
  }

  Map<String, FlowManager> get flowList => _flowList;
  String get newFlowId => _newFlowId;
  // bool get isLoading => _isLoading;

  void recentFlowId(String val) {
    _newFlowId = val;
    notifyListeners();
  }

  Future<void> _initializeUser() async {
    try {
      var res = await auth.fetchCurrentUserDetails();
      if (res == null) {
        throw Exception('No authenticated user found');
      }

      if (res != null && res['flowList'] != null) {
        // Convert the database flowList to FlowManager objects
        Map<String, dynamic> dbFlowList =
            Map<String, dynamic>.from(res['flowList']);

        _flowList.clear();
        dbFlowList.forEach((key, value) {
          var flowManager = FlowManager(flowId: key);
          // Here you could also restore the nodes and connections if needed
          _flowList[key] = flowManager;
        });
      }
    } catch (e) {
      print('Error initializing user: $e');
    }
  }

  Future<void> updateFlowList() async {
    try {
      var res = await auth.fetchCurrentUserDetails();
      var us = await auth.userData.user;

      if (res == null) {
        throw Exception('No authenticated user found');
      }

      // Convert FlowManager objects to JSON
      final flowListJson = {};
      _flowList.forEach((key, value) {
        flowListJson[key] = value.exportFlow();
      });

      await supabase
          .from('User')
          .update({'flowList': flowListJson}).eq('id', us!.id);
    } catch (e) {
      print('Error updating flow list: $e');
      throw e;
    }
  }

  Future<void> addFlow() async {
    try {
      var res = await auth.fetchCurrentUserDetails();
      print(res);

      if (res == null) {
        throw Exception('No authenticated user found');
      }

      final String newFlowId = (_flowList.length + 1).toString();
      FlowManager flowm = FlowManager(flowId: newFlowId);

      _flowList[newFlowId] = flowm;
      _newFlowId = newFlowId;

      await updateFlowList();
      notifyListeners();
    } catch (e) {
      print('Error adding flow: $e');
      throw e;
    }
  }

  Future<void> refreshFlowList() async {
    await _initializeUser();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
