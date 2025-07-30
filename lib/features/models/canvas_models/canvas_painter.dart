// lib/features/models/canvas_models/canvas_painter.dart

import 'dart:convert';
import 'dart:math';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
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
import 'package:cookethflow/features/models/canvas_models/user_cursor.dart';
import 'package:flutter/material.dart';

class CanvasPainter extends CustomPainter {
  final Map<String, UserCursor> userCursors;
  final Map<String, CanvasObject> canvasObjects;
  final String? currentlySelectedObjectId;
  final double handleRadius;
  final InteractionMode interactionMode;

  CanvasPainter({
    required this.userCursors,
    required this.canvasObjects,
    this.currentlySelectedObjectId,
    this.handleRadius = 8.0,
    required this.interactionMode,
  });

  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.black;
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }

  // CHANGE: More robust style parsing
  TextStyle _getTextStyle(Map<String, dynamic>? attributes) {
    if (attributes == null) return const TextStyle(fontSize: 14.0, color: Colors.black);

    double fontSize = 14.0;
    if (attributes['header'] == 1) {
      fontSize = 28.0;
    } else if (attributes['header'] == 2) {
      fontSize = 22.0;
    } else if (attributes.containsKey('size')) {
        // You can add more specific size handling if needed
        fontSize = 14.0; 
    }
    
    final isCode = attributes['code-block'] == true;

    return TextStyle(
      fontWeight: attributes['bold'] == true ? FontWeight.bold : FontWeight.normal,
      fontStyle: attributes['italic'] == true ? FontStyle.italic : FontStyle.normal,
      color: _parseColor(attributes['color'] as String?),
      fontSize: fontSize,
      fontFamily: isCode ? 'monospace' : (attributes['font'] as String?),
      decoration: attributes['underline'] == true ? TextDecoration.underline : TextDecoration.none,
      backgroundColor: attributes['background'] != null
          ? _parseColor(attributes['background'] as String?)
          : null,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final canvasObject in canvasObjects.values) {
      final paint = Paint()..color = canvasObject.color;
      Rect rect;

      if (canvasObject is Circle) {
        canvas.drawCircle(canvasObject.center, canvasObject.radius, paint);
        rect = Rect.fromCircle(center: canvasObject.center, radius: canvasObject.radius);
      } else if (canvasObject is TextBoxObject) {
        rect = canvasObject.getBounds();
        if (canvasObject.color != Colors.transparent) {
          canvas.drawRect(rect, paint);
        }
      } else {
        rect = canvasObject.getBounds();
        if (canvasObject is Rectangle) {
          canvas.drawRect(rect, paint);
        } else if (canvasObject is Square) {
          canvas.drawRect(rect, paint);
        } else if (canvasObject is RoundedSquare) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(canvasObject.cornerRadius)), paint);
        } else if (canvasObject is Diamond) {
          final path = Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.center.dy)
            ..lineTo(rect.center.dx, rect.bottom)
            ..lineTo(rect.left, rect.center.dy)
            ..close();
          canvas.drawPath(path, paint);
        } else if (canvasObject is Triangle) {
          final path = Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close();
          canvas.drawPath(path, paint);
        } else if (canvasObject is InvertedTriangle) {
          final path = Path()
            ..moveTo(rect.left, rect.top)
            ..lineTo(rect.right, rect.top)
            ..lineTo(rect.center.dx, rect.bottom)
            ..close();
          canvas.drawPath(path, paint);
        } else if (canvasObject is Parallelogram) {
          final skew = rect.width * 0.25;
          final path = Path()
            ..moveTo(rect.left + skew, rect.top)
            ..lineTo(rect.right, rect.top)
            ..lineTo(rect.right - skew, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close();
          canvas.drawPath(path, paint);
        } else if (canvasObject is Cylinder) {
          final ellipseHeight = min(rect.height * 0.3, 40.0);
          final bodyRect = Rect.fromLTRB(rect.left, rect.top + ellipseHeight / 2, rect.right, rect.bottom - ellipseHeight / 2);
          canvas.drawRect(bodyRect, paint);
          canvas.drawOval(Rect.fromCenter(center: bodyRect.topCenter, width: rect.width, height: ellipseHeight), paint);
          canvas.drawOval(Rect.fromCenter(center: bodyRect.bottomCenter, width: rect.width, height: ellipseHeight), paint);
        }
      }

      final bool isEditingText = interactionMode == InteractionMode.editingText && currentlySelectedObjectId == canvasObject.id;

      // CHANGE: Rewrote text rendering logic to be more robust.
      if (canvasObject.textDelta != null && canvasObject.textDelta!.isNotEmpty && !isEditingText) {
        try {
          final List<dynamic> delta = jsonDecode(canvasObject.textDelta!);
          
          final List<InlineSpan> textSpans = [];
          for (final op in delta) {
            textSpans.add(TextSpan(
              text: op['insert'],
              style: _getTextStyle(op['attributes'] as Map<String, dynamic>?),
            ));
          }
          final richText = TextSpan(children: textSpans);
          
          final textPainter = TextPainter(
            text: richText,
            textDirection: TextDirection.ltr,
          );
          
          final double textPadding = 8.0;
          final double availableWidth = rect.width - (2 * textPadding);
          if (availableWidth > 0) {
              textPainter.layout(maxWidth: availableWidth);
              canvas.save();
              canvas.clipRect(rect);
              textPainter.paint(canvas, rect.topLeft.translate(textPadding, textPadding));
              canvas.restore();
          }

        } catch (e) {
          print("Error painting text: $e");
        }
      }

      if (canvasObject.id == currentlySelectedObjectId && !isEditingText) {
        final handlePaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

        canvas.drawCircle(rect.topLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.topRight, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomRight, handleRadius, handlePaint);

        final borderPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        if (canvasObject is TextBoxObject && canvasObject.color == Colors.transparent) {
          final path = Path()..addRect(rect);
          canvas.drawPath(
            dashPath(path, dashArray: CircularIntervalList<double>([5.0, 3.0])),
            borderPaint,
          );
        } else {
          canvas.drawRect(rect, borderPaint);
        }
      }
    }

    for (final userCursor in userCursors.values) {
      final position = userCursor.position;
      final paint = Paint()..color = userCursor.color;
      final path = Path()
        ..moveTo(position.dx, position.dy)
        ..lineTo(position.dx, position.dy + 20)
        ..lineTo(position.dx + 5, position.dy + 15)
        ..moveTo(position.dx, position.dy + 20)
        ..lineTo(position.dx + 10, position.dy + 20)
        ..close();
      canvas.drawPath(path, paint..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldPainter) {
    return oldPainter.userCursors != userCursors ||
           oldPainter.canvasObjects.length != canvasObjects.length ||
           oldPainter.currentlySelectedObjectId != currentlySelectedObjectId ||
           oldPainter.interactionMode != interactionMode ||
           _hasCanvasObjectsChanged(oldPainter.canvasObjects, canvasObjects);
  }

  bool _hasCanvasObjectsChanged(Map<String, CanvasObject> oldObjects, Map<String, CanvasObject> newObjects) {
    if (oldObjects.length != newObjects.length) return true;
    for (final id in newObjects.keys) {
      final newObj = newObjects[id];
      final oldObj = oldObjects[id];
      if (oldObj == null || newObj == null) return true;
      if (newObj.getBounds() != oldObj.getBounds()) return true;
      if (newObj.textDelta != oldObj.textDelta) return true;
    }
    return false;
  }
}

Path dashPath(Path source, {required CircularIntervalList<double> dashArray}) {
  final Path dest = Path();
  for (final metric in source.computeMetrics()) {
    double distance = 0.0;
    bool draw = true;
    while (distance < metric.length) {
      final len = dashArray.next;
      if (draw) {
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      draw = !draw;
    }
  }
  return dest;
}

class CircularIntervalList<T> {
  CircularIntervalList(this._values);
  final List<T> _values;
  int _idx = 0;
  T get next {
    if (_idx >= _values.length) {
      _idx = 0;
    }
    return _values[_idx++];
  }
}