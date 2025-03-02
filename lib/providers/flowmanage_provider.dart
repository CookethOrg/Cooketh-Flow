import 'dart:io';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/user.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlowmanageProvider extends StateHandler {
  UserModel user = UserModel();
  late final SupabaseService supabaseService;
  late final SupabaseClient supabase;
  // String supabaseUrl;
  // String supabaseApiKey;
  final Map<String, FlowManager> _flowList = {"1": FlowManager(flowId: "1")};
  String _newFlowId = "";

  FlowmanageProvider(this.supabaseService) : super() {
    supabase = supabaseService.supabase;
    _initializeUser();
  }

  Map<String, FlowManager> get flowList => _flowList;
  String get newFlowId => _newFlowId;

  void recentFlowId(String val) {
    _newFlowId = val;
    notifyListeners();
  }

  Future<void> _initializeUser() async {
    try {
      var res = await supabaseService.fetchCurrentUserDetails();
      if (res == null) {
        print('No authenticated user found during initialization');
        return;
      }

      if (res['flowList'] != null) {
        // Convert the database flowList to FlowManager objects
        Map<String, dynamic> dbFlowList =
            Map<String, dynamic>.from(res['flowList']);
        _flowList.clear();
        dbFlowList.forEach((key, value) {
          var flowManager = FlowManager(flowId: key);
          // Here you could also restore the nodes and connections if needed
          _flowList[key] = flowManager;
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing user: $e');
    }
  }

  Future<void> updateFlowList() async {
    try {
      var res = await supabaseService.fetchCurrentUserDetails();
      var currentUser = supabaseService.userData;

      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Convert FlowManager objects to JSON
      final flowListJson = {};
      _flowList.forEach((key, value) {
        flowListJson[key] = value.exportFlow();
      });

      await supabase
          .from('User')
          .update({'flowList': flowListJson}).eq('id', currentUser.user!.id);
    } catch (e) {
      print('Error updating flow list: $e');
      rethrow;
    }
  }

  Future<void> addFlow() async {
    try {
      var currentUser = supabaseService.userData;

      if (currentUser == null) {
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
      rethrow;
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
