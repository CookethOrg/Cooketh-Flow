import 'package:cookethflow/core/utils/enums.dart';

class Connection {
  String nodeId;
  ConnectionPoint point;
  String? connectionContent;
  Connection({
    required this.nodeId,
    required this.point,
    this.connectionContent,
  });
}

class ConnectionModel {
  String id;
  List<Connection> targetConnections; // data about target nodes
  String sourceNodeId;
  ConnectionPoint sourcePoint;
  double thickness;
  ConnectionType type;

  ConnectionModel({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePoint,
    this.thickness = 1,
    this.type = ConnectionType.solid,
  }) : targetConnections = <Connection>[];

  ConnectionModel copyWith() {
    ConnectionModel newCon = ConnectionModel(
      id: id,
      sourceNodeId: sourceNodeId,
      thickness: thickness,
      type: type,
      sourcePoint: sourcePoint,
    );
    newCon.targetConnections = targetConnections;
    return newCon;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sourceNodeId": sourceNodeId,
      "sourcePoint": sourcePoint.index,
      "thickness": thickness,
      "type": type.index,
      "targetConnections":
          targetConnections
              .map(
                (conn) => {
                  "nodeId": conn.nodeId,
                  "point": conn.point.index,
                  if (conn.connectionContent != null)
                    "content": conn.connectionContent,
                },
              )
              .toList(),
    };
  }

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    final model = ConnectionModel(
      id: json["id"] as String,
      sourceNodeId: json["sourceNodeId"] as String,
      sourcePoint: ConnectionPoint.values[json["sourcePoint"] as int],
      thickness: (json["thickness"] as num).toDouble(),
      type: ConnectionType.values[json["type"] as int],
    );

    if (json["targetConnections"] != null) {
      final connections = json["targetConnections"] as List<dynamic>;
      model.targetConnections =
          connections
              .map(
                (conn) => Connection(
                  nodeId: conn["nodeId"] as String,
                  point: ConnectionPoint.values[conn["point"] as int],
                  connectionContent: conn["content"] as String?,
                ),
              )
              .toList();
    }
    return model;
  }
}
