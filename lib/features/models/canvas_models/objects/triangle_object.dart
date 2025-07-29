// lib/features/models/canvas_models/objects/triangle_object.dart

import 'dart:math'; // Added for min/max in resize
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Triangle extends CanvasObject {
  static const String type = 'triangle';
  final Offset topLeft;
  final Offset bottomRight;

  Triangle({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
    super.textDelta, // ADDED: textDelta to constructor
  });

  Triangle.fromJson(Map<String, dynamic> json)
    : bottomRight = Offset(
        json['bottom_right']['x'],
        json['bottom_right']['y'],
      ),
      topLeft = Offset(json['top_left']['x'], json['top_left']['y']),
      super(
        id: json['id'],
        color: Color(json['color'] as int),
        textDelta: json['text_delta'], // ADDED: Load text_delta
      );

  Triangle.createNew(Offset defaultTopLeft, Offset defaultBottomRight)
    : topLeft = defaultTopLeft,
      bottomRight = defaultBottomRight,
      super(
        color: RandomColor.getRandom(),
        id: const Uuid().v4(),
        textDelta: null, // Initial text is null
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
      'color': color.value,
      'top_left': {'x': topLeft.dx, 'y': topLeft.dy},
      'bottom_right': {'x': bottomRight.dx, 'y': bottomRight.dy},
      'text_delta': textDelta, // ADDED: Save text_delta
    };
  }

  @override
  Triangle copyWith({
    Offset? topLeft,
    Offset? bottomRight,
    Color? color,
    String? textDelta,
  }) {
    // ADDED: textDelta to copyWith signature
    return Triangle(
      topLeft: topLeft ?? this.topLeft,
      id: id,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
      textDelta: textDelta ?? this.textDelta, // ADDED: Copy textDelta
    );
  }

  @override
  bool intersectsWith(Offset point) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    return rect.contains(point);
  }

  @override
  Triangle move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  Triangle resize(Offset newTopLeft, Offset newBottomRight) {
    // Ensure that width and height are not negative
    final correctedTopLeft = Offset(
      min(newTopLeft.dx, newBottomRight.dx),
      min(newTopLeft.dy, newBottomRight.dy),
    );
    final correctedBottomRight = Offset(
      max(newTopLeft.dx, newBottomRight.dx),
      max(newTopLeft.dy, newBottomRight.dy),
    );
    return copyWith(
      topLeft: correctedTopLeft,
      bottomRight: correctedBottomRight,
    );
  }
}
