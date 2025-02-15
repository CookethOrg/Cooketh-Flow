import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ResizeHandle { topLeft, topRight, bottomLeft, bottomRight }

class Node extends StatelessWidget {
  const Node({
    super.key,
    required this.id,
    this.type = NodeType.rectangular,
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
                child: Container(
                  width: wp.getWidth(id),
                  height: wp.getHeight(id),
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD8A8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: wp.nodeList[id]!.isSelected
                          ? Colors.blue
                          : Colors.black,
                      width: wp.nodeList[id]!.isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: wp.nodeList[id]!.data,
                    maxLines: null,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (wp.nodeList[id]!.isSelected) ...[
                _buildResizeHandle(context, ResizeHandle.topLeft, wp),
                _buildResizeHandle(context, ResizeHandle.topRight, wp),
                _buildResizeHandle(context, ResizeHandle.bottomLeft, wp),
                _buildResizeHandle(context, ResizeHandle.bottomRight, wp),
              ],
            ],
          ),
        );
      },
    );
  }
}
