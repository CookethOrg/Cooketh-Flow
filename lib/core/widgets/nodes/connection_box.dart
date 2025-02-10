import 'package:cookethflow/core/widgets/buttons/connector.dart';
import 'package:flutter/material.dart';

class ConnectionBox extends StatelessWidget {
  const ConnectionBox(
      {super.key,
      required this.top,
      required this.bottom,
      required this.left,
      required this.right});
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: top,
        left: left,
        bottom: bottom,
        right: right,
        child: Connector(
          icon: Icons.arrow_drop_up_outlined,
        ));
  }
}
