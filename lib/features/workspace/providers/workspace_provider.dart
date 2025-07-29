// lib/features/workspace/providers/workspace_provider.dart

import 'dart:ui';
import 'dart:convert'; // For jsonDecode/jsonEncode

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
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart'; // NEW: Import TextBoxObject
import 'package:cookethflow/features/models/canvas_models/objects/triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/user_cursor.dart';
import 'package:cookethflow/features/models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class WorkspaceProvider extends StateHandler {
  late SupabaseService _supabaseService;
  late DashboardProvider _dashboardProvider;

  // Initialize _currentWorkspace as null, it will be set by setWorkspace
  WorkspaceModel? _currentWorkspace;

  // NEW: Temporary QuillController for editing selected object's text
  late QuillController _tempQuillController;


  WorkspaceProvider(this._supabaseService, this._dashboardProvider) : super() {
    _myId = _supabaseService.supabase.auth.currentUser?.id ?? const Uuid().v4();
    // No initial fetch here, it will be triggered when a workspace is set.

    // Listen for workspace name changes to sync with DB
    _workspaceNameController.addListener(_onWorkspaceNameChanged);

    // Initialize the temporary QuillController
    _tempQuillController = QuillController.basic();
    _tempQuillController.addListener(_onQuillContentChanged); // NEW: Listen for changes
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
  Offset _cursorPosition = const Offset(0, 0); // Now stores canvas coordinates
  static const double _defaultShapeSize = 100.0; // In canvas units
  static const double _defaultTextBoxWidth = 200.0; // Default width for a new text box
  static const double _defaultTextBoxHeight = 50.0; // Default height for a new text box
  static const double _handleRadius = 8.0; // In canvas units
  Color _currentWorkspaceColor = scaffoldColor;
  TextEditingController _workspaceNameController = TextEditingController(
    text: 'Workspace Name',
  );
  // QuillController _quillController = QuillController.basic(); // REMOVED: No longer a direct field

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
  // QuillController get quillController => _quillController; // REMOVED: Replaced by selectedObjectQuillController

  // NEW: Getter for the QuillController related to the currently selected object
  QuillController get selectedObjectQuillController {
    // If no object is selected or it's a new object being created,
    // the _tempQuillController will reflect that.
    return _tempQuillController;
  }

  // NEW: Listener for changes in the temporary QuillController
  void _onQuillContentChanged() {
    if (_currentlySelectedObjectId != null &&
        _interactionMode == InteractionMode.editingText) {
      final currentObject = _canvasObjects[_currentlySelectedObjectId!];
      if (currentObject != null) {
        final newTextDelta = jsonEncode(_tempQuillController.document.toDelta().toJson());
        // Only update if the text content has actually changed to avoid unnecessary re-renders/saves
        if (currentObject.textDelta != newTextDelta) {
          _canvasObjects[_currentlySelectedObjectId!] = currentObject.copyWith(textDelta: newTextDelta);
          // Debounce this save if performance becomes an issue
          // For now, let's directly sync the object with the new text.
          syncCanvasObject(_cursorPosition); // Sync to other users
          _saveCanvasObjectToDb(_currentlySelectedObjectId!); // Persist to DB
        }
      }
    }
  }

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
    _tempQuillController.clear(); // NEW: Clear quill controller content

    await _fetchCanvasObjects(); // Fetch objects for the new workspace
    _setupRealtimeChannel(
      _currentWorkspace!.id,
    ); // Set up realtime for new workspace

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
        // Ensure that `canvasObjectData['object']` is directly the JSONB content
        // and not wrapped in another object if not intended.
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
      _canvasChannel =
          _supabaseService.supabase
              .channel(
                Constants.channelName + ':$workspaceId',
              ) // Unique channel per workspace
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
                      // NEW: If the object being updated is the currently selected one,
                      // update the QuillController content.
                      if (object.id == _currentlySelectedObjectId && object.textDelta != null) {
                        try {
                          final doc = Document.fromJson(jsonDecode(object.textDelta!));
                          if (!isEqual(_tempQuillController.document.toDelta().toJson(), doc.toDelta().toJson())) {
                             _tempQuillController.document = doc;
                          }
                        } catch (e) {
                          print("Error loading textDelta into QuillController: $e");
                        }
                      }
                    }
                    notifyListeners();
                  }
                },
              )
              .subscribe();
    }
  }

  // --- Realtime Sync ---
  // Now expects canvas coordinates for cursorPosition
  Future<void> syncCanvasObject(Offset cursorPosition) {
    final myCursor = UserCursor(position: cursorPosition, id: _myId);
    if (_currentWorkspace == null || _canvasChannel == null)
      return Future.value();

    // NEW: Always include the currently selected object's full state if available
    final Map<String, dynamic> payload = {
      'cursor': myCursor.toJson(),
      'workspace_id': _currentWorkspace!.id,
    };

    if (_currentlySelectedObjectId != null &&
        _canvasObjects.containsKey(_currentlySelectedObjectId!)) {
      payload['object'] = _canvasObjects[_currentlySelectedObjectId!]!.toJson();
    }

    return _canvasChannel!.sendBroadcastMessage(
      event: Constants.broadcastEventName,
      payload: payload,
    );
  }

  // --- Database Persistence ---
  void _onWorkspaceNameChanged() {
    // Debounce this if it causes too many updates on every key stroke
    // For simplicity, we'll directly update on change for now.
    // A better approach for frequent changes is to use a debounce timer.
    if (_currentWorkspace != null &&
        _currentWorkspace!.name != _workspaceNameController.text) {
      _currentWorkspace = _currentWorkspace!.copyWith(
        name: _workspaceNameController.text,
      );
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

  // NEW: Helper method to upsert a canvas object to the database
  Future<void> _saveCanvasObjectToDb(String objectId) async {
    if (_currentWorkspace == null) return;
    final objectToSave = _canvasObjects[objectId];
    if (objectToSave == null) {
      print("Error: Attempted to save non-existent object: $objectId");
      return;
    }
    try {
      await _supabaseService.supabase.from('canvas_objects').upsert({
        'id': objectToSave.id,
        'object': objectToSave.toJson(),
        'workspace_id': _currentWorkspace!.id,
      });
      print('Canvas object ${objectToSave.id} upserted to DB.');
    } catch (e) {
      print('Error upserting canvas object ${objectToSave.id}: $e');
    }
  }

  // Modified onPanEnd to ensure object is saved when interaction stops
  void onPanEnd(DragEndDetails details) async {
    if (_currentlySelectedObjectId != null &&
        _interactionMode != InteractionMode.editingText) { // NEW: Don't save on pan end if in text editing mode
      syncCanvasObject(_cursorPosition); // Sync final position
      _saveCanvasObjectToDb(_currentlySelectedObjectId!); // Persist to DB
    }

    _panStartPoint = null;
    if (_interactionMode != InteractionMode.editingText) { // NEW: Only reset mode if not editing text
      _interactionMode = InteractionMode.none;
    }
    notifyListeners();
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

  // NEW: Sets the currently selected object and loads its text into the Quill controller
  void changeCurrentlySelectedObj(String? id) {
    if (_currentlySelectedObjectId == id && _interactionMode == InteractionMode.editingText) {
      // If the same text object is clicked again while editing, allow continued editing.
      return;
    }

    // If a different object is selected, or we're exiting text editing of the current one
    if (_currentlySelectedObjectId != null && _interactionMode == InteractionMode.editingText) {
      // If we were editing text, save the changes before switching.
      _saveCanvasObjectToDb(_currentlySelectedObjectId!);
    }

    _currentlySelectedObjectId = id;
    _tempQuillController.clear(); // Clear previous content

    if (id != null) {
      final selectedObject = _canvasObjects[id];
      if (selectedObject != null && selectedObject.textDelta != null) {
        try {
          _tempQuillController.document = Document.fromJson(jsonDecode(selectedObject.textDelta!));
        } catch (e) {
          print("Error setting QuillController document from textDelta: $e");
          _tempQuillController.document = Document()..insert(0, selectedObject.textDelta!); // Fallback to plain text
        }
      }
      // NEW: Automatically switch to editingText mode if a TextBoxObject is selected
      if (selectedObject is TextBoxObject) {
        _interactionMode = InteractionMode.editingText;
      } else {
        _interactionMode = InteractionMode.none; // Reset mode for other objects
      }
    } else {
      _interactionMode = InteractionMode.none; // No object selected, no interaction mode
    }

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
      case TextBoxObject.type: // NEW: Icon for TextBoxObject
        return Icons.text_fields;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void changeDrawMode(DrawMode mode) {
    // NEW: If changing mode from text editing, save text first
    if (_interactionMode == InteractionMode.editingText && _currentlySelectedObjectId != null) {
      _saveCanvasObjectToDb(_currentlySelectedObjectId!);
    }
    _currentMode = mode;
    _currentlySelectedObjectId = null; // Unselect object when changing draw mode
    _interactionMode = InteractionMode.none; // Reset interaction mode
    notifyListeners();
  }

  // Expects details.globalPosition to be in canvas coordinates
  void addNewNode(DragDownDetails details) async {
    // Make async to save immediately
    if (_currentWorkspace == null) {
      print("Cannot add node: No workspace selected.");
      return;
    }
    CanvasObject? newObject;
    final defaultTopLeft =
        details.globalPosition -
        const Offset(_defaultShapeSize / 2, _defaultShapeSize / 2);
    final defaultBottomRight =
        details.globalPosition +
        const Offset(_defaultShapeSize / 2, _defaultShapeSize / 2);

    switch (_currentMode) {
      case DrawMode.circle:
        newObject = Circle.createNew(
          details.globalPosition,
          _defaultShapeSize / 2,
        );
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
        newObject = InvertedTriangle.createNew(
          defaultTopLeft,
          defaultBottomRight,
        );
        break;
      case DrawMode.textBox: // NEW: Handle TextBox creation
        final textBoxTopLeft = details.globalPosition;
        final textBoxBottomRight = Offset(
          details.globalPosition.dx + _defaultTextBoxWidth,
          details.globalPosition.dy + _defaultTextBoxHeight,
        );
        newObject = TextBoxObject.createNew(textBoxTopLeft, textBoxBottomRight);
        // NEW: Automatically set some default text for new text boxes
        _tempQuillController.document = Document()..insert(0, 'Double-click to edit text');
        newObject = (newObject as TextBoxObject).copyWith(textDelta: jsonEncode(_tempQuillController.document.toDelta().toJson()));
        break;
      case DrawMode.pointer:
        break;
    }

    if (newObject != null) {
      _canvasObjects[newObject.id] = newObject;
      changeCurrentlySelectedObj(newObject.id); // Use the new method to set selection and load text
      // NEW: If a new text box, set interaction mode to editing immediately
      if (newObject is TextBoxObject) {
        _interactionMode = InteractionMode.editingText;
      } else {
        _interactionMode = InteractionMode.moving; // For other shapes, set to moving
      }

      notifyListeners();

      // Immediately save the newly created object to the database
      await _saveCanvasObjectToDb(newObject.id);
    }
  }

  // Expects details.globalPosition and details.delta to be in canvas coordinates
  void onPanDown(DragDownDetails details) {
    _cursorPosition =
        details.globalPosition; // This is now in canvas coordinates
    _panStartPoint =
        details.globalPosition; // This is now in canvas coordinates

    // NEW: If in text editing mode, check if click is outside the current object
    if (_interactionMode == InteractionMode.editingText) {
      final selectedObject = _canvasObjects[_currentlySelectedObjectId!];
      if (selectedObject != null && !selectedObject.getBounds().contains(details.globalPosition)) {
        // Clicked outside, save changes and exit editing mode
        _saveCanvasObjectToDb(_currentlySelectedObjectId!);
        _currentlySelectedObjectId = null;
        _interactionMode = InteractionMode.none;
        _tempQuillController.clear();
        notifyListeners();
        return; // Don't process further pan down if exiting text editing
      } else if (selectedObject != null && selectedObject.getBounds().contains(details.globalPosition)) {
        // If clicked inside the text box while in editing mode, stay in editing mode.
        // This allows text selection/cursor movement within the text box.
        // We do not want to trigger object move/resize here.
        return;
      }
    }


    _currentlySelectedObjectId = null;
    _interactionMode = InteractionMode.none;
    notifyListeners();

    if (_currentMode == DrawMode.pointer) {
      // Prioritize handle interaction check
      for (final canvasObject in _canvasObjects.values.toList().reversed) {
        final rect = canvasObject.getBounds();

        // Check for handle interaction. Handle radius also in canvas units.
        if ((details.globalPosition - rect.topLeft).distance < _handleRadius) {
          changeCurrentlySelectedObj(canvasObject.id); // NEW: Use the new selection method
          _interactionMode = InteractionMode.resizingTopLeft;
          notifyListeners();
          return; // Exit after finding a handle
        } else if ((details.globalPosition - rect.topRight).distance <
            _handleRadius) {
          changeCurrentlySelectedObj(canvasObject.id); // NEW: Use the new selection method
          _interactionMode = InteractionMode.resizingTopRight;
          notifyListeners();
          return;
        } else if ((details.globalPosition - rect.bottomLeft).distance <
            _handleRadius) {
          changeCurrentlySelectedObj(canvasObject.id); // NEW: Use the new selection method
          _interactionMode = InteractionMode.resizingBottomLeft;
          notifyListeners();
          return;
        } else if ((details.globalPosition - rect.bottomRight).distance <
            _handleRadius) {
          changeCurrentlySelectedObj(canvasObject.id); // NEW: Use the new selection method
          _interactionMode = InteractionMode.resizingBottomRight;
          notifyListeners();
          return;
        }
      }

      // If no handle interaction, check if we're clicking on an object to move it or edit its text
      for (final canvasObject in _canvasObjects.values.toList().reversed) {
        if (canvasObject.intersectsWith(details.globalPosition)) {
          changeCurrentlySelectedObj(canvasObject.id); // NEW: Use the new selection method
          // NEW: If it's a TextBoxObject, set interaction mode to editingText
          if (canvasObject is TextBoxObject) {
            _interactionMode = InteractionMode.editingText;
          } else {
            _interactionMode = InteractionMode.moving;
          }
          notifyListeners();
          break; // Exit after selecting an object
        }
      }
    } else {
      // If not in pointer mode, it means we are in a drawing mode (e.g., circle, rectangle, textBox)
      // This path is for creating new objects.
      addNewNode(details);
    }
  }

  // Expects details.globalPosition and details.delta to be in canvas coordinates
  void onPanUpdate(DragUpdateDetails details) {
    _cursorPosition =
        details.globalPosition; // This is now in canvas coordinates
    if (_currentlySelectedObjectId == null) return;

    // NEW: If in text editing mode, do not pan/resize
    if (_interactionMode == InteractionMode.editingText) {
      return;
    }

    final currentObject = _canvasObjects[_currentlySelectedObjectId!];
    if (currentObject == null) return;

    switch (_interactionMode) {
      case InteractionMode.moving:
        _canvasObjects[_currentlySelectedObjectId!] = currentObject.move(
          details.delta,
        ); // delta is already in canvas units
        break;
      case InteractionMode.resizingTopLeft:
        final newTopLeft = currentObject.getBounds().topLeft + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic)
            .resize(newTopLeft, currentObject.getBounds().bottomRight);
        break;
      case InteractionMode.resizingTopRight:
        final newTopRight = currentObject.getBounds().topRight + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic)
            .resize(
              Offset(currentObject.getBounds().topLeft.dx, newTopRight.dy),
              Offset(newTopRight.dx, currentObject.getBounds().bottomRight.dy),
            );
        break;
      case InteractionMode.resizingBottomLeft:
        final newBottomLeft =
            currentObject.getBounds().bottomLeft + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic)
            .resize(
              Offset(newBottomLeft.dx, currentObject.getBounds().topLeft.dy),
              Offset(
                currentObject.getBounds().bottomRight.dx,
                newBottomLeft.dy,
              ),
            );
        break;
      case InteractionMode.resizingBottomRight:
        final newBottomRight =
            currentObject.getBounds().bottomRight + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = (currentObject as dynamic)
            .resize(currentObject.getBounds().topLeft, newBottomRight);
        break;
      case InteractionMode.none:
      case InteractionMode.editingText: // Should be handled by the guard above
        break;
    }

    notifyListeners();
    syncCanvasObject(_cursorPosition);
  }

  void exitWorkspace() {
    // NEW: Save any unsaved text changes before exiting
    if (_currentlySelectedObjectId != null && _interactionMode == InteractionMode.editingText) {
      _saveCanvasObjectToDb(_currentlySelectedObjectId!);
    }

    _canvasChannel?.unsubscribe(); // Unsubscribe when exiting
    _canvasChannel = null;
    _currentWorkspace = null;
    _canvasObjects.clear();
    _userCursors.clear();
    _currentlySelectedObjectId = null;
    _workspaceNameController.text = 'Workspace Name'; // Reset controller
    _tempQuillController.clear(); // NEW: Clear quill controller
    _interactionMode = InteractionMode.none; // NEW: Reset interaction mode
    notifyListeners();
  }

  @override
  void dispose() {
    _workspaceNameController.removeListener(_onWorkspaceNameChanged);
    _workspaceNameController.dispose();
    _tempQuillController.removeListener(_onQuillContentChanged); // NEW: Remove listener
    _tempQuillController.dispose(); // NEW: Dispose temporary controller
    _canvasChannel?.unsubscribe();
    super.dispose();
  }

  // Helper for deep comparison of JSON for Quill documents
  bool isEqual(dynamic a, dynamic b) {
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !isEqual(a[key], b[key])) {
          return false;
        }
      }
      return true;
    } else if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!isEqual(a[i], b[i])) {
          return false;
        }
      }
      return true;
    } else {
      return a == b;
    }
  }
}