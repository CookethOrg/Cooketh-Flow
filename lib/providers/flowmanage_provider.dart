import 'package:cookethflow/core/utils/utils.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlowmanageProvider extends StateHandler {
  UserModel user = UserModel();
  late final SupabaseClient supabase;
  String supabaseUrl;
  String supabaseApiKey;
  Map<String, FlowManager> _flowList = {"1": FlowManager(flowId: "1")};
  String _newFlowId = "";
  bool _isLoading = true;

  FlowmanageProvider()
      : supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "Url",
        supabaseApiKey = dotenv.env["SUPABASE_KEY"] ?? "your_api_key",
        super() {
    supabase = SupabaseClient(
      supabaseUrl,
      supabaseApiKey,
      authOptions: AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    _initializeUser();
  }

  Map<String, FlowManager> get flowList => _flowList;
  String get newFlowId => _newFlowId;
  bool get isLoading => _isLoading;

  void recentFlowId(String val) {
    _newFlowId = val;
    notifyListeners();
  }

  Future<void> _initializeUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final userData = await supabase
          .from('User')
          .select()
          .eq('id', currentUser.id)
          .single();

      if (userData != null && userData['flowList'] != null) {
        // Convert the database flowList to FlowManager objects
        Map<String, dynamic> dbFlowList =
            Map<String, dynamic>.from(userData['flowList']);

        _flowList.clear();
        dbFlowList.forEach((key, value) {
          var flowManager = FlowManager(flowId: key);
          // Here you could also restore the nodes and connections if needed
          _flowList[key] = flowManager;
        });
      }
    } catch (e) {
      print('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFlowList() async {
    try {
      final currentUser = supabase.auth.currentUser;
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
          .update({'flowList': flowListJson}).eq('id', currentUser.id);
    } catch (e) {
      print('Error updating flow list: $e');
      throw e;
    }
  }

  Future<void> addFlow() async {
    try {
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
