import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Cylinder extends CanvasObject {
  static const String type = 'cylinder';
  final Offset topLeft;
  final Offset bottomRight;

  Cylinder({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
  });

  Cylinder.fromJson(Map<String, dynamic> json)
      : bottomRight = Offset(json['bottom_right']['x'], json['bottom_right']['y']),
        topLeft = Offset(json['top_left']['x'], json['top_left']['y']),
        super(id: json['id'], color: Color(json['color']));

  Cylinder.createNew(Offset defaultTopLeft, Offset defaultBottomRight)
      : topLeft = defaultTopLeft,
        bottomRight = defaultBottomRight,
        super(color: RandomColor.getRandom(), id: const Uuid().v4());

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
      'color': color.value,
      'top_left': {'x': topLeft.dx, 'y': topLeft.dy},
      'bottom_right': {'x': bottomRight.dx, 'y': bottomRight.dy},
    };
  }

  @override
  Cylinder copyWith({Offset? topLeft, Offset? bottomRight, Color? color}) {
    return Cylinder(
      topLeft: topLeft ?? this.topLeft,
      id: id,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
    );
  }

  @override
  bool intersectsWith(Offset point) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    return rect.contains(point);
  }

  @override
  Cylinder move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  Cylinder resize(Offset newTopLeft, Offset newBottomRight) {
    return copyWith(topLeft: newTopLeft, bottomRight: newBottomRight);
  }
}