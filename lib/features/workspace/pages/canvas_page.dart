// ===== UPDATED FILE: lib/features/canvas/pages/canvas_page.dart =====

import 'dart:math';
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/consts.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_painter.dart';
// ** Importing all the shape models **
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
    // This logic is kept exactly as you provided it.
    _myId = _supabaseService.supabase.auth.currentUser?.id ?? const Uuid().v4();

    _canvasChannel =
        _supabaseService.supabase.channel(Constants.channelName).onBroadcast(
      event: Constants.broadcastEventName,
      callback: (payload) {
        if (!mounted) return;
        final cursor = UserCursor.fromJson(payload['cursor']);
        _userCursors[cursor.id] = cursor;

        if (payload['object'] != null) {
          final object = CanvasObject.fromJson(payload['object']);
          _canvasObjects[object.id] = object;
        }
        setState(() {});
      },
    ).subscribe();

    final initialData = await _supabaseService.supabase
        .from('canvas_objects')
        .select()
        .order('created_at', ascending: true);
        
    if (mounted) {
      setState(() {
        for (final canvasObjectData in initialData) {
          final canvasObject =
              CanvasObject.fromJson(canvasObjectData['object']);
          _canvasObjects[canvasObject.id] = canvasObject;
        }
      });
    }
  }

  Future<void> _syncCanvasObject(Offset cursorPosition) {
    // This logic is kept exactly as you provided it.
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
    _cursorPosition = details.globalPosition;
    _panStartPoint = details.globalPosition;

    CanvasObject? newObject;
    switch (_currentMode) {
      case _DrawMode.pointer:
        for (final canvasObject in _canvasObjects.values.toList().reversed) {
          if (canvasObject.intersectsWith(details.globalPosition)) {
            _currentlyDrawingObjectId = canvasObject.id;
            break;
          }
        }
        break;
      case _DrawMode.circle:
        newObject = Circle.createNew(details.globalPosition);
        break;
      case _DrawMode.rectangle:
        newObject = Rectangle.createNew(details.globalPosition);
        break;
      case _DrawMode.square:
        newObject = Square.createNew(details.globalPosition);
        break;
      // ** 2. Add cases to create new shapes on pan down **
      case _DrawMode.diamond:
        newObject = Diamond.createNew(details.globalPosition);
        break;
      case _DrawMode.roundedSquare:
        newObject = RoundedSquare.createNew(details.globalPosition);
        break;
      case _DrawMode.parallelogram:
        newObject = Parallelogram.createNew(details.globalPosition);
        break;
      case _DrawMode.cylinder:
        newObject = Cylinder.createNew(details.globalPosition);
        break;
      case _DrawMode.triangle:
        newObject = Triangle.createNew(details.globalPosition);
        break;
      case _DrawMode.invertedTriangle:
        newObject = InvertedTriangle.createNew(details.globalPosition);
        break;
    }

    if (newObject != null) {
      setState(() {
        _canvasObjects[newObject!.id] = newObject;
        _currentlyDrawingObjectId = newObject.id;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _cursorPosition = details.globalPosition;
    if (_currentlyDrawingObjectId == null) return;

    final currentObject = _canvasObjects[_currentlyDrawingObjectId!];
    if (currentObject == null) return;

    switch (_currentMode) {
      case _DrawMode.pointer:
        _canvasObjects[_currentlyDrawingObjectId!] =
            currentObject.move(details.delta);
        break;
      case _DrawMode.circle:
        final currentlyDrawingCircle = currentObject as Circle;
        _canvasObjects[_currentlyDrawingObjectId!] =
            currentlyDrawingCircle.copyWith(
          center: (details.globalPosition + _panStartPoint!) / 2,
          radius: min(
                (details.globalPosition.dx - _panStartPoint!.dx).abs(),
                (details.globalPosition.dy - _panStartPoint!.dy).abs(),
              ) / 2,
        );
        break;
      // ** 3. Add cases to update new shapes on pan update **
      case _DrawMode.rectangle:
      case _DrawMode.square:
      case _DrawMode.diamond:
      case _DrawMode.roundedSquare:
      case _DrawMode.parallelogram:
      case _DrawMode.cylinder:
      case _DrawMode.triangle:
      case _DrawMode.invertedTriangle:
        _canvasObjects[_currentlyDrawingObjectId!] =
            (currentObject as dynamic).copyWith(
          bottomRight: details.globalPosition,
        );
        break;
    }

    if (_currentlyDrawingObjectId != null) {
      setState(() {});
    }
    _syncCanvasObject(_cursorPosition);
  }

  void onPanEnd(DragEndDetails details) async {
    // This logic is kept exactly as you provided it.
    if (_currentlyDrawingObjectId != null) {
      _syncCanvasObject(_cursorPosition);
    }

    final drawnObjectId = _currentlyDrawingObjectId;

    setState(() {
      _panStartPoint = null;
      _currentlyDrawingObjectId = null;
    });

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
            GestureDetector(
              onPanDown: _onPanDown,
              onPanUpdate: _onPanUpdate, // Corrected typo here
              onPanEnd: onPanEnd,
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: CanvasPainter(
                  userCursors: _userCursors,
                  canvasObjects: _canvasObjects,
                ),
              ),
            ),
            // This is your original UI structure for the toolbar.
            Positioned(
              top: 500,
              left: 0,
              child: Row(
                children: _DrawMode.values
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

// ** 4. Add the new draw modes to the enum **
enum _DrawMode {
  pointer(iconData: Icons.pan_tool_alt),
  circle(iconData: Icons.circle_outlined),
  rectangle(iconData: Icons.rectangle_outlined),
  square(iconData: Icons.square_outlined),
  diamond(iconData: Icons.diamond_outlined),
  roundedSquare(iconData: Icons.rounded_corner),
  parallelogram(iconData: Icons.square_foot_outlined), // Placeholder
  cylinder(iconData: Icons.view_in_ar_outlined), // Placeholder
  triangle(iconData: Icons.change_history),
  invertedTriangle(iconData: Icons.warning_amber_rounded); // Placeholder

  const _DrawMode({required this.iconData});
  final IconData iconData;
}
