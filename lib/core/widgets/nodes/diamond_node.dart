import 'package:flutter/material.dart';

class DiamondNode extends StatelessWidget {
  const DiamondNode({super.key, required this.height, required this.width, required this.tcontroller});
  final double width;
  final double height;
  final TextEditingController tcontroller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: 0.7854, // Rotating the container to form a diamond
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.lightGreen.shade200,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Transform.rotate(
            angle: -0.7854, // Rotating back to keep the text upright
            child: Center(
              child: TextField(
                controller: tcontroller,
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
