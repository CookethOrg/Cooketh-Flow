import 'dart:math';

import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Square extends CanvasObject {
  static const String type = 'square';
  final Offset topLeft;
  final Offset bottomRight;

  Square._({
    required super.id,
    required super.color,
    required this.bottomRight,
    required this.topLeft,
  });

  factory Square({
    required String id,
    required Color color,
    required Offset topLeft,
    required Offset bottomRight,
  }) {
    // Ensure it's a square when created or resized
    final dx = bottomRight.dx - topLeft.dx;
    final dy = bottomRight.dy - topLeft.dy;
    final side = max(dx.abs(), dy.abs());

    final adjustedBottomRight = Offset(
      topLeft.dx + side * dx.sign,
      topLeft.dy + side * dy.sign,
    );

    return Square._(
      id: id,
      color: color,
      topLeft: topLeft,
      bottomRight: adjustedBottomRight,
    );
  }

  Square.fromJson(Map<String, dynamic> json)
    : bottomRight = Offset(
        json['bottom_right']['x'],
        json['bottom_right']['y'],
      ),
      topLeft = Offset(json['top_left']['x'], json['top_left']['y']),
      super(id: json['id'], color: Color(json['color']));
  
  Square.createNew(Offset defaultTopLeft, Offset defaultBottomRight)
    : topLeft = defaultTopLeft,
      bottomRight = defaultBottomRight,
      super(id: const Uuid().v4(), color: RandomColor.getRandom());

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
  Square copyWith({Offset? topLeft, Offset? bottomRight, Color? color}) {
    // Pass through the factory constructor to ensure it remains a square
    return Square(
      id: id,
      color: color ?? this.color,
      bottomRight: bottomRight ?? this.bottomRight,
      topLeft: topLeft ?? this.topLeft,
    );
  }

  @override
  bool intersectsWith(Offset point) {
    final minX = min(topLeft.dx, bottomRight.dx);
    final maxX = max(topLeft.dx, bottomRight.dx);
    final minY = min(topLeft.dy, bottomRight.dy);
    final maxY = max(topLeft.dy, bottomRight.dy);
    return minX < point.dx &&
        point.dx < maxX &&
        minY < point.dy &&
        point.dy < maxY;
  }

  @override
  Square move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  Square resize(Offset newTopLeft, Offset newBottomRight) {
    // Ensure square constraint is maintained during resize
    return Square(
      id: id,
      color: color,
      topLeft: newTopLeft,
      bottomRight: newBottomRight,
    );
  }
}