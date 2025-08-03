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
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
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

  WorkspaceModel? _currentWorkspace;

  late QuillController _tempQuillController;

  WorkspaceProvider(this._supabaseService, this._dashboardProvider) : super() {
    _myId = _supabaseService.supabase.auth.currentUser?.id ?? const Uuid().v4();

    _workspaceNameController.addListener(_onWorkspaceNameChanged);

    _tempQuillController = QuillController.basic();
    _tempQuillController.addListener(
      _onQuillContentChanged,
    );
  }

  bool _isLoading = false;
  bool _isDrawerOpen = false;
  int? _selectedTileIndex;
  final Map<String, UserCursor> _userCursors = {};
  final Map<String, CanvasObject> _canvasObjects = {};
  RealtimeChannel? _canvasChannel;
  late String _myId;
  DrawMode _currentMode = DrawMode.pointer;
  String? _currentlySelectedObjectId;
  InteractionMode _interactionMode = InteractionMode.none;
  Offset? _panStartPoint;
  Offset _cursorPosition = const Offset(0, 0);
  static const double _defaultShapeSize = 100.0;
  static const double _defaultTextBoxWidth = 200.0;
  static const double _defaultTextBoxHeight = 50.0;
  static const double _handleRadius = 8.0;
  Color _currentWorkspaceColor = scaffoldColor;
  final TextEditingController _workspaceNameController = TextEditingController(
    text: 'Workspace Name',
  );

  DateTime? _lastTapTime;
  String? _lastTappedObjectId;

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

  QuillController get selectedObjectQuillController {
    return _tempQuillController;
  }

  void _onQuillContentChanged() {
    if (_currentlySelectedObjectId != null &&
        _interactionMode == InteractionMode.editingText) {
      final currentObject = _canvasObjects[_currentlySelectedObjectId!];
      if (currentObject != null) {
        final newTextDelta = jsonEncode(
          _tempQuillController.document.toDelta().toJson(),
        );
        if (currentObject.textDelta != newTextDelta) {
          _canvasObjects[_currentlySelectedObjectId!] = currentObject.copyWith(
            textDelta: newTextDelta,
          );
          notifyListeners();
          syncCanvasObject(_cursorPosition);
          _saveCanvasObjectToDb(_currentlySelectedObjectId!);
        }
      }
    }
  }

  void setWorkspace(String id) async {
    await _canvasChannel?.unsubscribe();
    _canvasChannel = null;

    _currentWorkspace = _dashboardProvider.workspaceList[id];
    if (_currentWorkspace == null) {
      print("Error: Workspace with ID $id not found in DashboardProvider.");
      return;
    }

    _workspaceNameController.text = _currentWorkspace!.name;
    _canvasObjects.clear();
    _userCursors.clear();
    _currentlySelectedObjectId = null;
    _tempQuillController.clear();

    await _fetchCanvasObjects();
    _setupRealtimeChannel(
      _currentWorkspace!.id,
    );

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
    if (_canvasChannel?.topic != '${Constants.channelName}:$workspaceId') {
      _canvasChannel = _supabaseService.supabase
          .channel(
            '${Constants.channelName}:$workspaceId',
          )
          .onBroadcast(
            event: Constants.broadcastEventName,
            callback: (payload) {
              if (payload['workspace_id'] == _currentWorkspace?.id) {
                final cursor = UserCursor.fromJson(payload['cursor']);
                _userCursors[cursor.id] = cursor;

                if (payload['object'] != null) {
                  final object = CanvasObject.fromJson(payload['object']);
                  _canvasObjects[object.id] = object;
                  if (object.id == _currentlySelectedObjectId &&
                      object.textDelta != null) {
                    try {
                      final doc = Document.fromJson(
                        jsonDecode(object.textDelta!),
                      );
                      if (!isEqual(
                        _tempQuillController.document.toDelta().toJson(),
                        doc.toDelta().toJson(),
                      )) {
                        _tempQuillController.document = doc;
                      }
                    } catch (e) {
                      print(
                        "Error loading textDelta into QuillController: $e",
                      );
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

  Future<void> syncCanvasObject(Offset cursorPosition) {
    final myCursor = UserCursor(position: cursorPosition, id: _myId);
    if (_currentWorkspace == null || _canvasChannel == null) {
      return Future.value();
    }

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

  void _onWorkspaceNameChanged() {
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
      _dashboardProvider.updateWorkspaceName(_currentWorkspace!.id, newName);
      print("Workspace name updated in DB: $newName");
    } catch (e) {
      print("Error updating workspace name: $e");
    }
  }

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

  void onPanEnd(DragEndDetails details) async {
    if (_currentlySelectedObjectId != null &&
        _interactionMode != InteractionMode.editingText) {
      syncCanvasObject(_cursorPosition);
      _saveCanvasObjectToDb(_currentlySelectedObjectId!);
    }

    _panStartPoint = null;
    if (_interactionMode != InteractionMode.editingText) {
      _interactionMode = InteractionMode.none;
    }
    notifyListeners();
  }

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

  void changeCurrentlySelectedObj(String? id) {
    if (_currentlySelectedObjectId != null &&
        _interactionMode == InteractionMode.editingText) {
      _saveCanvasObjectToDb(_currentlySelectedObjectId!);
    }

    _currentlySelectedObjectId = id;

    if (id == null) {
      _tempQuillController.clear();
      _interactionMode = InteractionMode.none;
    } else {
      final selectedObject = _canvasObjects[id];
      if (selectedObject?.textDelta != null) {
        try {
          final doc = Document.fromJson(jsonDecode(selectedObject!.textDelta!));
          _tempQuillController.document = doc;
        } catch (e) {
          _tempQuillController.document = Document()
            ..insert(0, selectedObject!.textDelta!);
          print("Error parsing Delta, loaded as plain text: $e");
        }
      } else {
        _tempQuillController.clear();
      }
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
      case TextBoxObject.type:
        return Icons.text_fields;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void changeDrawMode(DrawMode mode) {
    if (_interactionMode == InteractionMode.editingText &&
        _currentlySelectedObjectId != null) {
      _saveCanvasObjectToDb(_currentlySelectedObjectId!);
    }
    _currentMode = mode;
    _currentlySelectedObjectId = null;
    _interactionMode = InteractionMode.none;
    notifyListeners();
  }

  void addNewNode(DragDownDetails details) async {
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
      case DrawMode.textBox:
        final textBoxTopLeft = details.globalPosition;
        final textBoxBottomRight = Offset(
          details.globalPosition.dx + _defaultTextBoxWidth,
          details.globalPosition.dy + _defaultTextBoxHeight,
        );
        newObject = TextBoxObject.createNew(textBoxTopLeft, textBoxBottomRight);
        final initialDoc = Document()..insert(0, 'Double-click to edit');
        newObject = (newObject).copyWith(
          textDelta: jsonEncode(
            initialDoc.toDelta().toJson(),
          ),
        );
        break;
      case DrawMode.pointer:
        break;
    }

    if (newObject != null) {
      _canvasObjects[newObject.id] = newObject;
      changeCurrentlySelectedObj(newObject.id);

      if (newObject is TextBoxObject) {
        _interactionMode = InteractionMode.editingText;
      } else {
        _interactionMode = InteractionMode.moving;
      }

      notifyListeners();
      await _saveCanvasObjectToDb(newObject.id);
    }
  }

  void onPanDown(DragDownDetails details) {
    _cursorPosition = details.globalPosition;
    _panStartPoint = details.globalPosition;

    if (_interactionMode == InteractionMode.editingText) {
      final selectedObject = _canvasObjects[_currentlySelectedObjectId!];
      if (selectedObject != null &&
          !selectedObject.getBounds().contains(details.globalPosition)) {
        changeCurrentlySelectedObj(null);
        notifyListeners();
      }
      return;
    }

    if (_currentMode == DrawMode.pointer) {
      // Check for resize handle interaction first
      if (_currentlySelectedObjectId != null) {
        final selectedObject = _canvasObjects[_currentlySelectedObjectId!];
        if (selectedObject != null) {
          final bounds = selectedObject.getBounds();
          if (Rect.fromCircle(center: bounds.topLeft, radius: _handleRadius)
              .contains(details.globalPosition)) {
            _interactionMode = InteractionMode.resizingTopLeft;
            notifyListeners();
            return;
          }
          if (Rect.fromCircle(center: bounds.topRight, radius: _handleRadius)
              .contains(details.globalPosition)) {
            _interactionMode = InteractionMode.resizingTopRight;
            notifyListeners();
            return;
          }
          if (Rect.fromCircle(
                  center: bounds.bottomLeft, radius: _handleRadius)
              .contains(details.globalPosition)) {
            _interactionMode = InteractionMode.resizingBottomLeft;
            notifyListeners();
            return;
          }
          if (Rect.fromCircle(
                  center: bounds.bottomRight, radius: _handleRadius)
              .contains(details.globalPosition)) {
            _interactionMode = InteractionMode.resizingBottomRight;
            notifyListeners();
            return;
          }
        }
      }

      CanvasObject? tappedObject;
      for (final canvasObject in _canvasObjects.values.toList().reversed) {
        if (canvasObject.intersectsWith(details.globalPosition)) {
          tappedObject = canvasObject;
          break;
        }
      }

      if (tappedObject != null) {
        if (tappedObject.id != _currentlySelectedObjectId) {
          changeCurrentlySelectedObj(tappedObject.id);
        }

        final now = DateTime.now();
        final isDoubleTap = _lastTappedObjectId == tappedObject.id &&
            _lastTapTime != null &&
            now.difference(_lastTapTime!) < const Duration(milliseconds: 300);

        _lastTapTime = now;
        _lastTappedObjectId = tappedObject.id;

        if (isDoubleTap) {
          _interactionMode = InteractionMode.editingText;
          _lastTappedObjectId = null;
        } else {
          _interactionMode = InteractionMode.moving;
        }
      } else {
        changeCurrentlySelectedObj(null);
      }
    } else {
      addNewNode(details);
    }
    notifyListeners();
  }

  void onPanUpdate(DragUpdateDetails details) {
    _cursorPosition = details.globalPosition;
    if (_currentlySelectedObjectId == null) return;

    if (_interactionMode == InteractionMode.editingText) {
      return;
    }

    final currentObject = _canvasObjects[_currentlySelectedObjectId!];
    if (currentObject == null) return;

    switch (_interactionMode) {
      case InteractionMode.moving:
        _canvasObjects[_currentlySelectedObjectId!] = currentObject.move(
          details.delta,
        );
        break;
      case InteractionMode.resizingTopLeft:
        final newTopLeft = currentObject.getBounds().topLeft + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] =
            currentObject.resize(newTopLeft, currentObject.getBounds().bottomRight);
        break;
      case InteractionMode.resizingTopRight:
        final newTopRight = currentObject.getBounds().topRight + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = currentObject.resize(
              Offset(currentObject.getBounds().topLeft.dx, newTopRight.dy),
              Offset(newTopRight.dx, currentObject.getBounds().bottomRight.dy),
            );
        break;
      case InteractionMode.resizingBottomLeft:
        final newBottomLeft =
            currentObject.getBounds().bottomLeft + details.delta;
        _canvasObjects[_currentlySelectedObjectId!] = currentObject.resize(
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
        _canvasObjects[_currentlySelectedObjectId!] =
            currentObject.resize(currentObject.getBounds().topLeft, newBottomRight);
        break;
      case InteractionMode.none:
      case InteractionMode.editingText:
        break;
    }

    notifyListeners();
    syncCanvasObject(_cursorPosition);
  }

  void exitWorkspace() {
    if (_currentlySelectedObjectId != null &&
        _interactionMode == InteractionMode.editingText) {
      _saveCanvasObjectToDb(_currentlySelectedObjectId!);
    }

    _canvasChannel?.unsubscribe();
    _canvasChannel = null;
    _currentWorkspace = null;
    _canvasObjects.clear();
    _userCursors.clear();
    _currentlySelectedObjectId = null;
    _workspaceNameController.text = 'Workspace Name';
    _tempQuillController.clear();
    _interactionMode = InteractionMode.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _workspaceNameController.removeListener(_onWorkspaceNameChanged);
    _workspaceNameController.dispose();
    _tempQuillController.removeListener(
      _onQuillContentChanged,
    );
    _tempQuillController.dispose();
    _canvasChannel?.unsubscribe();
    super.dispose();
  }

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