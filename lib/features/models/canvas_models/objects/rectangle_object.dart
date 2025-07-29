// lib/features/models/canvas_models/objects/rectangle_object.dart

import 'dart:math';
import 'dart:ui';

import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:uuid/uuid.dart';

/// Rectangle displayed on the canvas.
class Rectangle extends CanvasObject {
  static const String type = 'rectangle';

  final Offset topLeft;
  final Offset bottomRight;

  Rectangle({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
    super.textDelta, // ADDED: textDelta to constructor
  });

  Rectangle.fromJson(Map<String, dynamic> json)
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

  /// Constructor to be used when first creating the object on the canvas with a default size
  Rectangle.createNew(Offset defaultTopLeft, Offset defaultBottomRight)
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
  Rectangle copyWith({
    Offset? topLeft,
    Offset? bottomRight,
    Color? color,
    String? textDelta,
  }) {
    // ADDED: textDelta to copyWith signature
    return Rectangle(
      topLeft: topLeft ?? this.topLeft,
      id: id,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
      textDelta: textDelta ?? this.textDelta, // ADDED: Copy textDelta
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
  Rectangle move(Offset delta) {
    return copyWith(topLeft: topLeft + delta, bottomRight: bottomRight + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  Rectangle resize(Offset newTopLeft, Offset newBottomRight) {
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
