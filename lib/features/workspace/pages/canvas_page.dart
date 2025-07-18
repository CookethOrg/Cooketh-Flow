import 'dart:math';

import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/consts.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_painter.dart';
import 'package:cookethflow/features/models/canvas_models/objects/circle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rectangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/user_cursor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  final Map<String, UserCursor> _userCursors = {};
  final Map<String, CanvasObject> _canvasObjects = {};
  late RealtimeChannel _canvasChannel;
  late String _myId;
  _DrawMode _currentMode = _DrawMode.pointer;
  String? _currentlyDrawingObjectId;
  Offset? _panStartPoint;
  Offset _cursorPosition = const Offset(0, 0);
  late SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = Provider.of<SupabaseService>(context, listen: false);
    _initialize();
  }

  Future<void> _initialize() async {
    // Use the authenticated user ID if available, otherwise generate a random one
    // _myId = _supabaseService.userData.user?.id ?? const Uuid().v4();
    _myId = Uuid().v4();

    // Start listening to broadcast messages
    _canvasChannel =
        _supabaseService.supabase
            .channel(Constants.channelName)
            .onBroadcast(
              event: Constants.broadcastEventName,
              callback: (payload) {
                final cursor = UserCursor.fromJson(payload['cursor']);
                _userCursors[cursor.id] = cursor;

                if (payload['object'] != null) {
                  final object = CanvasObject.fromJson(payload['object']);
                  _canvasObjects[object.id] = object;
                }
                if(mounted){
                  setState(() {});
                }
              },
            )
            .subscribe();

    // Load initial canvas objects
    final initialData = await _supabaseService.supabase
        .from('canvas_objects')
        .select()
        .order('created_at', ascending: true);

    for (final canvasObjectData in initialData) {
      final canvasObject = CanvasObject.fromJson(canvasObjectData['object']);
      _canvasObjects[canvasObject.id] = canvasObject;
    }
    if(mounted){
      setState(() {});
    }
  }

  Future<void> _syncCanvasObject(Offset cursorPosition) {
    final myCursor = UserCursor(position: cursorPosition, id: _myId);
    return _canvasChannel.sendBroadcastMessage(
      event: Constants.broadcastEventName,
      payload: {
        'cursor': myCursor.toJson(),
        if (_currentlyDrawingObjectId != null)
          'object': _canvasObjects[_currentlyDrawingObjectId]?.toJson(),
      },
    );
  }

  void _onPanDown(DragDownDetails details) {
    switch (_currentMode) {
      case _DrawMode.pointer:
        // Loop through the canvas objects to find if there are any
        // that intersects with the current mouse position.
        for (final canvasObject in _canvasObjects.values.toList().reversed) {
          if (canvasObject.intersectsWith(details.globalPosition)) {
            _currentlyDrawingObjectId = canvasObject.id;
            break;
          }
        }
        break;
      case _DrawMode.circle:
        final newObject = Circle.createNew(details.globalPosition);
        _canvasObjects[newObject.id] = newObject;
        _currentlyDrawingObjectId = newObject.id;
        break;
      case _DrawMode.rectangle:
        final newObject = Rectangle.createNew(details.globalPosition);
        _canvasObjects[newObject.id] = newObject;
        _currentlyDrawingObjectId = newObject.id;
        break;
    }
    _cursorPosition = details.globalPosition;
    _panStartPoint = details.globalPosition;
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    switch (_currentMode) {
      // Moves the object to [details.delta] amount.
      case _DrawMode.pointer:
        if (_currentlyDrawingObjectId != null) {
          _canvasObjects[_currentlyDrawingObjectId!] =
              _canvasObjects[_currentlyDrawingObjectId!]!.move(details.delta);
        }
        break;

      // Updates the size of the Circle
      case _DrawMode.circle:
        final currentlyDrawingCircle =
            _canvasObjects[_currentlyDrawingObjectId!]! as Circle;
        _canvasObjects[_currentlyDrawingObjectId!] = currentlyDrawingCircle
            .copyWith(
              center: (details.globalPosition + _panStartPoint!) / 2,
              radius:
                  min(
                    (details.globalPosition.dx - _panStartPoint!.dx).abs(),
                    (details.globalPosition.dy - _panStartPoint!.dy).abs(),
                  ) /
                  2,
            );
        break;

      // Updates the size of the rectangle
      case _DrawMode.rectangle:
        _canvasObjects[_currentlyDrawingObjectId!] =
            (_canvasObjects[_currentlyDrawingObjectId!] as Rectangle).copyWith(
              bottomRight: details.globalPosition,
            );
        break;
    }

    if (_currentlyDrawingObjectId != null) {
      setState(() {});
    }
    _cursorPosition = details.globalPosition;
    _syncCanvasObject(_cursorPosition);
  }

  void onPanEnd(DragEndDetails _) async {
    if (_currentlyDrawingObjectId != null) {
      _syncCanvasObject(_cursorPosition);
    }

    final drawnObjectId = _currentlyDrawingObjectId;

    setState(() {
      _panStartPoint = null;
      _currentlyDrawingObjectId = null;
    });

    // Save whatever was drawn to Supabase DB
    if (drawnObjectId == null) {
      return;
    }
    await _supabaseService.supabase.from('canvas_objects').upsert({
      'id': drawnObjectId,
      'object': _canvasObjects[drawnObjectId]!.toJson(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          _syncCanvasObject(event.position);
        },
        child: Stack(
          children: [
            // The main canvas
            GestureDetector(
              onPanDown: _onPanDown,
              onPanUpdate: _onPanUpdate,
              onPanEnd: onPanEnd,
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: CanvasPainter(
                  userCursors: _userCursors,
                  canvasObjects: _canvasObjects,
                ),
              ),
            ),

            // Buttons to change the current mode.
            Positioned(
              top: 500,
              left: 0,
              child: Row(
                children:
                    _DrawMode.values
                        .map(
                          (mode) => IconButton(
                            iconSize: 48,
                            onPressed: () {
                              setState(() {
                                _currentMode = mode;
                              });
                            },
                            icon: Icon(mode.iconData),
                            color: _currentMode == mode ? Colors.green : null,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _canvasChannel.unsubscribe();
    super.dispose();
  }
}

enum _DrawMode {
  pointer(iconData: Icons.pan_tool_alt),
  circle(iconData: Icons.circle_outlined),
  rectangle(iconData: Icons.rectangle_outlined);

  const _DrawMode({required this.iconData});
  final IconData iconData;
}
