import 'dart:math';
import 'dart:ui';

import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:uuid/uuid.dart';

/// Rectangle displayed on the canvas.
class Rectangle extends CanvasObject {
  static String type = 'rectangle';

  final Offset topLeft;
  final Offset bottomRight;

  Rectangle({
    required super.id,
    required super.color,
    required this.topLeft,
    required this.bottomRight,
  });

  Rectangle.fromJson(Map<String, dynamic> json)
    : bottomRight = Offset(
        json['bottom_right']['x'],
        json['bottom_right']['y'],
      ),
      topLeft = Offset(json['top_left']['x'], json['top_left']['y']),
      super(id: json['id'], color: Color(json['color']));

  /// Constructor to be used when first starting to draw the object on the canvas
  Rectangle.createNew(Offset startingPoint)
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
  Rectangle copyWith({Offset? topLeft, Offset? bottomRight, Color? color}) {
    return Rectangle(
      topLeft: topLeft ?? this.topLeft,
      id: id,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
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
}