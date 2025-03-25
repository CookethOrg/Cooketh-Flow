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
    required this.colour,
    required this.onDrag,
    required this.position,
    required this.onResize,
  });

  final String id;
  final NodeType type;
  final Color colour;
  final Function(Offset) onDrag;
  final Function(Size) onResize;
  final Offset position;

  Widget _buildResizeHandle(
      BuildContext context, ResizeHandle handle, WorkspaceProvider wp) {
    final handleSize = 12.0;
    final containerPadding = 20.0;
    late double left, top;

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
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            // Start resizing
          },
          onPanUpdate: (details) {
            double newWidth = wp.getWidth(id);
            double newHeight = wp.getHeight(id);
            Offset newPosition = position;

            // Get the current scale factor
            final scaleFactor = wp.scale;

            // Adjust the deltas by dividing by scale factor
            final adjustedDeltaX = details.delta.dx / scaleFactor;
            final adjustedDeltaY = details.delta.dy / scaleFactor;

            switch (handle) {
              case ResizeHandle.topLeft:
                newWidth = wp.getWidth(id) - adjustedDeltaX;
                newHeight = wp.getHeight(id) - adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  newPosition = Offset(
                    position.dx + adjustedDeltaX,
                    position.dy + adjustedDeltaY,
                  );
                  onDrag(newPosition);
                  onResize(Size(newWidth, newHeight));
                }
                break;
              case ResizeHandle.topRight:
                newWidth = wp.getWidth(id) + adjustedDeltaX;
                newHeight = wp.getHeight(id) - adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  newPosition = Offset(
                    position.dx,
                    position.dy + adjustedDeltaY,
                  );
                  onDrag(newPosition);
                  onResize(Size(newWidth, newHeight));
                }
                break;
              case ResizeHandle.bottomLeft:
                newWidth = wp.getWidth(id) - adjustedDeltaX;
                newHeight = wp.getHeight(id) + adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  newPosition = Offset(
                    position.dx + adjustedDeltaX,
                    position.dy,
                  );
                  onDrag(newPosition);
                  onResize(Size(newWidth, newHeight));
                }
                break;
              case ResizeHandle.bottomRight:
                newWidth = wp.getWidth(id) + adjustedDeltaX;
                newHeight = wp.getHeight(id) + adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  newPosition = position; // No position change needed
                  onDrag(newPosition);
                  onResize(Size(newWidth, newHeight));
                }
                break;
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

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

  // In the _buildConnectionPoints method, update the positioning calculations:
  Widget _buildConnectionPoints(BuildContext context, ConnectionPoint point,
      String id, WorkspaceProvider wp) {
    // Check if the connection point is available
    if (!wp.nodeList[id]!.isConnectionPointAvailable(point)) {
      return const SizedBox.shrink();
    }

    final containerPadding = 20.0;
    final connectionSize = 16.0;
    final touchTargetSize = 32.0;

    final totalWidth = wp.getWidth(id) + (containerPadding * 2);
    final totalHeight = wp.getHeight(id) + (containerPadding * 2);

    late double left, top;
    switch (point) {
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
                wp.selectConnection(id, point);
              },
              child: Container(
                width: touchTargetSize,
                height: touchTargetSize,
                alignment: Alignment.center,
                child: SizedBox(
                  width: connectionSize,
                  height: connectionSize,
                  child: Connector(con: point, isHovered: hover),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, wp, child) {
        return GestureDetector(
          onTap: () => wp.changeSelected(id),
          onPanStart: (details) {
            // Only allow dragging if the node is selected
            if (!wp.nodeList[id]!.isSelected) {
              wp.changeSelected(id); // Select the node on drag start
            }
          },
          onPanUpdate: (details) {
            if (!wp.nodeList[id]!.isSelected) return;

            // Get the current scale factor
            final scaleFactor = wp.scale;
            
            // Calculate the delta in the current coordinate system
            final adjustedDeltaX = details.delta.dx / scaleFactor;
            final adjustedDeltaY = details.delta.dy / scaleFactor;
            
            // Directly add the delta to the node's current position
            onDrag(Offset(
              position.dx + adjustedDeltaX,
              position.dy + adjustedDeltaY,
            ));
          },
          child: Stack(
            clipBehavior: Clip.none,
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