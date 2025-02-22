import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Connector extends StatelessWidget {
  const Connector({
    super.key,
    this.color,
    this.isSelected,
    required this.con, // Made required
    this.isHovered = false,
    this.size = 24.0, // Default size
  });

  final Color? color;
  final bool? isSelected;
  final ConnectionPoint con;
  final bool isHovered;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, pv, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Icon(
            _getIcon(), // Call helper function to get the appropriate icon
            color: color ?? Colors.black,
            size: size,
          ),
        );
      },
    );
  }

  /// Helper function to return the correct icon based on `con` and `isHovered`
  IconData _getIcon() {
    switch (con) {
      case ConnectionPoint.top:
        return isHovered ? Icons.arrow_circle_up_outlined : Icons.arrow_upward;
      case ConnectionPoint.bottom:
        return isHovered ? Icons.arrow_circle_down_outlined : Icons.arrow_downward;
      case ConnectionPoint.left:
        return isHovered ? Icons.arrow_circle_left_outlined : Icons.arrow_back;
      case ConnectionPoint.right:
        return isHovered ? Icons.arrow_circle_right_outlined : Icons.arrow_forward;
    }
  }
}
