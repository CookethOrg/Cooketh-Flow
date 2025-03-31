import 'dart:io';
import 'dart:typed_data';
import 'package:cookethflow/core/services/file_services.dart';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/utils/ui_helper.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/models/user.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlowmanageProvider extends StateHandler {
  late final SupabaseService supabaseService;
  late final SupabaseClient supabase;
  final Map<String, FlowManager> _flowList = {};
  String _newFlowId = "";
  bool _isLoading = true;
  bool _isInitialized = false;

  FlowmanageProvider(this.supabaseService) : super() {
    supabase = supabaseService.supabase;
    // We'll initialize in a separate method that can be called after construction
  }

  Map<String, FlowManager> get flowList => _flowList;
  String get newFlowId => _newFlowId;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  void recentFlowId(String val) {
    if (_newFlowId != val) {
      _newFlowId = val;
      notifyListeners();
    }
  }

  // Call this method after the widget tree is built
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initializeUser();
      _isInitialized = true;
    }
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    // Do not notify listeners here during initialization
    
    try {
      var res = await supabaseService.fetchCurrentUserDetails();
      if (res == null) {
        print('No authenticated user found during initialization');
        _isLoading = false;
        notifyListeners(); // Safe to call here as we're outside the build phase
        return;
      }

      if (res['flowList'] != null) {
        // Clear existing flow list to avoid duplicates
        _flowList.clear();
        
        // Parse the database flow list
        Map<String, dynamic> dbFlowList = Map<String, dynamic>.from(res['flowList']);
        
        print("Fetched flowList from DB: $dbFlowList");
        
        // Create FlowManager objects from each flow in the database
        dbFlowList.forEach((flowId, flowData) {
          try {
            FlowManager flowManager = FlowManager.fromJson(flowData, flowId);
            _flowList[flowId] = flowManager;
            
            // If we have at least one flow, set it as the current one
            if (_newFlowId.isEmpty) {
              _newFlowId = flowId;
            }
          } catch (e) {
            print('Error parsing flow $flowId: $e');
          }
        });
        
        print("Loaded ${_flowList.length} flows");
      } else {
        print("No flows found in user data");
      }
    } catch (e) {
      print('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Safe to call here as we're outside the build phase
    }
  }

  Future<void> updateFlowList() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      var currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Create a serializable map of all flows
      final Map<String, dynamic> flowListJson = {};
      _flowList.forEach((key, value) {
        flowListJson[key] = value.exportFlow();
      });
      
      print("Updating flow list to Supabase: $flowListJson");

      // Update the database
      await supabase
          .from('User')
          .update({'flowList': flowListJson})
          .eq('id', currentUser.id);
          
      print("Flow list updated successfully");
    } catch (e) {
      print('Error updating flow list: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addFlow() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      var currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Generate a unique ID for the new flow
      final String newFlowId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create a new flow with the generated ID
      FlowManager flowManager = FlowManager(
        flowId: newFlowId,
        flowName: "New Project",
        // Create a default node for the new project
        nodes: {
          "1": FlowNode(
            id: "1",
            type: NodeType.rectangular,
            position: Offset(canvasDimension/2, canvasDimension/2),
            colour: Color(0xffFAD7A0),
          )
        }
      );
      
      // Add the flow to the local list
      _flowList[newFlowId] = flowManager;
      
      // Set this as the current flow
      recentFlowId(newFlowId);
      
      // Update the database with the new flow
      await updateFlowList();
      
      print("New flow created with ID: $newFlowId");
      return newFlowId;
    } catch (e) {
      print('Error adding flow: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFlowList() async {
    _isLoading = true;
    notifyListeners();
    await _initializeUser();
  }

Future<String> importWorkspace(Uint8List fileData, String fileName) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    var currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }
    
    // Parse the JSON file
    Map<String, dynamic>? jsonData = await FileServices().importJsonFile(fileData);
    if (jsonData == null) {
      throw Exception("Failed to parse JSON file");
    }
    
    // Generate a unique ID for the new flow
    final String newFlowId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Clean the filename to use as the flow name
    String flowName = fileName.replaceAll(RegExp(r'\.json$'), '');
    // Further clean the name if needed
    flowName = flowName.replaceAll(RegExp(r'_\d+$'), ''); // Remove timestamp if present
    
    // Create a new flow with the imported data and cleaned name
    FlowManager flowManager = FlowManager.fromJson(jsonData, newFlowId);
    flowManager.flowName = flowName;
    
    // Add the flow to the local list
    _flowList[newFlowId] = flowManager;
    
    // Set this as the current flow
    recentFlowId(newFlowId);
    
    // Update the database with the new flow
    await updateFlowList();
    
    _isLoading = false;
    notifyListeners();
    
    print("Imported flow created with ID: $newFlowId and name: $flowName");
    return newFlowId;
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    print('Error importing flow: $e');
    rethrow;
  }
}

Future<void> deleteWorkspace(String flowId) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    var currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    if (!_flowList.containsKey(flowId)) {
      throw Exception('Flow with ID $flowId not found');
    }
    
    // Remove the flow from the local list
    _flowList.remove(flowId);
    
    // Update newFlowId if necessary
    if (_newFlowId == flowId) {
      _newFlowId = _flowList.isNotEmpty ? _flowList.keys.first : "";
    }
    
    // Update the database
    await updateFlowList();
    
    print("Workspace deleted successfully: $flowId");
  } catch (e) {
    print('Error deleting workspace: $e');
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
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