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

  // Helper method to parse color from string
  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.black;
    try {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final canvasObject in canvasObjects.values) {
      final paint = Paint()..color = canvasObject.color;
      Rect rect;

      if (canvasObject is Circle) {
        canvas.drawCircle(canvasObject.center, canvasObject.radius, paint);
        rect = Rect.fromCircle(
            center: canvasObject.center, radius: canvasObject.radius);
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
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  rect, Radius.circular(canvasObject.cornerRadius)),
              paint);
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
          final bodyRect = Rect.fromLTRB(rect.left,
              rect.top + ellipseHeight / 2, rect.right, rect.bottom - ellipseHeight / 2);
          canvas.drawRect(bodyRect, paint);
          canvas.drawOval(
              Rect.fromCenter(
                  center: bodyRect.topCenter,
                  width: rect.width,
                  height: ellipseHeight),
              paint);
          canvas.drawOval(
              Rect.fromCenter(
                  center: bodyRect.bottomCenter,
                  width: rect.width,
                  height: ellipseHeight),
              paint);
        }
      }

      final bool isEditingText = interactionMode == InteractionMode.editingText &&
                                  currentlySelectedObjectId == canvasObject.id;

      // CHANGE: Rewrote text rendering logic for proper styling.
      if (canvasObject.textDelta != null &&
          canvasObject.textDelta!.isNotEmpty &&
          !isEditingText) {
        try {
          final List<dynamic> deltaJson = jsonDecode(canvasObject.textDelta!);
          final List<TextSpan> textSpans = [];
          int listCounter = 1;

          for (final op in deltaJson) {
            if (op is Map && op.containsKey('insert')) {
              String text = op['insert'];
              final Map<String, dynamic>? attributes =
                  op['attributes'] as Map<String, dynamic>?;

              double fontSize = 14.0;
              FontWeight fontWeight = FontWeight.normal;
              FontStyle fontStyle = FontStyle.normal;
              TextDecoration textDecoration = TextDecoration.none;
              Color color = Colors.black;
              Color? backgroundColor;
              String? listType;

              if (attributes != null) {
                fontWeight = attributes['bold'] == true
                    ? FontWeight.bold
                    : FontWeight.normal;
                fontStyle = attributes['italic'] == true
                    ? FontStyle.italic
                    : FontStyle.normal;
                textDecoration = attributes['underline'] == true
                    ? TextDecoration.underline
                    : TextDecoration.none;
                color = _parseColor(attributes['color'] as String?);
                backgroundColor =
                    _parseColor(attributes['background'] as String?);
                if (attributes['header'] == 1) fontSize = 24.0;
                if (attributes['header'] == 2) fontSize = 20.0;
                if (attributes['list'] != null) {
                  listType = attributes['list'];
                }
              }
              
              if (text.endsWith('\n') && listType != null) {
                if (listType == 'bullet') {
                  text = '• ${text.substring(0, text.length -1)}\n';
                } else if (listType == 'ordered') {
                  text = '$listCounter. ${text.substring(0, text.length -1)}\n';
                  listCounter++;
                }
              } else if (listType == null) {
                listCounter = 1; // Reset counter when not in a list
              }

              textSpans.add(
                TextSpan(
                  text: text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    fontStyle: fontStyle,
                    decoration: textDecoration,
                    color: color,
                    backgroundColor: backgroundColor,
                  ),
                ),
              );
            }
          }

          final richText = TextSpan(children: textSpans);
          final textPainter = TextPainter(
            text: richText,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
          );

          double textPadding = 5.0;
          double availableWidth = rect.width - 2 * textPadding;
          
          if (availableWidth <= 0) continue;

          textPainter.layout(maxWidth: availableWidth);
          
          final textOffset = Offset(
            rect.left + textPadding,
            rect.top + textPadding,
          );

          canvas.save();
          canvas.clipRect(rect);
          textPainter.paint(canvas, textOffset);
          canvas.restore();

        } catch (e) {
          print(
              "Warning: Could not parse Quill Delta, rendering as plain text: $e");
          // Fallback for plain text
          final textPainter = TextPainter(
            text: TextSpan(
              text: canvasObject.textDelta,
              style: const TextStyle(color: Colors.black, fontSize: 14.0),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: rect.width);
          textPainter.paint(canvas, rect.topLeft);
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

        if (canvasObject is TextBoxObject &&
            canvasObject.color == Colors.transparent) {
          // Draw dashed border for transparent text box
          final path = Path()
            ..addRect(rect);
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

  bool _hasCanvasObjectsChanged(
      Map<String, CanvasObject> oldObjects, Map<String, CanvasObject> newObjects) {
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

// Copied from path_drawing package to avoid adding a dependency
Path dashPath(
  Path source, {
  required CircularIntervalList<double> dashArray,
}) {
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