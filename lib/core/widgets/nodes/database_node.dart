import 'package:flutter/material.dart';

class DatabaseNode extends StatelessWidget {
  const DatabaseNode({
    super.key,
    required this.height,
    required this.width,
    required this.controller,
  });

  final double height;
  final double width;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(width, height),
          painter: CylinderPainter(),
        ),
        Positioned(
          top: height * 0.3, // Positioning text centrally
          child: SizedBox(
            width: width * 0.8, // Leave some padding
            child: TextField(
              controller: controller,
              maxLines: null,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
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
      ..strokeWidth = 1;

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
