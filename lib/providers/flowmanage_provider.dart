import 'dart:io';
import 'dart:typed_data';
import 'package:cookethflow/core/routes/app_route_const.dart';
import 'package:cookethflow/core/services/file_services.dart';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/utils/ui_helper.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/presentation/workspace_screens/workspace.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    try {
      initialize();
      refreshFlowList();
    } catch (e) {
      dispose();
    }
  }

  Map<String, FlowManager> get flowList => _flowList;
  String get newFlowId => _newFlowId;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  void setLoading(bool val) {
    if (_isLoading != val) {
      _isLoading = val;
      notifyListeners();
    }
  }

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
      notifyListeners();
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
        Map<String, dynamic> dbFlowList =
            Map<String, dynamic>.from(res['flowList']);

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
    setLoading(true);

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
          .update({'flowList': flowListJson}).eq('id', currentUser.id);

      print("Flow list updated successfully");
    } catch (e) {
      print('Error updating flow list: $e');
      rethrow;
    } finally {
      setLoading(false);
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
              position: Offset(canvasDimension / 2, canvasDimension / 2),
              colour: nodeColors[0],
            )
          });

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
    setLoading(true);
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
      Map<String, dynamic>? jsonData =
          await FileServices().importJsonFile(fileData);
      if (jsonData == null) {
        throw Exception("Failed to parse JSON file");
      }

      // Generate a unique ID for the new flow
      final String newFlowId = DateTime.now().millisecondsSinceEpoch.toString();

      // Clean the filename to use as the flow name
      String flowName = fileName.replaceAll(RegExp(r'\.json$'), '');
      // Further clean the name if needed
      flowName = flowName.replaceAll(
          RegExp(r'_\d+$'), ''); // Remove timestamp if present

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

  Future<void> createNewProject(BuildContext context) async {
    try {
      String newFlowId = await addFlow();
      // Create a new instance of WorkspaceProvider just for this flow
      final workspaceProvider =
          Provider.of<WorkspaceProvider>(context, listen: false);
      // Initialize the workspace with the new flow ID
      workspaceProvider.initializeWorkspace(newFlowId);

      // Navigator.of(context)
      //     .push(
      //       MaterialPageRoute(
      //         builder: (context) => Workspace(flowId: newFlowId),
      //       ),
      //     )
      //     .then((_) => refreshFlowList());
      context.go('${RoutesPath.workspace}/:$newFlowId');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create project: $e')),
        );
      }
    }
  }

  Future<void> importExistingProject(BuildContext context) async {
    try {
      // Show a loading indicator while preparing
      setLoading(true);

      // Use our new file service instead of FilePicker
      final fileServices = FileServices();
      final fileData = await fileServices.importJsonFiles();
      print(fileData!.name);

      final fileBytes = await fileData.readAsBytes();

      // Import the workspace
      String newFlowId = await importWorkspace(
        fileBytes,
        fileData.name,
      );

      // Hide loading indicator
      setLoading(false);

      if (context.mounted) {
        // Create a new instance of WorkspaceProvider just for this flow
        final workspaceProvider =
            Provider.of<WorkspaceProvider>(context, listen: false);
        // Initialize the workspace with the new flow ID
        workspaceProvider.initializeWorkspace(newFlowId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project imported successfully!')),
        );

        // Navigator.of(context)
        //     .push(
        //       MaterialPageRoute(
        //         builder: (context) => Workspace(flowId: newFlowId),
        //       ),
        //     )
        //     .then((_) => refreshFlowList());
        context.go('${RoutesPath.workspace}/:$newFlowId');
      }
    } catch (e) {
      // Hide loading indicator
      setLoading(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing project: $e'),
            backgroundColor: deleteButtons,
          ),
        );
      }
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
