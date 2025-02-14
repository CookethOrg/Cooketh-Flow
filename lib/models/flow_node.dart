import 'package:cookethflow/models/connection.dart';
import 'package:flutter/material.dart';

enum NodeType { rectangular, parallelogram, diamond, database }

class FlowNode {
  Offset position;
  final TextEditingController data;
  final NodeType type;
  final String id;
  bool isSelected;
  final Map<ConnectionPoint, Set<Connection>> connections;
  Size size;

  FlowNode({
    required this.id,
    this.isSelected = false,
    required this.type,
    required this.position,
    this.size = const Size(150, 75)
  })  : connections = {
          for (var point in ConnectionPoint.values) point: <Connection>{}
        },
        data = TextEditingController(text: 'Node $id');

  // Check if a connection point is available
  bool isConnectionPointAvailable(ConnectionPoint point) {
    // You can implement custom logic here for maximum connections per point
    return connections[point]!.isEmpty; // Example: one connection per point
  }

  Rect get bounds {
    // Add padding to account for the resize handles
    const padding = 20.0;
    return Rect.fromLTWH(
      position.dx - padding,
      position.dy - padding,
      size.width + (padding * 2),
      size.height + (padding * 2)
    );
  }

  void addConnection(Connection connection) {
    if (connection.sourceNodeId == id) {
      connections[connection.sourcePoint]!.add(connection);
    } else if (connection.targetNodeId == id) {
      connections[connection.targetPoint]!.add(connection);
    }
  }

  void removeConnection(Connection connection) {
    if (connection.sourceNodeId == id) {
      connections[connection.sourcePoint]!.remove(connection);
    } else if (connection.targetNodeId == id) {
      connections[connection.targetPoint]!.remove(connection);
    }
  }

  // For serialization
  Map<String, dynamic> toJson() => {
        "id": id,
        "data": data,
        "type": type,
        "position": position,
        "size" : size,
        "connections": connections.map((point, conns) => MapEntry(
            point.index.toString(),
            conns.map((conn) => conn.toJson()).toList()))
      };
}
