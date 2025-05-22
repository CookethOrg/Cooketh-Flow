import 'package:cookethflow/app/theme/colors.dart';
import 'package:cookethflow/presentation/core/painters/connector_painter.dart';
import 'package:cookethflow/app/providers/workspace_provider.dart';
import 'package:cookethflow/utilities/enums/connection_point.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Connector extends StatelessWidget {
  const Connector({
    super.key,
    this.color,
    this.isSelected,
    required this.con,
    this.isHovered = false,
    this.size = 24.0,
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
          child: CustomPaint(
            painter: ConnectorPainter(
              connectionPoint: con,
              isHovered: isHovered,
              color: color ?? textColor,
            ),
          ),
        );
      },
    );
  }
}
