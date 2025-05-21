import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';

class CustomPointer extends StatefulWidget {
  final Function? onNodeHover;
  final Function? onToolbarHover;
  final Function? onDrawerHover;
  final Function(bool)? onClickable;
  
  const CustomPointer({
    super.key, 
    this.onNodeHover, 
    this.onToolbarHover, 
    this.onDrawerHover,
    this.onClickable,
  });

  @override
  _CustomPointerState createState() => _CustomPointerState();
}

class _CustomPointerState extends State<CustomPointer> {
  Offset _cursorPosition = Offset.zero;
  bool _isCursorInside = false;
  bool _isOverInteractive = false;
  bool _isOverNode = false;
  bool _isOverToolbar = false;
  bool _isOverDrawer = false;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, workProvider, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.none, // Hide default cursor
          onHover: (event) {
            setState(() {
              _cursorPosition = event.localPosition;
              _isCursorInside = true;
              
              // Check if we're over any interactive elements
              _checkInteractiveElements(event.position, context, workProvider);
            });
          },
          onExit: (_) {
            setState(() {
              _isCursorInside = false;
              _isOverInteractive = false;
              _isOverNode = false;
              _isOverToolbar = false;
              _isOverDrawer = false;
              
              if (widget.onClickable != null) {
                widget.onClickable!(false);
              }
            });
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: transparent),
              ),

              if (_isCursorInside)
                Positioned(
                  left: _cursorPosition.dx - 15,  // Adjust for center of cursor
                  top: _cursorPosition.dy - 15,   // Adjust for center of cursor
                  child: _buildCursor(),
                ),
            ],
          ),
        );
      }
    );
  }
  
  Widget _buildCursor() {
    // Different cursor appearances based on what we're hovering over
    if (_isOverNode) {
      return Icon(
        PhosphorIconsFill.handPointing,
        size: 30,
        color: Color(0xFFC3B1E1),
      );
    } else if (_isOverToolbar) {
      return Icon(
        PhosphorIconsFill.cursor,
        size: 30,
        color: Color(0xFFFFD8A8),
      );
    } else if (_isOverDrawer) {
      return Icon(
        PhosphorIconsFill.cursor,
        size: 30,
        color: Color(0xFF87CEEB),
      );
    } else if (_isOverInteractive) {
      return Icon(
        PhosphorIconsFill.handPointing,
        size: 30,
        color: Colors.purple,
      );
    } else {
      // Default cursor
      return Icon(
        PhosphorIconsFill.navigationArrow,
        size: 30,
        color: Color(0xFFC3B1E1),
      );
    }
  }
  
  void _checkInteractiveElements(Offset globalPosition, BuildContext context, WorkspaceProvider workProvider) {
    bool wasOverInteractive = _isOverInteractive;
    bool wasOverNode = _isOverNode;
    bool wasOverToolbar = _isOverToolbar;
    bool wasOverDrawer = _isOverDrawer;
    
    _isOverInteractive = false;
    _isOverNode = false;
    _isOverToolbar = false;
    _isOverDrawer = false;
    
    // Check if we're over any node
    final scale = workProvider.scale;
    final position = workProvider.position;
    
    for (var node in workProvider.nodeList.values) {
      final transformedBounds = Rect.fromLTWH(
        node.position.dx * scale + position.dx,
        node.position.dy * scale + position.dy,
        node.size.width * scale,
        node.size.height * scale,
      );

      if (transformedBounds.contains(globalPosition)) {
        _isOverNode = true;
        _isOverInteractive = true;
        break;
      }
    }
    
    // Check if over toolbar
    if (_isToolbarAt(globalPosition, context)) {
      _isOverToolbar = true;
      _isOverInteractive = true;
    }
    
    // Check if over drawer
    if (_isDrawerAt(globalPosition, context, workProvider)) {
      _isOverDrawer = true;
      _isOverInteractive = true;
    }
    
    // Notify parent if interactive state changed
    if (wasOverInteractive != _isOverInteractive && widget.onClickable != null) {
      widget.onClickable!(_isOverInteractive);
    }
    
    // Notify specific hover callbacks
    if (wasOverNode != _isOverNode && widget.onNodeHover != null) {
      widget.onNodeHover!(_isOverNode);
    }
    
    if (wasOverToolbar != _isOverToolbar && widget.onToolbarHover != null) {
      widget.onToolbarHover!(_isOverToolbar);
    }
    
    if (wasOverDrawer != _isOverDrawer && widget.onDrawerHover != null) {
      widget.onDrawerHover!(_isOverDrawer);
    }
  }
  
  bool _isToolbarAt(Offset position, BuildContext context) {
    // Approximate toolbar position (left side of screen, fixed position)
    // You'll need to adjust these values based on your actual toolbar dimensions
    final toolbarRect = Rect.fromLTWH(
      0, 
      80, // Assuming toolbar starts below AppBar
      80, // Approximate toolbar width
      MediaQuery.of(context).size.height - 80 // Full height minus AppBar
    );
    
    return toolbarRect.contains(position);
  }
  
  bool _isDrawerAt(Offset position, BuildContext context, WorkspaceProvider workProvider) {
    // Check if drawer is open
    if (!workProvider.isOpen) return false;
    
    // Approximate drawer position (right side of screen)
    // Adjust based on actual drawer dimensions
    final drawerRect = Rect.fromLTWH(
      MediaQuery.of(context).size.width - 300, // Assuming drawer width is 300
      0,
      300,
      MediaQuery.of(context).size.height
    );
    
    return drawerRect.contains(position);
  }
}