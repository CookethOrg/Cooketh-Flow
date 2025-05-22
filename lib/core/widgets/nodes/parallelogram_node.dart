import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/app/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParallelogramNode extends StatelessWidget {
  const ParallelogramNode(
      {super.key,
      required this.height,
      required this.width,
      required this.controller,
      required this.id});
  final String id;
  final double width;
  final double height;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(builder: (context, pv, child) {
      return Center(
        child: Stack(
          children: [
            // Black outline
            ClipPath(
              clipper: ParallelogramClipper(),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            // Inner blue box with text
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(1), // Outline thickness
                child: ClipPath(
                  clipper: ParallelogramClipper(),
                  child: Container(
                    width: 150,
                    height: 70,
                    color: pv.nodeList[id]!.colour,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
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
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
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

class ParallelogramClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double offset = 20; // Slant amount
    Path path = Path()
      ..moveTo(offset, 0) // Top-left slant
      ..lineTo(size.width, 0) // Top-right
      ..lineTo(size.width - offset, size.height) // Bottom-right slant
      ..lineTo(0, size.height) // Bottom-left
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
