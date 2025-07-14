import 'package:cookethflow/core/utils/enums.dart';

class Connection {
  String nodeId;
  ConnectionPoint point;
  String connectionContent;
  Connection({
    required this.nodeId,
    required this.point,
    required this.connectionContent,
  });
}

class ConnectionModel {
  String id;
  List<Connection> targetConnections;
  String sourceNodeId;
  ConnectionPoint sourcePoint;
  double thickness;
  ConnectionType type;

  ConnectionModel({
    required this.id,
    required this.targetConnections,
    required this.sourceNodeId,
    required this.sourcePoint,
    required this.thickness,
    required this.type
  });
}
