// lib/features/models/canvas_models/objects/connector_object.dart
import 'dart:ui';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ConnectorObject extends CanvasObject {
  static const String type = 'connector';

  final String sourceId;
  final String targetId;
  final Alignment sourceAlignment;
  final Alignment targetAlignment;
  final double thickness;
  final ConnectionType connectionType;

  ConnectorObject({
    required super.id,
    required super.color,
    required this.sourceId,
    required this.targetId,
    required this.sourceAlignment,
    required this.targetAlignment,
    this.thickness = 2.0,
    this.connectionType = ConnectionType.solid,
  }) : super(textDelta: null);

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
      'color': color.value.toRadixString(16),
      'source_id': sourceId,
      'target_id': targetId,
      'source_alignment': {
        'x': sourceAlignment.x,
        'y': sourceAlignment.y
      },
      'target_alignment': {
        'x': targetAlignment.x,
        'y': targetAlignment.y
      },
      'thickness': thickness,
      'connection_type': connectionType.name,
    };
  }

  factory ConnectorObject.fromJson(Map<String, dynamic> json) {
    return ConnectorObject(
      id: json['id'],
      color: Color(int.parse(json['color'] as String, radix: 16)),
      sourceId: json['source_id'],
      targetId: json['target_id'],
      sourceAlignment: Alignment(
        json['source_alignment']['x'],
        json['source_alignment']['y'],
      ),
      targetAlignment: Alignment(
        json['target_alignment']['x'],
        json['target_alignment']['y'],
      ),
      thickness: json['thickness'] as double? ?? 2.0,
      connectionType: ConnectionType.values.firstWhere(
        (e) => e.name == json['connection_type'],
        orElse: () => ConnectionType.solid,
      ),
    );
  }

  factory ConnectorObject.createNew({
    required String sourceId,
    required String targetId,
    required Alignment sourceAlignment,
    required Alignment targetAlignment,
    Color color = Colors.black87,
    double thickness = 2.0,
    ConnectionType connectionType = ConnectionType.solid,
  }) {
    if (sourceId == targetId) {
      throw StateError('A connector cannot connect to itself.');
    }

    return ConnectorObject(
      id: const Uuid().v4(),
      sourceId: sourceId,
      targetId: targetId,
      sourceAlignment: sourceAlignment,
      targetAlignment: targetAlignment,
      color: color,
      thickness: thickness,
      connectionType: connectionType,
    );
  }

  @override
  ConnectorObject copyWith({
    String? textDelta,
    Color? color,
    String? sourceId,
    String? targetId,
    Alignment? sourceAlignment,
    Alignment? targetAlignment,
    double? thickness,
    ConnectionType? connectionType,
  }) {
    return ConnectorObject(
      id: id,
      color: color ?? this.color,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      sourceAlignment: sourceAlignment ?? this.sourceAlignment,
      targetAlignment: targetAlignment ?? this.targetAlignment,
      thickness: thickness ?? this.thickness,
      connectionType: connectionType ?? this.connectionType,
    );
  }

  @override
  Rect getBounds() => Rect.zero;

  @override
  ConnectorObject move(Offset delta) => this;

  @override
  ConnectorObject resize(Offset newTopLeft, Offset newBottomRight) => this;

  @override
  bool intersectsWith(Offset point) {
    return false;
  }
}
