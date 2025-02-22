import 'package:flutter/material.dart';

class DiamondNode extends StatelessWidget {
  const DiamondNode({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: 0.7854, // Rotating the container to form a diamond
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.lightGreen.shade200,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Transform.rotate(
            angle: -0.7854, // Rotating back to keep the text upright
            child: const Center(
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
