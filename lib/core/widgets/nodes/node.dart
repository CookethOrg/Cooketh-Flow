import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/core/widgets/buttons/connector.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Node extends StatefulWidget {
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

  @override
  State<Node> createState() => _NodeState();
}

class _NodeState extends State<Node> {
  late Offset _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.position;
  }

  @override
  void didUpdateWidget(Node oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _currentPosition = widget.position;
    }
  }

  Widget _buildResizeHandle(
      BuildContext context, ResizeHandle handle, WorkspaceProvider wp) {
    final handleSize = 12.0;
    final containerPadding = 20.0;
    late double left, top;

    final totalWidth = wp.getWidth(widget.id) + (containerPadding * 2);
    final totalHeight = wp.getHeight(widget.id) + (containerPadding * 2);

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
          onPanUpdate: (details) {
            double newWidth = wp.getWidth(widget.id);
            double newHeight = wp.getHeight(widget.id);
            Offset newPosition = _currentPosition;

            final scaleFactor = wp.scale;
            final adjustedDeltaX = details.delta.dx / scaleFactor;
            final adjustedDeltaY = details.delta.dy / scaleFactor;

            switch (handle) {
              case ResizeHandle.topLeft:
                newWidth = wp.getWidth(widget.id) - adjustedDeltaX;
                newHeight = wp.getHeight(widget.id) - adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  newPosition = Offset(
                    _currentPosition.dx + adjustedDeltaX,
                    _currentPosition.dy + adjustedDeltaY,
                  );
                  widget.onResize(Size(newWidth, newHeight));
                  setState(() {
                    _currentPosition = newPosition;
                  });
                }
                break;
              case ResizeHandle.topRight:
                newWidth = wp.getWidth(widget.id) + adjustedDeltaX;
                newHeight = wp.getHeight(widget.id) - adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  newPosition = Offset(
                    _currentPosition.dx,
                    _currentPosition.dy + adjustedDeltaY,
                  );
                  widget.onResize(Size(newWidth, newHeight));
                  setState(() {
                    _currentPosition = newPosition;
                  });
                }
                break;
              case ResizeHandle.bottomLeft:
                newWidth = wp.getWidth(widget.id) - adjustedDeltaX;
                newHeight = wp.getHeight(widget.id) + adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  newPosition = Offset(
                    _currentPosition.dx + adjustedDeltaX,
                    _currentPosition.dy,
                  );
                  widget.onResize(Size(newWidth, newHeight));
                  setState(() {
                    _currentPosition = newPosition;
                  });
                }
                break;
              case ResizeHandle.bottomRight:
                newWidth = wp.getWidth(widget.id) + adjustedDeltaX;
                newHeight = wp.getHeight(widget.id) + adjustedDeltaY;
                if (newWidth >= 150 && newHeight >= 75) {
                  widget.onResize(Size(newWidth, newHeight));
                }
                break;
            }
            widget.onDrag(newPosition);
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

  Widget _buildConnectionPoints(BuildContext context, ConnectionPoint point,
      String id, WorkspaceProvider wp) {
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
          onTap: () => wp.changeSelected(widget.id),
          onPanStart: (details) {
            if (!wp.nodeList[widget.id]!.isSelected) {
              wp.changeSelected(widget.id);
            }
          },
          onPanUpdate: (details) {
            if (!wp.nodeList[widget.id]!.isSelected || wp.isPanning) return;
        
            final scaleFactor = wp.scale;
            final adjustedDelta = details.delta / scaleFactor;
            setState(() {
              _currentPosition += adjustedDelta;
            });
            wp.dragNode(widget.id, _currentPosition);
          },
          onPanEnd: (details) {
            widget.onDrag(_currentPosition);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: wp.buildNode(widget.id, widget.type),
              ),
              if (wp.nodeList[widget.id]!.isSelected) ...[
                _buildResizeHandle(context, ResizeHandle.topLeft, wp),
                _buildResizeHandle(context, ResizeHandle.topRight, wp),
                _buildResizeHandle(context, ResizeHandle.bottomLeft, wp),
                _buildResizeHandle(context, ResizeHandle.bottomRight, wp),
                _buildConnectionPoints(
                    context, ConnectionPoint.top, widget.id, wp),
                _buildConnectionPoints(
                    context, ConnectionPoint.right, widget.id, wp),
                _buildConnectionPoints(
                    context, ConnectionPoint.bottom, widget.id, wp),
                _buildConnectionPoints(
                    context, ConnectionPoint.left, widget.id, wp),
              ]
            ],
          ),
        );
      },
    );
  }
}
