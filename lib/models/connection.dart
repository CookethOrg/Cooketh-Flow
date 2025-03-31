enum ConnectionPoint { top, right, bottom, left }

class ConnectionPointSelection {
  final String nodeId;
  final ConnectionPoint connectionPoint;

  ConnectionPointSelection(this.nodeId, this.connectionPoint);
}

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
        "sourceNodeId": sourceNodeId,
        "targetNodeId": targetNodeId,
        "sourcePoint": sourcePoint
            .index, // Use index instead of name for proper serialization
        "targetPoint": targetPoint
            .index // Use index instead of name for proper serialization
      };

  // For deserialization
  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      sourceNodeId: json['sourceNodeId'],
      targetNodeId: json['targetNodeId'],
      sourcePoint: ConnectionPoint.values[json['sourcePoint']],
      targetPoint: ConnectionPoint.values[json['targetPoint']],
    );
  }

  @override
  String toString() {
    return 'Connection(sourceNodeId: $sourceNodeId, targetNodeId: $targetNodeId, sourcePoint: $sourcePoint, targetPoint: $targetPoint)';
  }

  Connection copy() {
    Connection newCon = Connection(
        sourceNodeId: sourceNodeId,
        targetNodeId: targetNodeId,
        sourcePoint: sourcePoint,
        targetPoint: targetPoint);
    return newCon;
  }

  // For set equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Connection &&
        other.sourceNodeId == sourceNodeId &&
        other.targetNodeId == targetNodeId &&
        other.sourcePoint == sourcePoint &&
        other.targetPoint == targetPoint;
  }

  @override
  int get hashCode =>
      sourceNodeId.hashCode ^
      targetNodeId.hashCode ^
      sourcePoint.hashCode ^
      targetPoint.hashCode;
}
