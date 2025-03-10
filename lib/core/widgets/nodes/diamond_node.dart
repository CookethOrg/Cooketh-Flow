import 'package:flutter/material.dart';

class DiamondNode extends StatelessWidget {
  const DiamondNode({super.key, required this.height, required this.width, required this.tcontroller});
  final double width;
  final double height;
  final TextEditingController tcontroller;

  @override
  Widget build(BuildContext context) {
    // Calculate the size to ensure perfect symmetry
    final size = width < height ? width : height;
    
    return Center(
      child: Transform.rotate(
        angle: 0.7854, // 45 degrees in radians
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.lightGreen.shade200,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Transform.rotate(
            angle: -0.7854, // -45 degrees to keep text upright
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
    );
  }
}
