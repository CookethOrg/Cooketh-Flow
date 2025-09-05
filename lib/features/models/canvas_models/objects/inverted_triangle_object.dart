import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class InvertedTriangle extends CanvasObject {
  static const String type = 'inverted_triangle';
  final Offset topLeft;
  final Offset bottomRight;

  InvertedTriangle({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
    super.textDelta,
  });

  InvertedTriangle.fromJson(Map<String, dynamic> json)
    : bottomRight = Offset(
        json['bottom_right']['x'],
        json['bottom_right']['y'],
      ),
      topLeft = Offset(json['top_left']['x'], json['top_left']['y']),
      super(
        id: json['id'],
        color: Color(json['color'] as int),
        textDelta: json['text_delta'],
      );

  InvertedTriangle.createNew(Offset defaultTopLeft, Offset defaultBottomRight)
    : topLeft = defaultTopLeft,
      bottomRight = defaultBottomRight,
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
      'text_delta': textDelta,
    };
  }

  @override
  InvertedTriangle copyWith({
    Offset? topLeft,
    Offset? bottomRight,
    Color? color,
    String? textDelta,
  }) {
    return InvertedTriangle(
      topLeft: topLeft ?? this.topLeft,
      id: id,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
      textDelta: textDelta ?? this.textDelta,
    );
  }

  @override
  bool intersectsWith(Offset point) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    return rect.contains(point);
  }

  @override
  InvertedTriangle move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  InvertedTriangle resize(Offset newTopLeft, Offset newBottomRight) {
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