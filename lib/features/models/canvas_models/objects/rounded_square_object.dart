// lib/features/models/canvas_models/objects/rounded_square_object.dart

import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RoundedSquare extends CanvasObject {
  static const String type = 'rounded_square';
  final Offset topLeft;
  final Offset bottomRight;
  final double cornerRadius;

  RoundedSquare({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
    this.cornerRadius = 10.0,
    super.textDelta,
  });

  RoundedSquare.fromJson(Map<String, dynamic> json)
    : bottomRight = Offset(
        json['bottom_right']['x'],
        json['bottom_right']['y'],
      ),
      topLeft = Offset(json['top_left']['x'], json['top_left']['y']),
      cornerRadius = json['corner_radius'] ?? 10.0,
      super(
        id: json['id'],
        color: Color(json['color'] as int),
        textDelta: json['text_delta'],
      );

  RoundedSquare.createNew(Offset defaultTopLeft, Offset defaultBottomRight)
    : topLeft = defaultTopLeft,
      bottomRight = defaultBottomRight,
      cornerRadius = 10.0,
      super(
        color: RandomColor.getRandom(),
        id: const Uuid().v4(),
        textDelta: null,
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
      'color': color.value,
      'top_left': {'x': topLeft.dx, 'y': topLeft.dy},
      'bottom_right': {'x': bottomRight.dx, 'y': bottomRight.dy},
      'corner_radius': cornerRadius,
      'text_delta': textDelta,
    };
  }

  @override
  RoundedSquare copyWith({
    Offset? topLeft,
    Offset? bottomRight,
    Color? color,
    String? textDelta,
  }) {
    return RoundedSquare(
      topLeft: topLeft ?? this.topLeft,
      id: id,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
      cornerRadius: cornerRadius,
      textDelta: textDelta ?? this.textDelta,
    );
  }

  @override
  bool intersectsWith(Offset point) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    return rect.contains(point);
  }

  @override
  RoundedSquare move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  RoundedSquare resize(Offset newTopLeft, Offset newBottomRight) {
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