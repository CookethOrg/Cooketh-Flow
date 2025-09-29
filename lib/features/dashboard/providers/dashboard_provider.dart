import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cookethflow/core/helpers/file_helper.dart';

class DashboardProvider extends StateHandler {
  late SupabaseClient? supabase;
  late SupabaseService supabaseService;
  final FileServices _fileServices = FileServices();

  DashboardProvider(this.supabase, this.supabaseService) : super() {
    initialize();
  }

  // properties
  bool _isDrawerOpen = true;
  int _tabIndex = 0;
  bool _isLoading = false;
  bool _isInitialized = false;
  final Map<String, WorkspaceModel> _workspaceList = {};

  // getters
  bool get isDrawerOpen => _isDrawerOpen;
  int get tabIndex => _tabIndex;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Map<String, WorkspaceModel> get workspaceList => _workspaceList;

  List<WorkspaceModel> get displayedWorkspaces {
    final allWorkspaces = _workspaceList.values.toList();
    allWorkspaces.sort(
      (a, b) =>
          (b.lastEdited ?? DateTime(0)).compareTo(a.lastEdited ?? DateTime(0)),
    );

    switch (_tabIndex) {
      case 1: // Starred
        return allWorkspaces.where((ws) => ws.isStarred).toList();
      case 2: // Trash
      case 3: // About Us
        // Return an empty list for non-project tabs
        return [];
      case 0: // All
      default:
        return allWorkspaces;
    }
  }

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
        List<dynamic> dbWorkspace = await supabase!
            .from('workspace')
            .select()
            .eq('owner', res.id);
        _workspaceList.clear();
        for (var workspaceData in dbWorkspace) {
          WorkspaceModel newWorkspace = WorkspaceModel.fromJson(workspaceData);
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

  void updateWorkspace(WorkspaceModel workspace) {
    if (_workspaceList.containsKey(workspace.id)) {
      _workspaceList[workspace.id] = workspace;
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

  Future<void> toggleStar(String workspaceId) async {
    final workspace = _workspaceList[workspaceId];
    if (workspace == null) return;

    final updatedWorkspace = workspace.copyWith(
      isStarred: !workspace.isStarred,
    );
    _workspaceList[workspaceId] = updatedWorkspace;
    notifyListeners();

    try {
      final dataToSave = updatedWorkspace.toJson()['data'];
      await supabase!
          .from('workspace')
          .update({'data': dataToSave})
          .eq('id', workspaceId);
      print("Workspace $workspaceId star status updated in DB.");
    } catch (e) {
      print("Error updating star status for $workspaceId: $e");
      _workspaceList[workspaceId] = workspace;
      notifyListeners();
    }
  }

  Future<String> createNewProject() async {
    _isLoading = true;
    try {
      var res = supabase?.auth.currentUser;
      if (res == null) {
        _isLoading = false;
        print("User not found");
        notifyListeners();
        return 'User not found';
      }
      Map<String, dynamic> newWorkspaceData = {
        "id": Uuid().v4(),
        "owner": res.id,
        "name": "New Project",
        "editorId": [],
        "viewerId": [],
        "data": {'isStarred': false},
      };

      await supabase!.from('workspace').insert(newWorkspaceData);

      await refreshDashboard();
      return 'Workspace created successfully!!';
    } catch (e) {
      print("Error creating new project: $e");
      String output = e.toString();
      if (e.toString() ==
          'PostgrestException(message: User has reached the maximum limit of 10 workspaces., code: P0001, details: , hint: null)') {
        output = 'Maximum limit of workspaces reached. Upgrade your plan for more!';
      }
      return output;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> importExistingProject() async {
    _isLoading = true;
    notifyListeners();
    try {
      final jsonContent = await _fileServices.importJsonFileFromUser();
      if (jsonContent == null) {
        return 'Import operation cancelled or failed.';
      }

      if (jsonContent['workspace'] == null || jsonContent['canvasObjects'] == null) {
        return 'Invalid file format. Missing "workspace" or "canvasObjects" data.';
      }

      final currentUser = supabase?.auth.currentUser;
      if (currentUser == null) {
        return 'User not authenticated.';
      }

      final oldWorkspaceId = jsonContent['workspace']['id'];
      final newWorkspaceId = Uuid().v4();

      final newWorkspace = Map<String, dynamic>.from(jsonContent['workspace']);
      newWorkspace['id'] = newWorkspaceId;
      newWorkspace['owner'] = currentUser.id;
      newWorkspace['name'] = '${newWorkspace['name']} (Imported)';
      newWorkspace.remove('created_at');
      newWorkspace.remove('lastEdited');

      final oldToNewIdMap = <String, String>{};
      final newCanvasObjects = <Map<String, dynamic>>[];

      for (var obj in (jsonContent['canvasObjects'] as List)) {
        final newId = Uuid().v4();
        final oldId = obj['id'];
        oldToNewIdMap[oldId] = newId;

        final newObj = Map<String, dynamic>.from(obj);
        newObj['id'] = newId;
        newCanvasObjects.add(newObj);
      }

      for (var obj in newCanvasObjects) {
        if (obj['object_type'] == 'connector') {
          final sourceId = obj['source_id'];
          final targetId = obj['target_id'];
          if (sourceId != null && oldToNewIdMap.containsKey(sourceId)) {
            obj['source_id'] = oldToNewIdMap[sourceId];
          }
          if (targetId != null && oldToNewIdMap.containsKey(targetId)) {
            obj['target_id'] = oldToNewIdMap[targetId];
          }
        }
      }

      await supabase!.from('workspace').insert(newWorkspace);

      if (newCanvasObjects.isNotEmpty) {
        final objectsToInsert = newCanvasObjects.map((obj) {
          return {
            'id': obj['id'],
            'object': obj,
            'workspace_id': newWorkspaceId,
          };
        }).toList();
        await supabase!.from('canvas_objects').insert(objectsToInsert);
      }

      await refreshDashboard();
      return 'Workspace imported successfully!';
    } catch (e) {
      print("Error importing project: $e");
      String output = 'An error occurred during import.';
      if (e.toString().contains('maximum limit of 10 workspaces')) {
        output = 'Maximum limit of workspaces reached. Upgrade your plan for more!';
      }
      return output;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> deleteWorkspace(String id) async {
    if (supabase == null) {
      print("Supabase client is not initialized. Cannot delete workspace.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('Deleting canvas_objects for workspace: $id');
      await supabase!.from('canvas_objects').delete().eq('workspace_id', id);
      print('Canvas objects for workspace $id deleted from database.');

      print('Deleting workspace: $id');
      await supabase!.from('workspace').delete().eq('id', id);
      print('Workspace $id deleted from database.');

      _workspaceList.remove(id);

      print("Workspace $id removed from local list.");
    } catch (e) {
      print("Error deleting workspace $id: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      await refreshDashboard();
    }
  }
}