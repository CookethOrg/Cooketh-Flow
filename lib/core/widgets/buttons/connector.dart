import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Connector extends StatelessWidget {
  const Connector({
    super.key,
    this.color,
    this.isSelected,
    required this.con,
    this.isHovered = false,
    this.size = 24.0,
  });

  final Color? color;
  final bool? isSelected;
  final ConnectionPoint con;
  final bool isHovered;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, pv, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: ConnectorPainter(
              connectionPoint: con,
              isHovered: isHovered,
              color: color ?? Colors.black,
            ),
          ),
        );
      },
    );
  }
}

class ConnectorPainter extends CustomPainter {
  final ConnectionPoint connectionPoint;
  final bool isHovered;
  final Color color;

  ConnectorPainter({
    required this.connectionPoint,
    required this.isHovered,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isHovered ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    // final radius = 4.0; // Radius for rounded corners
    // final arrowSize = size.width * 0.4; // Size of the arrow part

    switch (connectionPoint) {
      case ConnectionPoint.top:
        // Start from bottom-left with rounded corner
        path.moveTo(size.width * 0.2, size.height * 0.6);
        // Line to middle-top
        path.lineTo(size.width * 0.5, size.height * 0.2);
        // Line to bottom-right
        path.lineTo(size.width * 0.8, size.height * 0.6);
        
        // Create rounded corners using quadratic bezier curves
        path.quadraticBezierTo(
          size.width * 0.8, size.height * 0.7,
          size.width * 0.7, size.height * 0.7,
        );
        // Bottom line
        path.lineTo(size.width * 0.3, size.height * 0.7);
        // Final rounded corner
        path.quadraticBezierTo(
          size.width * 0.2, size.height * 0.7,
          size.width * 0.2, size.height * 0.6,
        );
        break;

      case ConnectionPoint.bottom:
        // Rotate the top arrow 180 degrees
        canvas.translate(size.width / 2, size.height / 2);
        canvas.rotate(3.14159);
        canvas.translate(-size.width / 2, -size.height / 2);
        
        path.moveTo(size.width * 0.2, size.height * 0.6);
        path.lineTo(size.width * 0.5, size.height * 0.2);
        path.lineTo(size.width * 0.8, size.height * 0.6);
        path.quadraticBezierTo(
          size.width * 0.8, size.height * 0.7,
          size.width * 0.7, size.height * 0.7,
        );
        path.lineTo(size.width * 0.3, size.height * 0.7);
        path.quadraticBezierTo(
          size.width * 0.2, size.height * 0.7,
          size.width * 0.2, size.height * 0.6,
        );
        break;

      case ConnectionPoint.left:
        // Rotate the top arrow 270 degrees
        canvas.translate(size.width / 2, size.height / 2);
        canvas.rotate(-1.5708);
        canvas.translate(-size.width / 2, -size.height / 2);
        
        path.moveTo(size.width * 0.2, size.height * 0.6);
        path.lineTo(size.width * 0.5, size.height * 0.2);
        path.lineTo(size.width * 0.8, size.height * 0.6);
        path.quadraticBezierTo(
          size.width * 0.8, size.height * 0.7,
          size.width * 0.7, size.height * 0.7,
        );
        path.lineTo(size.width * 0.3, size.height * 0.7);
        path.quadraticBezierTo(
          size.width * 0.2, size.height * 0.7,
          size.width * 0.2, size.height * 0.6,
        );
        break;

      case ConnectionPoint.right:
        // Rotate the top arrow 90 degrees
        canvas.translate(size.width / 2, size.height / 2);
        canvas.rotate(1.5708);
        canvas.translate(-size.width / 2, -size.height / 2);
        
        path.moveTo(size.width * 0.2, size.height * 0.6);
        path.lineTo(size.width * 0.5, size.height * 0.2);
        path.lineTo(size.width * 0.8, size.height * 0.6);
        path.quadraticBezierTo(
          size.width * 0.8, size.height * 0.7,
          size.width * 0.7, size.height * 0.7,
        );
        path.lineTo(size.width * 0.3, size.height * 0.7);
        path.quadraticBezierTo(
          size.width * 0.2, size.height * 0.7,
          size.width * 0.2, size.height * 0.6,
        );
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConnectorPainter oldDelegate) {
    return oldDelegate.connectionPoint != connectionPoint ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.color != color;
  }
}
