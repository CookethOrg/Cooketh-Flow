import 'dart:convert';
import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/objects/circle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/cylinder_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/diamond_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/inverted_triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/parallelogram_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rectangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rounded_square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/synced_object.dart';
import 'package:flutter/material.dart';

extension RandomColor on Color {
  static Color getRandom() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  static Color getRandomFromUserId(String id) {
    final seed = utf8.encode(id).reduce((value, element) => value + element);
    return Color(
      (Random(seed).nextDouble() * 0xFFFFFF).toInt(),
    ).withOpacity(1.0);
  }
}

abstract class CanvasObject extends SyncedObject {
  final Color color;
  final String? textDelta;

  CanvasObject({required super.id, required this.color, this.textDelta});

  factory CanvasObject.fromJson(Map<String, dynamic> json) {
    final objectType = json['object_type'];
    switch (objectType) {
      case Circle.type:
        return Circle.fromJson(json);
      case Rectangle.type:
        return Rectangle.fromJson(json);
      case Square.type:
        return Square.fromJson(json);
      case Diamond.type:
        return Diamond.fromJson(json);
      case RoundedSquare.type:
        return RoundedSquare.fromJson(json);
      case Parallelogram.type:
        return Parallelogram.fromJson(json);
      case Cylinder.type:
        return Cylinder.fromJson(json);
      case Triangle.type:
        return Triangle.fromJson(json);
      case InvertedTriangle.type:
        return InvertedTriangle.fromJson(json);
      case TextBoxObject.type:
        return TextBoxObject.fromJson(json);
      default:
        throw UnimplementedError('Unknown object_type: $objectType');
    }
  }

  bool intersectsWith(Offset point);
  CanvasObject copyWith({String? textDelta});
  CanvasObject move(Offset delta);
  Rect getBounds();
  CanvasObject resize(
    Offset newTopLeft,
    Offset newBottomRight,
  );
}
