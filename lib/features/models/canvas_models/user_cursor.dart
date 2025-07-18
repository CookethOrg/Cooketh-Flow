import 'dart:ui';

import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/synced_object.dart';

/// Data model for the cursors displayed on the canvas.
class UserCursor extends SyncedObject {
  static String type = 'cursor';

  final Offset position;
  final Color color;

  UserCursor({
    required super.id,
    required this.position,
  }) : color = RandomColor.getRandomFromUserId(id);

  UserCursor.fromJson(Map<String, dynamic> json)
      : position = Offset(json['position']['x'], json['position']['y']),
        color = RandomColor.getRandomFromUserId(json['id']),
        super(id: json['id']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
      'position': {
        'x': position.dx,
        'y': position.dy,
      }
    };
  }
}