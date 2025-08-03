import 'dart:ui';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ConnectorObject extends CanvasObject {
  static const String type = 'connector';

  final String sourceId;
  final String targetId;
  final Alignment sourceAlignment;
  final Alignment targetAlignment;

  ConnectorObject({
    required super.id,
    required this.sourceId,
    required this.targetId,
    required this.sourceAlignment,
    required this.targetAlignment,
  }) : super(color: Colors.black87, textDelta: null); // Connectors have a fixed color and no text

  @override
  Map<String, dynamic> toJson() {
    return {
      'object_type': type,
      'id': id,
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
    };
  }

  factory ConnectorObject.fromJson(Map<String, dynamic> json) {
    return ConnectorObject(
      id: json['id'],
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
    );
  }

  factory ConnectorObject.createNew({
    required String sourceId,
    required String targetId,
    required Alignment sourceAlignment,
    required Alignment targetAlignment,
  }) {
    return ConnectorObject(
      id: const Uuid().v4(),
      sourceId: sourceId,
      targetId: targetId,
      sourceAlignment: sourceAlignment,
      targetAlignment: targetAlignment,
    );
  }

  // Connectors don't have a direct copyWith like shapes, as they are defined by their connections.
  @override
  ConnectorObject copyWith({
    String? textDelta,
    Color? color,
    String? sourceId,
    String? targetId,
    Alignment? sourceAlignment,
    Alignment? targetAlignment,
  }) {
    return ConnectorObject(
      id: id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      sourceAlignment: sourceAlignment ?? this.sourceAlignment,
      targetAlignment: targetAlignment ?? this.targetAlignment,
    );
  }

  // A connector's bounds are the line between its two points. For hit detection, this is handled differently.
  @override
  Rect getBounds() => Rect.zero;

  // Connectors are not moved directly; they follow their connected objects.
  @override
  ConnectorObject move(Offset delta) => this;

  // Connectors cannot be resized.
  @override
  ConnectorObject resize(Offset newTopLeft, Offset newBottomRight) => this;

  // Hit detection for a line is more complex than for a rect.
  @override
  bool intersectsWith(Offset point) {
    // This requires calculating the distance from the point to the line segment.
    // For simplicity, we'll skip complex hit detection for now.
    // Interactions will be primarily through connection points on shapes.
    return false;
  }
}