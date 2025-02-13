import 'package:cookethflow/models/connection.dart';
import 'package:flutter/material.dart';

enum NodeType { rectangular, parallelogram, diamond, database }

class FlowNode {
  final Offset position;
  final String data;
  final NodeType type;
  final String id;
  final Map<ConnectionPoint, Set<Connection>> connections;

  FlowNode({
    required this.id,
    required this.data,
    required this.type,
    required this.position,
  }) : connections = {
          for (var point in ConnectionPoint.values) point: <Connection>{}
        };

  // Check if a connection point is available
  bool isConnectionPointAvailable(ConnectionPoint point) {
    // You can implement custom logic here for maximum connections per point
    return connections[point]!.isEmpty; // Example: one connection per point
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
        "connections": connections.map((point, conns) => MapEntry(
            point.index.toString(),
            conns.map((conn) => conn.toJson()).toList()))
      };
}
