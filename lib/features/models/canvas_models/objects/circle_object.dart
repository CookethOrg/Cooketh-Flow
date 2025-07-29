import 'dart:math';
import 'dart:ui';

import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:uuid/uuid.dart';

/// Circle displayed on the canvas.
class Circle extends CanvasObject {
  static const String type = 'circle';

  final Offset center;
  final double radius;

  Circle({
    required super.id,
    required super.color,
    required this.radius,
    required this.center,
    super.textDelta,
  });

  Circle.fromJson(Map<String, dynamic> json)
    : radius = json['radius'],
      center = Offset(json['center']['x'], json['center']['y']),
      super(
        id: json['id'],
        color: Color(json['color'] as int),
        textDelta: json['text_delta'],
      );

  /// Constructor to be used when first creating the object on the canvas with a default size
  Circle.createNew(Offset position, double defaultRadius)
    : radius = defaultRadius,
      center = position,
      super(
        id: const Uuid().v4(),
        color: RandomColor.getRandom(),
        textDelta: null,
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
      'color': color.value,
      'center': {'x': center.dx, 'y': center.dy},
      'radius': radius,
      'text_delta': textDelta,
    };
  }

  @override
  Circle copyWith({
    double? radius,
    Offset? center,
    Color? color,
    String? textDelta,
  }) {
    return Circle(
      radius: radius ?? this.radius,
      center: center ?? this.center,
      id: id,
      color: color ?? this.color,
      textDelta: textDelta ?? this.textDelta,
    );
  }

  @override
  bool intersectsWith(Offset point) {
    final centerToPointerDistance = (point - center).distance;
    return radius > centerToPointerDistance;
  }

  @override
  Circle move(Offset delta) {
    return copyWith(center: center + delta);
  }

  @override
  Rect getBounds() {
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  Circle resize(Offset newTopLeft, Offset newBottomRight) {
    final newCenter = (newTopLeft + newBottomRight) / 2;
    final newWidth = (newBottomRight.dx - newTopLeft.dx).abs();
    final newHeight = (newBottomRight.dy - newTopLeft.dy).abs();
    final newRadius = (max(newWidth, newHeight)) / 2;
    return copyWith(center: newCenter, radius: newRadius);
  }
}
