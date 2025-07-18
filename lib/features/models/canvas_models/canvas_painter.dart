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

  CanvasPainter({required this.userCursors, required this.canvasObjects});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw each canvas object
    for (final canvasObject in canvasObjects.values) {
      final paint = Paint()..color = canvasObject.color;
      
      // Determine the correct rectangle bounds, regardless of drag direction
      final rect = (canvasObject is! Circle) 
          ? Rect.fromPoints((canvasObject as dynamic).topLeft, (canvasObject as dynamic).bottomRight)
          : Rect.zero;

      if (canvasObject is Circle) {
        canvas.drawCircle(canvasObject.center, canvasObject.radius, paint);
      } else if (canvasObject is Rectangle) {
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
  bool shouldRepaint(oldPainter) => true;
}
