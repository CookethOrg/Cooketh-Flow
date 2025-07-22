import 'dart:ui';

import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/utils/consts.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/circle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/cylinder_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/diamond_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/inverted_triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/parallelogram_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rectangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rounded_square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/user_cursor.dart';
import 'package:cookethflow/features/models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class WorkspaceProvider extends StateHandler {
  late SupabaseService _supabaseService;
  late DashboardProvider _dashboardProvider;
  
  // Initialize _currentWorkspace as null, it will be set by setWorkspace
  WorkspaceModel? _currentWorkspace; 

  WorkspaceProvider(this._supabaseService, this._dashboardProvider) : super() {
    _myId = _supabaseService.supabase.auth.currentUser?.id ?? const Uuid().v4();
    // No initial fetch here, it will be triggered when a workspace is set.

    // Listen for workspace name changes to sync with DB
    _workspaceNameController.addListener(_onWorkspaceNameChanged);
  }

  bool _isLoading = false;
  bool _isDrawerOpen = false;
  int? _selectedTileIndex;
  final Map<String, UserCursor> _userCursors = {};
  final Map<String, CanvasObject> _canvasObjects = {};
  RealtimeChannel? _canvasChannel; // Make it nullable as it's initialized later
  late String _myId;
  DrawMode _currentMode = DrawMode.pointer;
  String? _currentlySelectedObjectId;
  InteractionMode _interactionMode = InteractionMode.none;
  Offset? _panStartPoint;
  Offset _cursorPosition = const Offset(0, 0);
  static const double _defaultShapeSize = 100.0;
  static const double _handleRadius = 8.0;
  Color _currentWorkspaceColor = scaffoldColor;
  
  TextEditingController _workspaceNameController = TextEditingController(
    text: 'Workspace Name',
  );

  bool get isLoading => _isLoading;
  bool get isDrawerOpen => _isDrawerOpen;
  int? get selectedTileIndex => _selectedTileIndex;
  Map<String, UserCursor> get userCursors => _userCursors;
  Map<String, CanvasObject> get canvasObjects => _canvasObjects;
  List<CanvasObject> get canvasObjectsList => _canvasObjects.values.toList();
  String get myId => _myId;
  DrawMode get currentMode => _currentMode;
  String? get currentlySelectedObjectId => _currentlySelectedObjectId;
  InteractionMode get interactionMode => _interactionMode;
  Offset? get panStartPoint => _panStartPoint;
  Offset get cursorPosition => _cursorPosition;
  double get defaultShapeSize => _defaultShapeSize;
  double get handleRadius => _handleRadius;
  Color get currentWorkspaceColor => _currentWorkspaceColor;
  WorkspaceModel? get currentWorkspace => _currentWorkspace;
  TextEditingController get workspaceNameController => _workspaceNameController;
  SupabaseService get supabaseService => _supabaseService;

  bool get hasSelectedTile => _selectedTileIndex != null;

  // --- Core Methods ---

  // Sets the current workspace and loads its data
  void setWorkspace(String id) async {
    // Unsubscribe from previous channel if exists
    await _canvasChannel?.unsubscribe();
    _canvasChannel = null;

    _currentWorkspace = _dashboardProvider.workspaceList[id];
    if (_currentWorkspace == null) {
      print("Error: Workspace with ID $id not found in DashboardProvider.");
      // Handle case where workspace isn't found (e.g., navigate back, show error)
      return;
    }
    
    _workspaceNameController.text = _currentWorkspace!.name;
    _canvasObjects.clear(); // Clear existing objects when changing workspace
    _userCursors.clear(); // Clear cursors too
    _currentlySelectedObjectId = null; // Clear selected object

    await _fetchCanvasObjects(); // Fetch objects for the new workspace
    _setupRealtimeChannel(_currentWorkspace!.id); // Set up realtime for new workspace
    
    notifyListeners();
  }

  Future<void> _fetchCanvasObjects() async {
    if (_currentWorkspace == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final initialData = await _supabaseService.supabase
          .from('canvas_objects')
          .select('*')
          .eq('workspace_id', _currentWorkspace!.id)
          .order('created_at', ascending: true);

      for (final canvasObjectData in initialData) {
        final canvasObject = CanvasObject.fromJson(canvasObjectData['object']);
        _canvasObjects[canvasObject.id] = canvasObject;
      }
    } catch (e) {
      print("Error fetching canvas objects: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealtimeChannel(String workspaceId) {
    // Only subscribe if not already subscribed to this workspace
    if (_canvasChannel?.topic != Constants.channelName + ':$workspaceId') {
      _canvasChannel = _supabaseService.supabase
          .channel(Constants.channelName + ':$workspaceId') // Unique channel per workspace
          .onBroadcast(
            event: Constants.broadcastEventName,
            callback: (payload) {
              // Only process broadcasts if they belong to the current workspace
              if (payload['workspace_id'] == _currentWorkspace?.id) {
                final cursor = UserCursor.fromJson(payload['cursor']);
                _userCursors[cursor.id] = cursor;

                if (payload['object'] != null) {
                  final object = CanvasObject.fromJson(payload['object']);
                  _canvasObjects[object.id] = object;
                }
                notifyListeners();
              }
            },
          )
          .subscribe();
    }
  }

  // --- Realtime Sync ---
  Future<void> syncCanvasObject(Offset cursorPosition) {
    final myCursor = UserCursor(position: cursorPosition, id: _myId);
    if (_currentWorkspace == null || _canvasChannel == null) return Future.value();

    return _canvasChannel!.sendBroadcastMessage(
      event: Constants.broadcastEventName,
      payload: {
        'cursor': myCursor.toJson(),
        if (_currentlySelectedObjectId != null)
          'object': _canvasObjects[_currentlySelectedObjectId]?.toJson(),
        'workspace_id': _currentWorkspace!.id, // Include workspace_id in broadcast
      },
    );
  }

  // --- Database Persistence ---
  void _onWorkspaceNameChanged() {
    // Debounce this if it causes too many updates on every key stroke
    // For simplicity, we'll directly update on change for now.
    // A better approach for frequent changes is to use a debounce timer.
    if (_currentWorkspace != null && _currentWorkspace!.name != _workspaceNameController.text) {
      _currentWorkspace = _currentWorkspace!.copyWith(name: _workspaceNameController.text);
      _updateWorkspaceNameInDb(_workspaceNameController.text);
    }
  }

  Future<void> _updateWorkspaceNameInDb(String newName) async {
    if (_currentWorkspace == null) return;
    try {
      await _supabaseService.supabase
          .from('workspace')
          .update({'name': newName})
          .eq('id', _currentWorkspace!.id);
      // Also update in DashboardProvider's list
      _dashboardProvider.updateWorkspaceName(_currentWorkspace!.id, newName);
      print("Workspace name updated in DB: $newName");
    } catch (e) {
      print("Error updating workspace name: $e");
    }
  }

  void onPanEnd(DragEndDetails details) async {
    if (_currentlySelectedObjectId != null) {
      syncCanvasObject(_cursorPosition);
    }

    final drawnObjectId = _currentlySelectedObjectId;

    _panStartPoint = null;
    _interactionMode = InteractionMode.none;
    notifyListeners();

    if (drawnObjectId == null || _currentWorkspace == null) {
      return;
    }
    await _supabaseService.supabase.from('canvas_objects').upsert({
      'id': drawnObjectId,
      'object': _canvasObjects[drawnObjectId]!.toJson(),
      'workspace_id': _currentWorkspace!.id,
    });
  }

  // --- UI/Interaction Logic ---
  void selectTile(int index) {
    if (_selectedTileIndex == index) {
      _selectedTileIndex = null;
    } else {
      _selectedTileIndex = index;
    }
    notifyListeners();
  }

  void setLoadingState() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  void changeCurrentlySelectedObj(String id) {
    _currentlySelectedObjectId = id;
    notifyListeners();
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void changeWorkspaceColor(Color newColor) {
    _currentWorkspaceColor = newColor;
    notifyListeners();
  }

  void changeWorkspaceName(String newName) {
    // This method is now primarily handled by the TextField listener,
    // but can be kept for direct programmatic changes if needed.
    _workspaceNameController.text = newName;
    notifyListeners();
  }

  IconData getIconForObjectType(String objectType) {
    switch (objectType) {
      case Circle.type:
        return Icons.circle_outlined;
      case Rectangle.type:
        return Icons.rectangle_outlined;
      case Square.type:
        return Icons.square_outlined;
      case Diamond.type:
        return Icons.diamond_outlined;
      case RoundedSquare.type:
        return Icons.rounded_corner;
      case Parallelogram.type:
        return Icons.square_foot_outlined;
      case Cylinder.type:
        return Icons.view_in_ar_outlined;
      case Triangle.type:
        return Icons.change_history;
      case InvertedTriangle.type:
        return Icons.warning_amber_rounded;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void changeDrawMode(DrawMode mode) {
    _currentMode = mode;
    _currentlySelectedObjectId = null;
    notifyListeners();
  }

  void addNewNode(DragDownDetails details) {
    if (_currentWorkspace == null) {
      print("Cannot add node: No workspace selected.");
      return;
    }
    CanvasObject? newObject;
    final defaultTopLeft = details.globalPosition - const Offset(_defaultShapeSize / 2, _defaultShapeSize / 2);
    final defaultBottomRight = details.globalPosition + const Offset(_defaultShapeSize / 2, _defaultShapeSize / 2);

    switch (_currentMode) {
      case DrawMode.circle:
        newObject = Circle.createNew(details.globalPosition, _defaultShapeSize / 2);
        break;
      case DrawMode.rectangle:
        newObject = Rectangle.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.square:
        newObject = Square.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.diamond:
        newObject = Diamond.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.roundedSquare:
        newObject = RoundedSquare.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.parallelogram:
        newObject = Parallelogram.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.cylinder:
        newObject = Cylinder.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.triangle:
        newObject = Triangle.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.invertedTriangle:
        newObject = InvertedTriangle.createNew(defaultTopLeft, defaultBottomRight);
        break;
      case DrawMode.pointer:
        break;
    }

    if (newObject != null) {
      _canvasObjects[newObject.id] = newObject;
      _currentlySelectedObjectId = newObject.id;
      _interactionMode = InteractionMode.moving;
      notifyListeners();
    }
  }

  void onPanDown(DragDownDetails details) {
    _cursorPosition = details.globalPosition;
    _panStartPoint = details.globalPosition;

    _currentlySelectedObjectId = null;
    _interactionMode = InteractionMode.none;
    notifyListeners();

    if (_currentMode == DrawMode.pointer) {
      if (_currentlySelectedObjectId != null) {
        final selectedObject = _canvasObjects[_currentlySelectedObjectId!]!;
        final rect = selectedObject.getBounds();

        if ((details.globalPosition - rect.topLeft).distance < _handleRadius) {
          _interactionMode = InteractionMode.resizingTopLeft;
        } else if ((details.globalPosition - rect.topRight).distance < _handleRadius) {
          _interactionMode = InteractionMode.resizingTopRight;
        } else if ((details.globalPosition - rect.bottomLeft).distance < _handleRadius) {
          _interactionMode = InteractionMode.resizingBottomLeft;
        } else if ((details.globalPosition - rect.bottomRight).distance < _handleRadius) {
          _interactionMode = InteractionMode.resizingBottomRight;
        }
      }

      if (_interactionMode == InteractionMode.none) {
        for (final canvasObject in _canvasObjects.values.toList().reversed) {
          if (canvasObject.intersectsWith(details.globalPosition)) {
            _currentlySelectedObjectId = canvasObject.id;
            _interactionMode = InteractionMode.moving;
            notifyListeners();
            break;
          }
        }
      }
    } else {
      addNewNode(details);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    _cursorPosition = details.globalPosition;
    if (_currentlySelectedObjectId == null) return;

    final currentObject = _canvasObjects[_currentlySelectedObjectId!];
    if (currentObject == null) return;

    switch (_interactionMode) {
      case InteractionMode.moving:
        _canvasObjects[_currentlySelectedObjectId!] = currentObject.move(details.delta);
        break;
      case InteractionMode.resizingTopLeft:
        final newTopLeft = currentObject.getBounds().topLeft + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic).resize(newTopLeft, currentObject.getBounds().bottomRight);
        break;
      case InteractionMode.resizingTopRight:
        final newTopRight = currentObject.getBounds().topRight + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic).resize(Offset(currentObject.getBounds().topLeft.dx, newTopRight.dy), Offset(newTopRight.dx, currentObject.getBounds().bottomRight.dy));
        break;
      case InteractionMode.resizingBottomLeft:
        final newBottomLeft = currentObject.getBounds().bottomLeft + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic).resize(Offset(newBottomLeft.dx, currentObject.getBounds().topLeft.dy), Offset(currentObject.getBounds().bottomRight.dx, newBottomLeft.dy));
        break;
      case InteractionMode.resizingBottomRight:
        final newBottomRight = currentObject.getBounds().bottomRight + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic).resize(currentObject.getBounds().topLeft, newBottomRight);
        break;
      case InteractionMode.none:
        break;
    }

    notifyListeners();
    syncCanvasObject(_cursorPosition);
  }

  void exitWorkspace() {
    _canvasChannel?.unsubscribe(); // Unsubscribe when exiting
    _canvasChannel = null;
    _currentWorkspace = null;
    _canvasObjects.clear();
    _userCursors.clear();
    _currentlySelectedObjectId = null;
    _workspaceNameController.text = 'Workspace Name'; // Reset controller
    notifyListeners();
  }

  @override
  void dispose() {
    _workspaceNameController.removeListener(_onWorkspaceNameChanged);
    _workspaceNameController.dispose();
    _canvasChannel?.unsubscribe();
    super.dispose();
  }
}