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
  });

  Circle.fromJson(Map<String, dynamic> json)
    : radius = json['radius'],
      center = Offset(json['center']['x'], json['center']['y']),
      super(id: json['id'], color: Color(json['color']));

  /// Constructor to be used when first starting to draw the object on the canvas
  Circle.createNew(this.center)
    : radius = 0,
      super(id: const Uuid().v4(), color: RandomColor.getRandom());

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
      'color': color.value,
      'center': {'x': center.dx, 'y': center.dy},
      'radius': radius,
    };
  }

  @override
  Circle copyWith({double? radius, Offset? center, Color? color}) {
    return Circle(
      radius: radius ?? this.radius,
      center: center ?? this.center,
      id: id,
      color: color ?? this.color,
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
}