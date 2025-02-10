import 'package:flutter/material.dart';

class SelectionBox extends StatelessWidget {
  const SelectionBox({super.key, this.height, this.offset, this.width});
  final double? width;
  final double? height;
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: (width! / 2) + offset!.dx,
        top: (height! / 2) + offset!.dy,
        // left: width!/2,
        // top: height!/2,
        child: Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(width: 2.5, color: Colors.blue)),
        ));
  }
}
