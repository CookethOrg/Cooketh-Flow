enum ConnectionPoint { top, right, bottom, left }

class Connection {
  final String sourceNodeId;
  final String targetNodeId;
  final ConnectionPoint sourcePoint;
  final ConnectionPoint targetPoint;

  Connection(
      {required this.sourceNodeId,
      required this.targetNodeId,
      required this.sourcePoint,
      required this.targetPoint});

  // for serialization
  Map<String, dynamic> toJson() => {
    "sourceNodeId" : sourceNodeId,
    "targetNodeId" : targetNodeId,
    "sourcePoint" : sourcePoint.index,
    "targetPoint" : targetPoint.index
  };

  // For deserialization
  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
    sourceNodeId: json['sourceNodeId'],
    targetNodeId: json['targetNodeId'],
    sourcePoint: ConnectionPoint.values[json['sourcePoint']],
    targetPoint: ConnectionPoint.values[json['targetPoint']],
  );
}
