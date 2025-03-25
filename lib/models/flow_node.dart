import 'package:cookethflow/models/connection.dart';
import 'package:flutter/material.dart';

enum NodeType { rectangular, parallelogram, diamond, database }

class FlowNode {
  Offset position;
  final TextEditingController data;
  NodeType type;
  final String id;
  Color colour = Color(0xffFAD7A0);
  bool isSelected;
  final Map<ConnectionPoint, Set<Connection>> connections;
  Size size;

  FlowNode({
    required this.id,
    this.isSelected = false,
    required this.type,
    required this.position,
    this.size = const Size(150, 75), required Color colour
  }) : connections = {
        for (var point in ConnectionPoint.values) point: <Connection>{}
      },
      data = TextEditingController(text: 'Node $id');

  // Check if a connection point is available
  bool isConnectionPointAvailable(ConnectionPoint point) {
    // You can implement custom logic here for maximum connections per point
    return connections[point]!.isEmpty; // Example: one connection per point
  }
  
  FlowNode copy() {
    FlowNode newNode = FlowNode(
      id: id,
      type: type,
      colour: colour,
      position: Offset(position.dx, position.dy),
      size: Size(size.width, size.height),
      isSelected: isSelected,
    );
    newNode.data.text = data.text;
    return newNode;
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
  Map<String, dynamic> toJson() {
    Map<String, dynamic> connectionsJson = {};
    
    connections.forEach((point, conns) {
      connectionsJson[point.index.toString()] = 
          conns.map((conn) => conn.toJson()).toList();
    });
    
    return {
      "id": id,
      "text": data.text,
      "type": type.index,
      "position": {
        "dx": position.dx, 
        "dy": position.dy
      },
      "size": {
        "width": size.width, 
        "height": size.height
      },
      "connections": connectionsJson
    };
  }
  
  // For deserialization
  factory FlowNode.fromJson(Map<String, dynamic> json) {
    FlowNode node = FlowNode(
      id: json["id"],
      type: NodeType.values[json["type"]],
      position: Offset(
        json["position"]["dx"].toDouble(), 
        json["position"]["dy"].toDouble()
      ),
      size: Size(
        json["size"]["width"].toDouble(), 
        json["size"]["height"].toDouble()
      ),
      colour: Color(0xffFAD7A0), // Provide a default or desired color
    );
    
    // Set text content
    if (json["text"] != null) {
      node.data.text = json["text"];
    }
    
    // Add connections if available
    if (json["connections"] != null) {
      Map<String, dynamic> connsJson = json["connections"];
      connsJson.forEach((pointKey, connsData) {
        ConnectionPoint point = ConnectionPoint.values[int.parse(pointKey)];
        List<dynamic> connsList = connsData as List<dynamic>;
        
        for (var connData in connsList) {
          Connection conn = Connection.fromJson(connData);
          node.connections[point]!.add(conn);
        }
      });
    }
    
    return node;
  }

}