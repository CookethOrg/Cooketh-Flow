import 'dart:convert';
import 'dart:math';

import 'package:cookethflow/features/models/canvas_models/objects/circle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rectangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/square_object.dart';
import 'package:cookethflow/features/models/canvas_models/synced_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

extension RandomColor on Color {
  static Color getRandom() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  // To generate random color for each new user
  static Color getRandomFromUserId(String id) {
    final seed = utf8.encode(id).reduce((value, element) => value + element);
    return Color(
      (Random(seed).nextDouble() * 0xFFFFFF).toInt(),
    ).withOpacity(1.0);
  }
}

/// Base model for any design objects displayed on the canvas.
abstract class CanvasObject extends SyncedObject {
  final Color color;

  CanvasObject({required super.id, required this.color});

  factory CanvasObject.fromJson(Map<String, dynamic> json) {
    if (json['object_type'] == Circle.type) {
      return Circle.fromJson(json);
    } else if (json['object_type'] == Rectangle.type) {
      return Rectangle.fromJson(json);
    } else if (json['object_type'] == Square.type) {
      return Square.fromJson(json);
    } else {
      throw UnimplementedError('Unknown object_type: ${json['object_type']}');
    }
  }

  /// Whether or not the object intersects with the given point.
  bool intersectsWith(Offset point);

  CanvasObject copyWith();

  /// Moves the object to a new position
  CanvasObject move(Offset delta);
}
