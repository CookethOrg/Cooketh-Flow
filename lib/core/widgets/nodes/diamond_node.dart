import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiamondNode extends StatelessWidget {
  const DiamondNode({
    super.key,
    required this.id,
    required this.height,
    required this.width,
    required this.tcontroller,
  });

  final String id;
  final double width;
  final double height;
  final TextEditingController tcontroller;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(builder: (context, pv, child) {
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Diamond shape with border
            CustomPaint(
              size: Size(width, height),
              painter: DiamondPainter(
                fillColor:
                    pv.nodeList[id]!.colour,
                borderColor: textColor,
                borderWidth: 1.0,
              ),
            ),

            // Text field centered in the diamond
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width * 0.65,
                  maxHeight: height * 0.65,
                ),
                child: TextField(
                  controller: tcontroller,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontStyle: pv.nodeList[id]!.isItalic
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontWeight: pv.nodeList[id]!.isBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    decoration: TextDecoration.combine([
                          if (pv.nodeList[id]!.isUnderlined)
                            TextDecoration.underline,
                          if (pv.nodeList[id]!.isStrikeThrough)
                            TextDecoration.lineThrough
                        ]),
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class DiamondPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  DiamondPainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Define the four points of the diamond based on current size
    final points = [
      Offset(width / 2, 0), // Top point
      Offset(width, height / 2), // Right point
      Offset(width / 2, height), // Bottom point
      Offset(0, height / 2), // Left point
    ];

    // Create the path
    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    path.lineTo(points[1].dx, points[1].dy);
    path.lineTo(points[2].dx, points[2].dy);
    path.lineTo(points[3].dx, points[3].dy);
    path.close();

    // Fill paint
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Border paint
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw the diamond
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(DiamondPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
