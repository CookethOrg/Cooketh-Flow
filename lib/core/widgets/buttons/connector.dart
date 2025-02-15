import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Connector extends StatelessWidget {
  const Connector({
    super.key, 
    this.color, 
    this.isSelected,
    this.size = 24.0,  // Added default size
  });

  final Color? color;
  final bool? isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, pv, child) {
        return MouseRegion(  // Added MouseRegion for better hover detection
          onEnter: (_) => pv.setHover(true),
          onExit: (_) => pv.setHover(false),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              pv.isHovered 
                ? Icons.arrow_circle_up_outlined
                : Icons.arrow_upward,
              color: color ?? Colors.black,
              size: size,
            ),
          ),
        );
      },
    );
  }
}