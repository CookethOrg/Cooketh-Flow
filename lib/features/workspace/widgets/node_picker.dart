
import 'package:cookethflow/core/utils/enums.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// The main NodePicker widget as per the design
class NodePicker extends StatelessWidget {
  const NodePicker({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a container to create the card-like appearance
    return Container(
      width: 340, // Fixed width as it appears in the image
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the column wrap its content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with Title and Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nodes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              // The close button inside the picker itself
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF111827), size: 28),
                onPressed: () {
                  // Closes the dialog
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for a shape',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Color(0xFF6B7280)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Grid of shapes
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true, // Important to make GridView work inside a Column
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling in the grid
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: const [
              ShapeWidget(shapeType: ShapeType.square),
              ShapeWidget(shapeType: ShapeType.diamond),
              ShapeWidget(shapeType: ShapeType.roundedSquare),
              ShapeWidget(shapeType: ShapeType.parallelogram),
              ShapeWidget(shapeType: ShapeType.cylinder),
              ShapeWidget(shapeType: ShapeType.circle),
              ShapeWidget(shapeType: ShapeType.triangle),
              ShapeWidget(shapeType: ShapeType.invertedTriangle),
            ],
          ),
        ],
      ),
    );
  }
}


// A widget to display a single shape
class ShapeWidget extends StatelessWidget {
  final ShapeType shapeType;

  const ShapeWidget({super.key, required this.shapeType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.transparent, // transparent background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: CustomPaint(
        painter: ShapePainter(shapeType: shapeType),
      ),
    );
  }
}

// Custom painter to draw the shapes
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;

  ShapePainter({required this.shapeType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black // A nice purple-blue color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final w = size.width;
    final h = size.height;

    switch (shapeType) {
      case ShapeType.square:
        path.addRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8));
        break;
      case ShapeType.diamond:
        path.moveTo(w * 0.5, h * 0.05);
        path.lineTo(w * 0.95, h * 0.5);
        path.lineTo(w * 0.5, h * 0.95);
        path.lineTo(w * 0.05, h * 0.5);
        path.close();
        break;
      case ShapeType.roundedSquare:
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8),
          const Radius.circular(8.0),
        ));
        break;
      case ShapeType.parallelogram:
        path.moveTo(w * 0.1, h * 0.9);
        path.lineTo(w * 0.4, h * 0.1);
        path.lineTo(w * 0.9, h * 0.1);
        path.lineTo(w * 0.6, h * 0.9);
        path.close();
        break;
      case ShapeType.cylinder:
        final rect = Rect.fromCenter(center: Offset(w/2, h/2), width: w * 0.7, height: h * 0.6);
        canvas.drawOval(Rect.fromCenter(center: Offset(rect.center.dx, rect.top), width: rect.width, height: rect.height * 0.3), paint);
        canvas.drawArc(Rect.fromCenter(center: Offset(rect.center.dx, rect.bottom), width: rect.width, height: rect.height * 0.3), 0, math.pi, false, paint);
        canvas.drawLine(rect.topLeft, rect.bottomLeft, paint);
        canvas.drawLine(rect.topRight, rect.bottomRight, paint);
        return; // Return early as we are drawing multiple parts
      case ShapeType.circle:
        path.addOval(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8));
        break;
      case ShapeType.triangle:
        path.moveTo(w * 0.5, h * 0.1);
        path.lineTo(w * 0.9, h * 0.9);
        path.lineTo(w * 0.1, h * 0.9);
        path.close();
        break;
      case ShapeType.invertedTriangle:
        path.moveTo(w * 0.1, h * 0.1);
        path.lineTo(w * 0.9, h * 0.1);
        path.lineTo(w * 0.5, h * 0.9);
        path.close();
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}