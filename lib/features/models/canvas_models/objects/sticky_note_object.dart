import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StickyNoteObject extends CanvasObject {
  static const String type = 'sticky_note';

  final Offset topLeft;
  final Offset bottomRight;

  StickyNoteObject({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
    super.textDelta,
  });

  factory StickyNoteObject.fromJson(Map<String, dynamic> json) {
    return StickyNoteObject(
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

  factory StickyNoteObject.createNew({
    required Offset position,
    required Color color,
    double width = 140.0,
    double height = 180.0,
  }) {
    final topLeft = position - Offset(width / 2, height / 2);
    final bottomRight = position + Offset(width / 2, height / 2);
    return StickyNoteObject(
      id: const Uuid().v4(),
      color: color,
      topLeft: topLeft,
      bottomRight: bottomRight,
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
  StickyNoteObject copyWith({
    Offset? topLeft,
    Offset? bottomRight,
    Color? color,
    String? textDelta,
  }) {
    return StickyNoteObject(
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
  StickyNoteObject move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  StickyNoteObject resize(Offset newTopLeft, Offset newBottomRight) {
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