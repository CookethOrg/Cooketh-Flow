import 'package:cookethflow/core/widgets/painters/connector_painter.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
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
              color: color ?? Colors.black,
            ),
          ),
        );
      },
    );
  }
}