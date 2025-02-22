import 'package:flutter/material.dart';

class DatabaseNode extends StatelessWidget {
  const DatabaseNode({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 150),
      painter: CylinderPainter(),
    );
  }
}

class CylinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.purple.shade200
      ..style = PaintingStyle.fill;
    
    final Paint outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double width = size.width;
    final double height = size.height;
    final double ellipseHeight = height * 0.2;
    final double bodyHeight = height - ellipseHeight;

    final Rect rect = Rect.fromLTWH(0, ellipseHeight / 2, width, bodyHeight);
    final RRect roundedRect = RRect.fromRectAndCorners(
      rect,
      bottomLeft: Radius.elliptical(width / 2, ellipseHeight * 0.6),
      bottomRight: Radius.elliptical(width / 2, ellipseHeight * 0.6),
    );

    canvas.drawRRect(roundedRect, paint);
    canvas.drawRRect(roundedRect, outline);

    canvas.drawOval(Rect.fromLTWH(0, 0, width, ellipseHeight), paint);
    canvas.drawOval(Rect.fromLTWH(0, 0, width, ellipseHeight), outline);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
