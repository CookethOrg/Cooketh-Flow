import 'package:cookethflow/app/theme/colors.dart';
import 'package:cookethflow/data/models/connection.dart';
import 'package:cookethflow/utilities/enums/connection_point.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final ConnectionPoint startPoint;
  final ConnectionPoint endPoint;
  final String sourceNodeId;
  final String targetNodeId;
  final double scale;
  final double cornerRadius;
  final Function(Offset, Connection)? onTap;
  final Connection? connection;

  // Node dimensions
  static const double nodeWidth = 150.0; // Default node width
  static const double nodeHeight = 75.0; // Default node height
  static const double containerPadding = 20.0;

  LinePainter(
      {required this.start,
      required this.end,
      required this.sourceNodeId,
      required this.startPoint,
      required this.targetNodeId,
      required this.endPoint,
      this.scale = 1.0,
      this.cornerRadius = 10.0,
      this.onTap,
      this.connection // Rounded corner radius
      });

  Offset _getConnectionPointOffset(Offset nodePosition, ConnectionPoint point) {
    // Calculate the center of the node without scaling
    final centerX = nodePosition.dx + (nodeWidth / 2) + containerPadding;
    final centerY = nodePosition.dy + (nodeHeight / 2) + containerPadding;

    switch (point) {
      case ConnectionPoint.top:
        return Offset(centerX, nodePosition.dy + containerPadding);
      case ConnectionPoint.right:
        return Offset(
            nodePosition.dx + nodeWidth + (containerPadding * 2), centerY);
      case ConnectionPoint.bottom:
        return Offset(
            centerX, nodePosition.dy + nodeHeight + (containerPadding * 2));
      case ConnectionPoint.left:
        return Offset(nodePosition.dx + containerPadding, centerY);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = textColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Get actual connection point coordinates
    final startOffset = _getConnectionPointOffset(start, startPoint);
    final endOffset = _getConnectionPointOffset(end, endPoint);

    // Create orthogonal path with rounded corners
    final path = Path();
    path.moveTo(startOffset.dx, startOffset.dy);

    // Determine intermediate points for orthogonal routing
    List<Offset> points =
        _createOrthogonalPoints(startOffset, endOffset, startPoint, endPoint);

    // Draw the path with rounded corners
    _drawRoundedOrthogonalPath(
        canvas, path, [startOffset, ...points, endOffset], paint);

    // Draw connection points at start and end
    final pointPaint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startOffset, 4, pointPaint);
    canvas.drawCircle(endOffset, 4, pointPaint);
  }

  List<Offset> _createOrthogonalPoints(Offset start, Offset end,
      ConnectionPoint startPoint, ConnectionPoint endPoint) {
    List<Offset> points = [];

    // Calculate the midpoint between start and end
    double midX = (start.dx + end.dx) / 2;
    double midY = (start.dy + end.dy) / 2;

    // Create different routing patterns based on connection points
    if (_isHorizontal(startPoint) && _isHorizontal(endPoint)) {
      // Horizontal to horizontal connection (e.g., left to right or right to left)
      points.add(Offset(midX, start.dy));
      points.add(Offset(midX, end.dy));
    } else if (_isVertical(startPoint) && _isVertical(endPoint)) {
      // Vertical to vertical connection (e.g., top to bottom or bottom to top)
      points.add(Offset(start.dx, midY));
      points.add(Offset(end.dx, midY));
    } else if (_isHorizontal(startPoint) && _isVertical(endPoint)) {
      // Horizontal to vertical connection
      points.add(Offset(end.dx, start.dy));
    } else if (_isVertical(startPoint) && _isHorizontal(endPoint)) {
      // Vertical to horizontal connection
      points.add(Offset(start.dx, end.dy));
    }

    return points;
  }

  bool _isHorizontal(ConnectionPoint point) {
    return point == ConnectionPoint.left || point == ConnectionPoint.right;
  }

  bool _isVertical(ConnectionPoint point) {
    return point == ConnectionPoint.top || point == ConnectionPoint.bottom;
  }

  void _drawRoundedOrthogonalPath(
      Canvas canvas, Path path, List<Offset> points, Paint paint) {
    if (points.length < 2) return;

    // Begin path at the first point
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 2; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = points[i + 2];

      // Draw line to the point before the corner
      if ((p1.dx == p2.dx && p2.dy == p3.dy) ||
          (p1.dy == p2.dy && p2.dx == p3.dx)) {
        // Determine corner type and draw rounded corner
        if (p1.dx == p2.dx) {
          // Vertical then horizontal
          double yDiff = (p2.dy - p1.dy).abs();
          double xDiff = (p3.dx - p2.dx).abs();

          // Make sure we don't use a radius larger than half the segment length
          double safeYDiff =
              yDiff > 0 ? yDiff : 1.0; // Prevent division by zero
          double safeXDiff =
              xDiff > 0 ? xDiff : 1.0; // Prevent division by zero

          double radius = math.min(cornerRadius, safeYDiff / 2);
          radius = math.min(radius, safeXDiff / 2);

          if (p2.dy > p1.dy) {
            // Going down then horizontal
            path.lineTo(p2.dx, p2.dy - radius);
            if (p3.dx > p2.dx) {
              // Going down then right
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx + radius, p2.dy);
            } else {
              // Going down then left
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx - radius, p2.dy);
            }
          } else {
            // Going up then horizontal
            path.lineTo(p2.dx, p2.dy + radius);
            if (p3.dx > p2.dx) {
              // Going up then right
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx + radius, p2.dy);
            } else {
              // Going up then left
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx - radius, p2.dy);
            }
          }
        } else {
          // Horizontal then vertical
          double xDiff = (p2.dx - p1.dx).abs();
          double yDiff = (p3.dy - p2.dy).abs();

          // Make sure we don't use a radius larger than half the segment length
          double safeXDiff =
              xDiff > 0 ? xDiff : 1.0; // Prevent division by zero
          double safeYDiff =
              yDiff > 0 ? yDiff : 1.0; // Prevent division by zero

          double radius = math.min(cornerRadius, safeXDiff / 2);
          radius = math.min(radius, safeYDiff / 2);

          if (p2.dx > p1.dx) {
            // Going right then vertical
            path.lineTo(p2.dx - radius, p2.dy);
            if (p3.dy > p2.dy) {
              // Going right then down
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx, p2.dy + radius);
            } else {
              // Going right then up
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx, p2.dy - radius);
            }
          } else {
            // Going left then vertical
            path.lineTo(p2.dx + radius, p2.dy);
            if (p3.dy > p2.dy) {
              // Going left then down
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx, p2.dy + radius);
            } else {
              // Going left then up
              path.quadraticBezierTo(p2.dx, p2.dy, p2.dx, p2.dy - radius);
            }
          }
        }
      } else {
        // Just draw a line if it's not a corner
        path.lineTo(p2.dx, p2.dy);
      }
    }

    // Draw the final segment
    if (points.length >= 2) {
      path.lineTo(points[points.length - 1].dx, points[points.length - 1].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.scale != scale ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
