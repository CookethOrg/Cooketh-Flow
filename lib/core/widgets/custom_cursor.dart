import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomCursor extends StatefulWidget {
  const CustomCursor({super.key});

  @override
  _CustomCursorState createState() => _CustomCursorState();
}

class _CustomCursorState extends State<CustomCursor> {
  Offset _cursorPosition = Offset.zero;
  bool _isCursorInside = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.none, // Hide default cursor
      onHover: (event) {
        setState(() {
          _cursorPosition = event.localPosition;
          _isCursorInside = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isCursorInside = false; 
        });
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.transparent),
          ),

          if (_isCursorInside)
            Positioned(
              left: _cursorPosition.dx, 
              top: _cursorPosition.dy,
              child: Icon(
                PhosphorIconsFill.navigationArrow,
                size: 30,
                color: Color(0xFFC3B1E1),
              ),
            ),
        ],
      ),
    );
  }
}
