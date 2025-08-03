// lib/features/models/canvas_models/objects/text_box_object.dart

import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TextBoxObject extends CanvasObject {
  static const String type = 'text_box';

  final Offset topLeft;
  final Offset bottomRight;

  TextBoxObject({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
    super.textDelta,
  });

  factory TextBoxObject.fromJson(Map<String, dynamic> json) {
    return TextBoxObject(
      id: json['id'],
      color: Color(json['color']),
      topLeft: Offset(json['top_left']['x'], json['top_left']['y']),
      bottomRight: Offset(
        json['bottom_right']['x'],
        json['bottom_right']['y'],
      ),
      textDelta: json['text_delta'],
    );
  }

  factory TextBoxObject.createNew(
      Offset defaultTopLeft, Offset defaultBottomRight) {
    return TextBoxObject(
      id: const Uuid().v4(),
      color: Colors.transparent,
      topLeft: defaultTopLeft,
      bottomRight: defaultBottomRight,
      textDelta: null,
    );
  }

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
  TextBoxObject copyWith({
    Offset? topLeft,
    Offset? bottomRight,
    Color? color,
    String? textDelta,
  }) {
    return TextBoxObject(
      id: id,
      color: color ?? this.color,
      topLeft: topLeft ?? this.topLeft,
      bottomRight: bottomRight ?? this.bottomRight,
      textDelta: textDelta ?? this.textDelta,
    );
  }

  @override
  bool intersectsWith(Offset point) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    return rect.contains(point);
  }

  @override
  TextBoxObject move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  TextBoxObject resize(Offset newTopLeft, Offset newBottomRight) {
    final correctedTopLeft = Offset(
      min(newTopLeft.dx, newBottomRight.dx),
      min(newTopLeft.dy, newBottomRight.dy),
    );
    final correctedBottomRight = Offset(
      max(newTopLeft.dx, newBottomRight.dx),
      max(newTopLeft.dy, newBottomRight.dy),
    );
    return copyWith(
        topLeft: correctedTopLeft, bottomRight: correctedBottomRight);
  }
}