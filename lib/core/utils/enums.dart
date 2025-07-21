import 'package:flutter/material.dart';

enum ProviderState { inital, empty, loading, loaded, success, error }

enum NodeType {
  note,
  rectangle,
  square,
  diamond,
  roundedSquare,
  parallelogram,
  cylinder,
  circle,
  triangle,
  invertedTriangle,
}

enum ConnectionPoint { up, down, left, right }

enum ConnectionType { solid, dotted, dashed }

// Enum to define the different shapes
enum ShapeType {
  square,
  diamond,
  roundedSquare,
  parallelogram,
  cylinder,
  circle,
  triangle,
  invertedTriangle,
}


enum DrawMode {
  pointer(iconData: Icons.pan_tool_alt),
  circle(iconData: Icons.circle_outlined),
  rectangle(iconData: Icons.rectangle_outlined),
  square(iconData: Icons.square_outlined),
  diamond(iconData: Icons.diamond_outlined),
  roundedSquare(iconData: Icons.rounded_corner),
  parallelogram(iconData: Icons.square_foot_outlined), // Placeholder
  cylinder(iconData: Icons.view_in_ar_outlined), // Placeholder
  triangle(iconData: Icons.change_history),
  invertedTriangle(iconData: Icons.warning_amber_rounded); // Placeholder

  const DrawMode({required this.iconData});
  final IconData iconData;
}

enum InteractionMode {
  none,
  moving,
  resizingTopLeft,
  resizingTopRight,
  resizingBottomLeft,
  resizingBottomRight,
}