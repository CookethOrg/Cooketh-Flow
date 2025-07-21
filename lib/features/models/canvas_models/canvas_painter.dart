import 'dart:math';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/circle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/cylinder_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/diamond_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/inverted_triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/parallelogram_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rectangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rounded_square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/user_cursor.dart';
import 'package:flutter/material.dart';

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
      } else {
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

        // Draw selection border
        final borderPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawRect(rect, borderPaint);
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
    return oldPainter.userCursors != userCursors ||
           oldPainter.canvasObjects != canvasObjects ||
           oldPainter.currentlySelectedObjectId != currentlySelectedObjectId;
  }
}