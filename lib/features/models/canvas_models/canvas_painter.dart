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

  // FIX: Added robust font size parsing
  double _getFontSize(dynamic size) {
    if (size == null) return 14.0;
    if (size is double) return size;
    if (size is int) return size.toDouble();
    if (size is String) {
      switch (size) {
        case 'small':
          return 10.0;
        case 'large':
          return 18.0;
        case 'huge':
          return 22.0;
        default:
          return double.tryParse(size) ?? 14.0;
      }
    }
    return 14.0;
  }

  TextStyle _getTextStyle(Map<String, dynamic>? attributes) {
    if (attributes == null) return const TextStyle(fontSize: 14.0, color: Colors.black);

    final isLink = attributes['link'] != null;
    final isCode = attributes['code'] == true || attributes['code-block'] == true;

    return TextStyle(
      fontWeight: attributes['bold'] == true ? FontWeight.bold : FontWeight.normal,
      fontStyle: attributes['italic'] == true ? FontStyle.italic : FontStyle.normal,
      // FIX: Handle links correctly
      color: isLink ? Colors.blue : _parseColor(attributes['color'] as String?),
      fontSize: _getFontSize(attributes['size'] ?? (attributes['header'] == 1 ? 'huge' : (attributes['header'] == 2 ? 'large' : null))),
      fontFamily: isCode ? 'monospace' : (attributes['font'] as String?),
      // FIX: Handle links and inline code underline
      decoration: attributes['underline'] == true || isLink ? TextDecoration.underline : TextDecoration.none,
      backgroundColor: attributes['background'] != null
          ? _parseColor(attributes['background'] as String?)
          : (isCode && attributes['code-block'] != true ? Colors.grey.shade300 : null),
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
            ..moveTo(rect.center.dx, rect.top)..lineTo(rect.right, rect.center.dy)..lineTo(rect.center.dx, rect.bottom)..lineTo(rect.left, rect.center.dy)..close();
          canvas.drawPath(path, paint);
        } else if (canvasObject is Triangle) {
          final path = Path()..moveTo(rect.center.dx, rect.top)..lineTo(rect.right, rect.bottom)..lineTo(rect.left, rect.bottom)..close();
          canvas.drawPath(path, paint);
        } else if (canvasObject is InvertedTriangle) {
          final path = Path()..moveTo(rect.left, rect.top)..lineTo(rect.right, rect.top)..lineTo(rect.center.dx, rect.bottom)..close();
          canvas.drawPath(path, paint);
        } else if (canvasObject is Parallelogram) {
          final skew = rect.width * 0.25;
          final path = Path()..moveTo(rect.left + skew, rect.top)..lineTo(rect.right, rect.top)..lineTo(rect.right - skew, rect.bottom)..lineTo(rect.left, rect.bottom)..close();
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

      // FIX: Complete rewrite of the text rendering logic.
      if (canvasObject.textDelta != null && canvasObject.textDelta!.isNotEmpty && !isEditingText) {
        try {
          final List<dynamic> delta = jsonDecode(canvasObject.textDelta!);
          final double textPadding = 8.0;
          double yOffset = rect.top + textPadding;
          
          List<Map<String, dynamic>> currentLineOps = [];
          for (final op in delta) {
            final String text = op['insert'];
            final Map<String, dynamic>? attributes = op['attributes'] as Map<String, dynamic>?;

            if (text.contains('\n')) {
              final lines = text.split('\n');
              for (int i = 0; i < lines.length; i++) {
                if (lines[i].isNotEmpty) {
                  currentLineOps.add({'insert': lines[i], 'attributes': attributes});
                }
                
                if (i < lines.length - 1) { // This is a line break
                  final lineSpans = currentLineOps.map((o) => TextSpan(text: o['insert'], style: _getTextStyle(o['attributes']))).toList();
                  
                  // Check for block attributes on the line break
                  final blockAttributes = attributes ?? {};
                  String prefix = '';
                  double indent = 0;
                  if(blockAttributes['list'] == 'bullet') {
                    prefix = '• ';
                    indent = 10.0;
                  } else if(blockAttributes['list'] == 'ordered') {
                    prefix = '1. '; // This is simplified, a proper implementation needs a counter
                    indent = 10.0;
                  } else if (blockAttributes['blockquote'] == true) {
                    indent = 20.0;
                  }

                  if(blockAttributes['code-block'] == true) {
                      final blockPaint = Paint()..color = Colors.grey.shade200;
                      // This is a simplified block drawing, would need to calculate total block height for a perfect rect
                      // For now, it draws a rect behind each line of the code block.
                      canvas.drawRect(Rect.fromLTWH(rect.left, yOffset, rect.width, 20), blockPaint); // Approximate height
                  }

                  final textPainter = TextPainter(
                    text: TextSpan(children: [TextSpan(text: prefix), ...lineSpans]),
                    textDirection: TextDirection.ltr,
                  );
                  
                  final availableWidth = rect.width - (2 * textPadding) - indent;
                  if (availableWidth > 0) {
                    textPainter.layout(maxWidth: availableWidth);
                    textPainter.paint(canvas, Offset(rect.left + textPadding + indent, yOffset));
                    yOffset += textPainter.height;
                  }
                  currentLineOps = [];
                }
              }
            } else {
              currentLineOps.add(op);
            }
          }

          // Paint any remaining text that didn't end with a newline
          if (currentLineOps.isNotEmpty) {
             final lineSpans = currentLineOps.map((o) => TextSpan(text: o['insert'], style: _getTextStyle(o['attributes']))).toList();
             final textPainter = TextPainter(
                  text: TextSpan(children: lineSpans),
                  textDirection: TextDirection.ltr,
                );
             final availableWidth = rect.width - (2 * textPadding);
             if (availableWidth > 0) {
                textPainter.layout(maxWidth: availableWidth);
                textPainter.paint(canvas, Offset(rect.left + textPadding, yOffset));
             }
          }

        } catch (e) {
          print("Error painting text: $e");
        }
      }


      if (canvasObject.id == currentlySelectedObjectId && !isEditingText) {
        final handlePaint = Paint()..color = Colors.blue..style = PaintingStyle.fill;
        canvas.drawCircle(rect.topLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.topRight, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomRight, handleRadius, handlePaint);

        final borderPaint = Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 2.0;
        if (canvasObject is TextBoxObject && canvasObject.color == Colors.transparent) {
          final path = Path()..addRect(rect);
          canvas.drawPath(dashPath(path, dashArray: CircularIntervalList<double>([5.0, 3.0])), borderPaint);
        } else {
          canvas.drawRect(rect, borderPaint);
        }
      }
    }

    for (final userCursor in userCursors.values) {
      final position = userCursor.position;
      final paint = Paint()..color = userCursor.color..strokeWidth = 2;
      final path = Path()
        ..moveTo(position.dx, position.dy)..lineTo(position.dx, position.dy + 20)..lineTo(position.dx + 5, position.dy + 15)..moveTo(position.dx, position.dy + 20)..lineTo(position.dx + 10, position.dy + 20)..close();
      canvas.drawPath(path, paint);
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