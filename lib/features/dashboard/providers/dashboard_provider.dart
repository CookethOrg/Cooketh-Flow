import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardProvider extends StateHandler {
  late SupabaseClient? supabase;
  late SupabaseService supabaseService;
  DashboardProvider(this.supabase, this.supabaseService) : super() {
    initialize();
  }

  // properties
  bool _isDrawerOpen = true;
  int _tabIndex = 0;
  bool _isLoading = false;
  bool _isInitialized = false;
  List<WorkspaceModel> _workspaceList = [];

  // getters
  bool get isDrawerOpen => _isDrawerOpen;
  int get tabIndex => _tabIndex;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  List<WorkspaceModel> get workspaceList => _workspaceList;

  List<Map<String, dynamic>> tabItems = [
    {"label": "All", "icon": Icon(PhosphorIcons.cardsThree())},
    {"label": "Starred", "icon": Icon(PhosphorIcons.star())},
    {"label": "Trash", "icon": Icon(PhosphorIcons.trashSimple())},
    {"label": "About us", "icon": Icon(PhosphorIcons.info())},
  ];

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void toggleTab(int idx) {
    if (_tabIndex != idx) {
      _tabIndex = idx;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initializeUser();
      print("function called");
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    try {
      var res = supabase?.auth.currentUser;
      if (res == null) {
        print("No Authenticated user found during initialization.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // print(res.id);
      try {
        List<dynamic> _dbWorkspace = await supabase!
            .from('workspace')
            .select()
            .eq('owner', res.id);
        print(_dbWorkspace);
        _workspaceList.clear();
        for (var workspace in _dbWorkspace) {
          WorkspaceModel newWorkspace = WorkspaceModel(
            id: workspace["id"],
            owner: workspace["owner"],
            name: workspace["name"],
            editorIdList: workspace["editorId"] ?? [],
            viewerIdList: workspace["viewerId"] ?? [],
            lastEdited: DateTime.parse(workspace["last edited"]),
          );
          // print(workspace);
          _workspaceList.add(newWorkspace);
        }
      } catch (e) {
        print("Error parsing workspaces: $e");
      }
    } catch (e) {
      print("Error initialising user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void createNewProject(BuildContext context) {}

  void importExistingProject(BuildContext context) {}
}
