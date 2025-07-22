import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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
  Map<String, WorkspaceModel> _workspaceList = {};

  // getters
  bool get isDrawerOpen => _isDrawerOpen;
  int get tabIndex => _tabIndex;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Map<String, WorkspaceModel> get workspaceList => _workspaceList;

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

  Future<void> refreshDashboard() async {
    await _initializeUser();
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

      try {
        List<dynamic> _dbWorkspace = await supabase!
            .from('workspace')
            .select()
            .eq('owner', res.id);
        _workspaceList.clear();
        for (var workspace in _dbWorkspace) {
          WorkspaceModel newWorkspace = WorkspaceModel(
            id: workspace["id"],
            owner: workspace["owner"],
            name: workspace["name"],
            editorIdList:
                (workspace["editorId"] as List?)?.cast<String>() ?? [],
            viewerIdList:
                (workspace["viewerId"] as List?)?.cast<String>() ?? [],
            lastEdited:
                workspace["last edited"] != null
                    ? DateTime.parse(workspace["last edited"])
                    : DateTime.now(),
          );
          _workspaceList[newWorkspace.id] = newWorkspace;
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

  void updateWorkspaceName(String workspaceId, String newName) {
    if (_workspaceList.containsKey(workspaceId)) {
      _workspaceList[workspaceId] = _workspaceList[workspaceId]!.copyWith(
        name: newName,
      );
      notifyListeners();
    }
  }

  Future<void> createNewProject(BuildContext context) async {
    _isLoading = true;
    try {
      var res = supabase?.auth.currentUser;
      if (res == null) {
        _isLoading = false;
        print("User not found");
        notifyListeners();
        return;
      }
      Map<String, dynamic> newWorkspaceData = {
        "id": Uuid().v4(),
        "owner": res.id,
        "name": "New Project",
        "editorId": [],
        "viewerId": [],
      };

      await supabase!.from('workspace').insert(newWorkspaceData);

      await refreshDashboard();
    } catch (e) {
      print("Error creating new project: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void importExistingProject(BuildContext context) {}

  Future<void> syncWithDb() async {
    if (supabase == null) {
      print("Supabase client is not initialized. Cannot sync with DB.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> workspacesToSync = [];
      _workspaceList.forEach((id, workspaceModel) {
        workspacesToSync.add(workspaceModel.toJson());
      });

      if (workspacesToSync.isNotEmpty) {
        await supabase!.from('workspace').upsert(workspacesToSync);
        print("All workspaces synced successfully with the database.");
      } else {
        print("No workspaces to sync.");
      }
    } catch (e) {
      print("Error syncing workspaces to database: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      await refreshDashboard();
    }
  }

  // UPDATED deleteWorkspace function
  Future<void> deleteWorkspace(String id) async {
    if (supabase == null) {
      print("Supabase client is not initialized. Cannot delete workspace.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Delete all canvas_objects linked to this workspace
      print('Deleting canvas_objects for workspace: $id');
      await supabase!
          .from('canvas_objects')
          .delete()
          .eq('workspace_id', id);
      print('Canvas objects for workspace $id deleted from database.');


      // 3. Delete the workspace from the database
      print('Deleting workspace: $id');
      await supabase!
          .from('workspace')
          .delete()
          .eq('id', id);
      print('Workspace $id deleted from database.');

      // 4. Then remove it from the local list
      _workspaceList.remove(id);
      
      print("Workspace $id removed from local list.");
    } catch (e) {
      print("Error deleting workspace $id: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      await refreshDashboard(); // Refresh local list after sync to pick up DB changes
    }
  }
}