import 'dart:io';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/user.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlowmanageProvider extends StateHandler {
  late final SupabaseService supabaseService;
  late final SupabaseClient supabase;
  final Map<String, FlowManager> _flowList = {"1": FlowManager(flowId: "1")};
  String _newFlowId = "1";

  FlowmanageProvider(this.supabaseService) : super() {
    supabase = supabaseService.supabase;
    _initializeUser();
  }

  Map<String, FlowManager> get flowList => _flowList;
  String get newFlowId => _newFlowId;

  void recentFlowId(String val) {
    if (_newFlowId != val) {
      _newFlowId = val;
      notifyListeners();
    }
  }

  Future<void> _initializeUser() async {
    try {
      var res = await supabaseService.fetchCurrentUserDetails();
      if (res == null) {
        print('No authenticated user found during initialization');
        return;
      }

      if (res['flowList'] != null) {
        Map<String, dynamic> dbFlowList =
            Map<String, dynamic>.from(res['flowList']);
        // _flowList.clear();
        dbFlowList.forEach((key, value) {
          // print(key);
          // print(value);
          var flowManager = FlowManager(
              flowId: key,
              connections: (value["connections"] as List<dynamic>).toSet(),
              flowName: value["flowName"],
              nodes: value["nodes"]);
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

      final flowListJson = {};
      _flowList.forEach((key, value) {
        flowListJson[key] = value.exportFlow();
      });
      print(_flowList);

      await supabase
          .from('User')
          .update({'flowList': flowListJson}).eq('id', currentUser.user!.id);
      notifyListeners();
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
      recentFlowId(newFlowId);
      notifyListeners();
      await updateFlowList();
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
