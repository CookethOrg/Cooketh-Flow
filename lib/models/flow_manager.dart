import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:flutter/material.dart';

class FlowManager {
  String flowName;
  String flowId;
  Map<String, FlowNode> nodes;
  Set<Connection> connections;
  double? scale;
  Offset? position;

  FlowManager(
      {this.flowId = "",
      this.flowName = "New Project",
      Map<String, FlowNode>? nodes,
      Set<Connection>? connections, this.scale = 1.0, Offset? position})
      : nodes = nodes ?? {},
        connections = connections ?? {}, position = position ?? Offset.zero;

  // Add a new node
  void addNode(FlowNode node) {
    nodes[node.id] = node;
  }

  // Remove a node and all its connections
  void removeNode(String nodeId) {
    final node = nodes[nodeId];
    if (node != null) {
      // Remove all connections associated with this node
      connections.removeWhere(
          (conn) => conn.sourceNodeId == nodeId || conn.targetNodeId == nodeId);
      nodes.remove(nodeId);
    }
  }

  // Create a connection between two nodes
  bool connectNodes({
    required String sourceNodeId,
    required String targetNodeId,
    required ConnectionPoint sourcePoint,
    required ConnectionPoint targetPoint,
  }) {
    final sourceNode = nodes[sourceNodeId];
    final targetNode = nodes[targetNodeId];

    if (sourceNode == null || targetNode == null) return false;
    if (!sourceNode.isConnectionPointAvailable(sourcePoint)) return false;
    if (!targetNode.isConnectionPointAvailable(targetPoint)) return false;

    final connection = Connection(
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      sourcePoint: sourcePoint,
      targetPoint: targetPoint,
    );

    connections.add(connection);
    sourceNode.addConnection(connection);
    targetNode.addConnection(connection);
    print("Connection added in flow manager: $connection");
    return true;
  }

  // Export the flow to JSON
  Map<String, dynamic> exportFlow() {
  return {
    'flowName': flowName,
    'nodes': nodes.map((id, node) => MapEntry(id, node.toJson())),
    'connections': connections.map((conn) => conn.toJson()).toList(),
    'scale': scale,
    'position': position != null ? {'dx': position!.dx, 'dy': position!.dy} : null,
  };
}

  // Create a FlowManager from JSON data
  factory FlowManager.fromJson(Map<String, dynamic> json, String flowId) {
  // Extract flow name
  String flowName = json['flowName'] ?? "New Project";
  
  // Create empty collections
  Map<String, FlowNode> nodes = {};
  Set<Connection> connections = {};
  
  // Parse nodes
  if (json['nodes'] != null) {
    (json['nodes'] as Map<String, dynamic>).forEach((id, nodeData) {
      nodes[id] = FlowNode.fromJson(nodeData);
    });
  }
  
  // Parse connections
  if (json['connections'] != null) {
    List<dynamic> connsJson = json['connections'];
    for (var connJson in connsJson) {
      connections.add(Connection.fromJson(connJson));
    }
  }
  
  // Parse scale and position
  double? scale = json['scale']?.toDouble() ?? 1.0;
  Offset? position;
  if (json['position'] != null) {
    position = Offset(
      json['position']['dx']?.toDouble() ?? 0.0,
      json['position']['dy']?.toDouble() ?? 0.0,
    );
  } else {
    position = Offset.zero;
  }
  
  return FlowManager(
    flowId: flowId,
    flowName: flowName,
    nodes: nodes,
    connections: connections,
    scale: scale,
    position: position,
  );
}
}
