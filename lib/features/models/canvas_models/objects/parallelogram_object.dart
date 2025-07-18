import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Parallelogram extends CanvasObject {
  static const String type = 'parallelogram';
  final Offset topLeft;
  final Offset bottomRight;

  Parallelogram({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
  });

  Parallelogram.fromJson(Map<String, dynamic> json)
      : bottomRight = Offset(json['bottom_right']['x'], json['bottom_right']['y']),
        topLeft = Offset(json['top_left']['x'], json['top_left']['y']),
        super(id: json['id'], color: Color(json['color']));

  Parallelogram.createNew(Offset startingPoint)
      : topLeft = startingPoint,
        bottomRight = startingPoint,
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
  Parallelogram copyWith({Offset? topLeft, Offset? bottomRight, Color? color}) {
    return Parallelogram(
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
  Parallelogram move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }
}