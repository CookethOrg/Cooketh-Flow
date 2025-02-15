import 'package:cookethflow/core/widgets/buttons/connector.dart';
import 'package:flutter/material.dart';

class ConnectionBox extends StatelessWidget {
  const ConnectionBox(
      {super.key,
      required this.icon,
      this.height,
      this.width,
      this.left,
      this.right,
      this.top,
      this.bottom});
  final IconData icon;
  final double? width;
  final double? height;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  // final Offset? offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: (width! / 2) + left!,
        right: (width! / 2) + right!,
        bottom: (height! / 2) + bottom!,
        top: (height! / 2) + top!,
        // left:left!,
        // right: right!,
        // bottom: bottom!,
        // top:  top!,
        child: Container());
  }
}
