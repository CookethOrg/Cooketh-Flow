import 'package:cookethflow/core/widgets/buttons/connector.dart';
import 'package:cookethflow/core/widgets/nodes/database_node.dart';
import 'package:cookethflow/core/widgets/nodes/diamond_node.dart';
import 'package:cookethflow/core/widgets/nodes/parallelogram_node.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ResizeHandle { topLeft, topRight, bottomLeft, bottomRight }

class Node extends StatelessWidget {
  const Node({
    super.key,
    required this.id,
    required this.type,
    required this.onDrag,
    required this.position,
    required this.onResize,
  });

  final String id;
  final NodeType type;
  final Function(Offset) onDrag;
  final Function(Size) onResize;
  final Offset position;

// Function to build selection boxes
  Widget _buildResizeHandle(
      BuildContext context, ResizeHandle handle, WorkspaceProvider wp) {
    final handleSize =
        12.0; // Made handle slightly larger for easier interaction
    final containerPadding = 20.0;
    late double left, top;

    // Total width and height including padding
    final totalWidth = wp.getWidth(id) + (containerPadding * 2);
    final totalHeight = wp.getHeight(id) + (containerPadding * 2);

    switch (handle) {
      case ResizeHandle.topLeft:
        left = 0;
        top = 0;
        break;
      case ResizeHandle.topRight:
        left = totalWidth - handleSize;
        top = 0;
        break;
      case ResizeHandle.bottomLeft:
        left = 0;
        top = totalHeight - handleSize;
        break;
      case ResizeHandle.bottomRight:
        left = totalWidth - handleSize;
        top = totalHeight - handleSize;
        break;
    }

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor: _getCursorForHandle(handle),
        child: GestureDetector(
          behavior:
              HitTestBehavior.opaque, // This ensures gestures are captured
          onPanStart: (details) {
            // Prevent the parent drag from interfering
            details.sourceTimeStamp;
          },
          onPanUpdate: (details) {
            double newWidth = wp.getWidth(id);
            double newHeight = wp.getHeight(id);

            switch (handle) {
              case ResizeHandle.topLeft:
                newWidth = wp.getWidth(id) - details.delta.dx;
                newHeight = wp.getHeight(id) - details.delta.dy;
                if (newWidth >= 150 && newHeight >= 75) {
                  onDrag(Offset(
                    position.dx + details.delta.dx,
                    position.dy + details.delta.dy,
                  ));
                  onResize(Size(newWidth, newHeight));
                }
                break;
              case ResizeHandle.topRight:
                newWidth = wp.getWidth(id) + details.delta.dx;
                newHeight = wp.getHeight(id) - details.delta.dy;
                if (newWidth >= 150 && newHeight >= 75) {
                  onDrag(Offset(position.dx, position.dy + details.delta.dy));
                  onResize(Size(newWidth, newHeight));
                }
                break;
              case ResizeHandle.bottomLeft:
                newWidth = wp.getWidth(id) - details.delta.dx;
                newHeight = wp.getHeight(id) + details.delta.dy;
                if (newWidth >= 150 && newHeight >= 75) {
                  onDrag(Offset(position.dx + details.delta.dx, position.dy));
                  onResize(Size(newWidth, newHeight));
                }
                break;
              case ResizeHandle.bottomRight:
                newWidth = wp.getWidth(id) + details.delta.dx;
                newHeight = wp.getHeight(id) + details.delta.dy;
                if (newWidth >= 150 && newHeight >= 75) {
                  onResize(Size(newWidth, newHeight));
                }
                break;
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  // Function to get cursor
  MouseCursor _getCursorForHandle(ResizeHandle handle) {
    switch (handle) {
      case ResizeHandle.topLeft:
        return SystemMouseCursors.resizeUpLeft;
      case ResizeHandle.bottomRight:
        return SystemMouseCursors.resizeDownRight;
      case ResizeHandle.topRight:
        return SystemMouseCursors.resizeUpRight;
      case ResizeHandle.bottomLeft:
        return SystemMouseCursors.resizeDownLeft;
    }
  }

  Widget _buildConnectionPoints(BuildContext context, ConnectionPoint con,
      String id, WorkspaceProvider wp) {
    final containerPadding = 20.0;
    final connectionSize = 16.0;
    final touchTargetSize = 32.0;

    final totalWidth = wp.getWidth(id) + (containerPadding * 2);
    final totalHeight = wp.getHeight(id) + (containerPadding * 2);

    late double left, top;
    switch (con) {
      case ConnectionPoint.top:
        left = (totalWidth - touchTargetSize) / 2;
        top = -touchTargetSize / 2;
        break;
      case ConnectionPoint.right:
        left = totalWidth - touchTargetSize / 2;
        top = (totalHeight - touchTargetSize) / 2;
        break;
      case ConnectionPoint.bottom:
        left = (totalWidth - touchTargetSize) / 2;
        top = totalHeight - touchTargetSize / 2;
        break;
      case ConnectionPoint.left:
        left = -touchTargetSize / 2;
        top = (totalHeight - touchTargetSize) / 2;
        break;
    }

    ValueNotifier<bool> isHovered = ValueNotifier(false);

    return Positioned(
      left: left,
      top: top,
      child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hover, child) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              hitTestBehavior: HitTestBehavior.translucent,
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  print(
                      "Connection point ${con.toString()} of node $id tapped");
                  // Prevent the tap from propagating to the parent
                  // details.handled = true;
                  wp.selectConnection(id, con);
                },
                child: Container(
                  width: touchTargetSize,
                  height: touchTargetSize,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: connectionSize,
                    height: connectionSize,
                    child: Connector(con: con, isHovered: hover),
                  ),
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, wp, child) {
        return GestureDetector(
          onTap: () => wp.changeSelected(id),
          onPanUpdate: (details) {
            // Only handle drag if we're not resizing
            if (!wp.nodeList[id]!.isSelected) return;
            onDrag(Offset(
              details.globalPosition.dx - (wp.getWidth(id) / 2),
              details.globalPosition.dy - (wp.getHeight(id) / 2),
            ));
          },
          child: Stack(
            clipBehavior: Clip.none, // Allow handles to overflow
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: wp.buildNode(id, type),
              ),
              if (wp.nodeList[id]!.isSelected) ...[
                _buildResizeHandle(context, ResizeHandle.topLeft, wp),
                _buildResizeHandle(context, ResizeHandle.topRight, wp),
                _buildResizeHandle(context, ResizeHandle.bottomLeft, wp),
                _buildResizeHandle(context, ResizeHandle.bottomRight, wp),
              ],
              // if(wp.nodeList[id]!.isSelected)...[
              //   wp.buildConnectionPoints(context, ConnectionPoint.top, id),
              //   wp.buildConnectionPoints(context, ConnectionPoint.right, id),
              //   wp.buildConnectionPoints(context, ConnectionPoint.bottom, id),
              //   wp.buildConnectionPoints(context, ConnectionPoint.left, id),
              // ]
              if (wp.nodeList[id]!.isSelected) ...[
                _buildConnectionPoints(context, ConnectionPoint.top, id, wp),
                _buildConnectionPoints(context, ConnectionPoint.right, id, wp),
                _buildConnectionPoints(context, ConnectionPoint.bottom, id, wp),
                _buildConnectionPoints(context, ConnectionPoint.left, id, wp),
              ]
            ],
          ),
        );
      },
    );
  }
}
