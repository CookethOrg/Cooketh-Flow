// lib/features/models/canvas_models/canvas_painter.dart

import 'dart:math';
import 'dart:ui';
import 'dart:convert'; // Import for jsonDecode

import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/circle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/cylinder_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/diamond_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/inverted_triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/parallelogram_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rectangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rounded_square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart'; // NEW: Import TextBoxObject
import 'package:cookethflow/features/models/canvas_models/objects/triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/user_cursor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'; // NEW: Import flutter_quill

class CanvasPainter extends CustomPainter {
  final Map<String, UserCursor> userCursors;
  final Map<String, CanvasObject> canvasObjects;
  final String? currentlySelectedObjectId;
  final double handleRadius;

  CanvasPainter({
    required this.userCursors,
    required this.canvasObjects,
    this.currentlySelectedObjectId,
    this.handleRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw each canvas object
    for (final canvasObject in canvasObjects.values) {
      final paint = Paint()..color = canvasObject.color;

      Rect rect;
      if (canvasObject is Circle) {
        canvas.drawCircle(canvasObject.center, canvasObject.radius, paint);
        rect = Rect.fromCircle(center: canvasObject.center, radius: canvasObject.radius);
      } else if (canvasObject is TextBoxObject) { // NEW: Handle TextBoxObject drawing
        rect = canvasObject.getBounds();
        // For text boxes, we might draw a subtle border if it's transparent,
        // or just let the text render.
        if (canvasObject.color == Colors.transparent) {
          final borderPaint = Paint()
            ..color = Colors.grey.shade400
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawRect(rect, borderPaint);
        } else {
          canvas.drawRect(rect, paint);
        }
      }
      else {
        // For other shapes, use their getBounds() method
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

      // NEW: Draw text content for any object that has it
      if (canvasObject.textDelta != null && canvasObject.textDelta!.isNotEmpty) {
        try {
          final doc = Document.fromJson(jsonDecode(canvasObject.textDelta!));
          final richText = TextSpan(
            children: doc.toDelta().map((op) {
              if (op.isInsert && op.data is String) {
                return TextSpan(
                  text: op.data as String,
                  style: TextStyle(
                    fontSize: (op.attributes?['size'] as double?) ?? 14.0, // Default font size
                    fontWeight: op.attributes?['bold'] == true ? FontWeight.bold : FontWeight.normal,
                    fontStyle: op.attributes?['italic'] == true ? FontStyle.italic : FontStyle.normal,
                    decoration: op.attributes?['underline'] == true ? TextDecoration.underline : TextDecoration.none,
                    color: Color(int.tryParse((op.attributes?['color'] as String?)?.replaceAll('#', '0xff') ?? '', radix: 16) ?? Colors.black.value),
                  ),
                );
              }
              return const TextSpan();
            }).toList(),
          );

          final textPainter = TextPainter(
            text: richText,
            textDirection: TextDirection.ltr, // Assuming LTR for most cases
            maxLines: null, // Allow multiple lines
          );

          // Constrain text to object's bounds.
          // For TextBoxObject, the text fills the box.
          // For other shapes, it can be centered with some padding.
          double textPadding = 5.0; // Small padding inside shapes
          double availableWidth = rect.width - 2 * textPadding;
          double availableHeight = rect.height - 2 * textPadding;

          if (availableWidth <= 0 || availableHeight <= 0) {
            continue; // Skip drawing text if object is too small
          }

          textPainter.layout(maxWidth: availableWidth);

          // Calculate offset to center text vertically and horizontally
          final textOffset = Offset(
            rect.left + textPadding + (availableWidth - textPainter.width) / 2,
            rect.top + textPadding + (availableHeight - textPainter.height) / 2,
          );

          // Save canvas state before clipping, restore after
          canvas.save();
          // Clip text to the object's bounds to prevent overflow
          canvas.clipRect(rect);
          textPainter.paint(canvas, textOffset);
          canvas.restore();

        } catch (e) {
          // Fallback for malformed Quill Delta (or plain text directly saved)
          final textPainter = TextPainter(
            text: TextSpan(
              text: canvasObject.textDelta, // Render as plain text
              style: const TextStyle(color: Colors.black, fontSize: 14.0),
            ),
            textDirection: TextDirection.ltr,
            maxLines: null,
          );

          double textPadding = 5.0;
          double availableWidth = rect.width - 2 * textPadding;
          double availableHeight = rect.height - 2 * textPadding;

          if (availableWidth <= 0 || availableHeight <= 0) {
            continue;
          }

          textPainter.layout(maxWidth: availableWidth);

          final textOffset = Offset(
            rect.left + textPadding + (availableWidth - textPainter.width) / 2,
            rect.top + textPadding + (availableHeight - textPainter.height) / 2,
          );
          canvas.save();
          canvas.clipRect(rect);
          textPainter.paint(canvas, textOffset);
          canvas.restore();
          print("Warning: Could not parse Quill Delta, rendering as plain text: $e");
        }
      }


      // Draw resize handles if this object is currently selected
      if (canvasObject.id == currentlySelectedObjectId) {
        final handlePaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
        
        // Draw corner handles
        canvas.drawCircle(rect.topLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.topRight, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomRight, handleRadius, handlePaint);

        // Draw selection border (dashed for text box if transparent)
        final borderPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        if (canvasObject is TextBoxObject && canvasObject.color == Colors.transparent) {
           // Draw dashed border for transparent text box
          const double dashWidth = 5.0;
          const double dashSpace = 3.0;
          double currentX = rect.left;
          double currentY = rect.top;

          // Top line
          while (currentX < rect.right) {
            canvas.drawLine(
              Offset(currentX, rect.top),
              Offset(min(currentX + dashWidth, rect.right), rect.top),
              borderPaint,
            );
            currentX += dashWidth + dashSpace;
          }
          // Right line
          currentX = rect.right;
          while (currentY < rect.bottom) {
            canvas.drawLine(
              Offset(rect.right, currentY),
              Offset(rect.right, min(currentY + dashWidth, rect.bottom)),
              borderPaint,
            );
            currentY += dashWidth + dashSpace;
          }
          // Bottom line
          currentY = rect.bottom;
          currentX = rect.right;
          while (currentX > rect.left) {
            canvas.drawLine(
              Offset(currentX, rect.bottom),
              Offset(max(currentX - dashWidth, rect.left), rect.bottom),
              borderPaint,
            );
            currentX -= dashWidth + dashSpace;
          }
          // Left line
          currentX = rect.left;
          currentY = rect.bottom;
          while (currentY > rect.top) {
            canvas.drawLine(
              Offset(rect.left, currentY),
              Offset(rect.left, max(currentY - dashWidth, rect.top)),
              borderPaint,
            );
            currentY -= dashWidth + dashSpace;
          }
        } else {
          canvas.drawRect(rect, borderPaint);
        }
      }
    }

    // Draw the cursors
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
    // Only repaint if the data or selection changes significantly
    return oldPainter.userCursors != userCursors ||
           oldPainter.canvasObjects.length != canvasObjects.length ||
           oldPainter.currentlySelectedObjectId != currentlySelectedObjectId ||
           // Deep comparison of canvas objects is expensive, but necessary if text content changes frequently
           _hasCanvasObjectsChanged(oldPainter.canvasObjects, canvasObjects);
  }

  // Helper method for deep comparison of canvas objects
  bool _hasCanvasObjectsChanged(Map<String, CanvasObject> oldObjects, Map<String, CanvasObject> newObjects) {
    if (oldObjects.length != newObjects.length) return true;

    for (final id in newObjects.keys) {
      final newObj = newObjects[id];
      final oldObj = oldObjects[id];

      if (oldObj == null || newObj == null) return true; // Object added/removed

      // Check if ID is different (shouldn't happen for same key)
      if (newObj.id != oldObj.id) return true;

      // Check basic properties
      if (newObj.color != oldObj.color ||
          newObj.getBounds() != oldObj.getBounds()) {
        return true;
      }

      // Check textDelta content
      if (newObj.textDelta != oldObj.textDelta) {
        return true;
      }
      // Add more specific checks if objects have other unique properties that can change.
      // For instance, if circle's radius or center changed.
      // A more robust check might involve comparing their toJson() output.
    }
    return false;
  }
}