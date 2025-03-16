import 'package:flutter/material.dart';
import 'dart:math';

class DiamondNode extends StatelessWidget {
  const DiamondNode({
    super.key,
    required this.height,
    required this.width,
    required this.tcontroller,
  });

  final double width;
  final double height;
  final TextEditingController tcontroller;

  @override
  Widget build(BuildContext context) {
    // Get the smallest dimension to maintain symmetry
    final double size = min(width, height);

    // Calculate bounding box dimensions
    final double boundingSize = size * sqrt(2);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Bounding Box (for visualization)
        Container(
          width: boundingSize,
          height: boundingSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 1, style: BorderStyle.solid),
          ),
        ),
        // Rotated Diamond Node
        Transform.rotate(
          angle: pi / 4, // 45 degrees in radians
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.lightGreen.shade200,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Transform.rotate(
              angle: -pi / 4, // -45 degrees to keep text upright
              child: Center(
                child: TextField(
                  controller: tcontroller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
          ),
        ),
      ],
    );
  }
}
