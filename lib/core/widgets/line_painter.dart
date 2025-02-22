import 'package:cookethflow/models/connection.dart';
import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final ConnectionPoint startPoint;
  final ConnectionPoint endPoint;
  final String sourceNodeId;
  final String targetNodeId;
  
  // Node dimensions
  static const double nodeWidth = 150.0;  // Default node width
  static const double nodeHeight = 75.0;  // Default node height
  static const double containerPadding = 20.0;

  LinePainter({
    required this.start,
    required this.end,
    required this.sourceNodeId,
    required this.startPoint,
    required this.targetNodeId,
    required this.endPoint,
  });

  Offset _getConnectionPointOffset(Offset nodePosition, ConnectionPoint point) {
    // Calculate the center of the node
    final centerX = nodePosition.dx + (nodeWidth / 2) + containerPadding;
    final centerY = nodePosition.dy + (nodeHeight / 2) + containerPadding;

    switch (point) {
      case ConnectionPoint.top:
        return Offset(centerX, nodePosition.dy + containerPadding);
      case ConnectionPoint.right:
        return Offset(
          nodePosition.dx + nodeWidth + (containerPadding * 2), 
          centerY
        );
      case ConnectionPoint.bottom:
        return Offset(
          centerX,
          nodePosition.dy + nodeHeight + (containerPadding * 2)
        );
      case ConnectionPoint.left:
        return Offset(nodePosition.dx + containerPadding, centerY);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Get actual connection point coordinates
    final startOffset = _getConnectionPointOffset(start, startPoint);
    final endOffset = _getConnectionPointOffset(end, endPoint);

    // Draw curved path between points
    final path = Path();
    path.moveTo(startOffset.dx, startOffset.dy);

    // Calculate control points for the curve
    // final midX = (startOffset.dx + endOffset.dx) / 2;
    // final midY = (startOffset.dy + endOffset.dy) / 2;
    
    double controlPointOffset = 50.0; // Adjust this value to change curve intensity

    switch (startPoint) {
      case ConnectionPoint.right:
        path.cubicTo(
          startOffset.dx + controlPointOffset, startOffset.dy,
          endOffset.dx - controlPointOffset, endOffset.dy,
          endOffset.dx, endOffset.dy,
        );
        break;
      case ConnectionPoint.left:
        path.cubicTo(
          startOffset.dx - controlPointOffset, startOffset.dy,
          endOffset.dx + controlPointOffset, endOffset.dy,
          endOffset.dx, endOffset.dy,
        );
        break;
      case ConnectionPoint.bottom:
        path.cubicTo(
          startOffset.dx, startOffset.dy + controlPointOffset,
          endOffset.dx, endOffset.dy - controlPointOffset,
          endOffset.dx, endOffset.dy,
        );
        break;
      case ConnectionPoint.top:
        path.cubicTo(
          startOffset.dx, startOffset.dy - controlPointOffset,
          endOffset.dx, endOffset.dy + controlPointOffset,
          endOffset.dx, endOffset.dy,
        );
        break;
    }

    // Draw the path
    canvas.drawPath(path, paint);

    // Draw connection points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(startOffset, 4, pointPaint);
    canvas.drawCircle(endOffset, 4, pointPaint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.start != start ||
           oldDelegate.end != end ||
           oldDelegate.startPoint != startPoint ||
           oldDelegate.endPoint != endPoint;
  }
}