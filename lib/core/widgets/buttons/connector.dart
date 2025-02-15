import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Connector extends StatelessWidget {
  Connector({super.key, this.color, this.isSelected});
  final Color? color;
  final bool? isSelected;
  // ConnectionPoint? con;
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, pv, child) {
        return SizedBox(
        child: InkWell(
          onHover: pv.setHover,
          onTap: () {},
          child: Icon(
            pv.isHovered
                ? Icons.arrow_circle_up_outlined
                : Icons.arrow_upward,
            color: color ?? Colors.blue,
            // size: 25,
          ),
        ),
      );
      },
    );
  }
}
