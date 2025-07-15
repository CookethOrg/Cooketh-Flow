import 'package:cookethflow/features/models/connection_model.dart';
import 'package:cookethflow/features/models/node_model.dart';
import 'package:flutter/widgets.dart';

class WorkspaceModel {
  String id;
  String owner;
  List<String> editorIdList;
  List<String> viewerIdList;
  Offset lastViewpoint;
  DateTime lastEdited;
  Offset scale;
  List<NodeModel> nodeList;
  List<ConnectionModel> connectionList;

  WorkspaceModel({
    required this.id,
    required this.owner,
    required this.editorIdList,
    required this.viewerIdList,
    required this.lastViewpoint,
    required this.lastEdited,
    required this.scale,
    required this.nodeList,
    required this.connectionList,
  });

  WorkspaceModel copyWith({
    String? id,
    String? owner,
    List<String>? editorIdList,
    List<String>? viewerIdList,
    Offset? lastViewpoint,
    DateTime? lastEdited,
    Offset? scale,
    List<NodeModel>? nodeList,
    List<ConnectionModel>? connectionList,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      editorIdList: editorIdList ?? List.from(this.editorIdList),
      viewerIdList: viewerIdList ?? List.from(this.viewerIdList),
      lastViewpoint: lastViewpoint ?? this.lastViewpoint,
      lastEdited: lastEdited ?? this.lastEdited,
      scale: scale ?? this.scale,
      nodeList: nodeList ?? List.from(this.nodeList),
      connectionList: connectionList ?? List.from(this.connectionList),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'editorIdList': editorIdList,
      'viewerIdList': viewerIdList,
      'lastViewpoint': {'dx': lastViewpoint.dx, 'dy': lastViewpoint.dy},
      'lastEdited': lastEdited.toIso8601String(),
      'scale': {'dx': scale.dx, 'dy': scale.dy},
      'nodeList': nodeList.map((node) => node.toJson()).toList(),
      'connectionList': connectionList.map((conn) => conn.toJson()).toList(),
    };
  }

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      owner: json['owner'] as String,
      editorIdList: List<String>.from(json['editorIdList']),
      viewerIdList: List<String>.from(json['viewerIdList']),
      lastViewpoint: Offset(
        (json['lastViewpoint']['dx'] as num).toDouble(),
        (json['lastViewpoint']['dy'] as num).toDouble(),
      ),
      lastEdited: DateTime.parse(json['lastEdited'] as String),
      scale: Offset(
        (json['scale']['dx'] as num).toDouble(),
        (json['scale']['dy'] as num).toDouble(),
      ),
      nodeList: (json['nodeList'] as List<dynamic>)
          .map((nodeJson) => NodeModel.fromJson(nodeJson as Map<String, dynamic>))
          .toList(),
      connectionList: (json['connectionList'] as List<dynamic>)
          .map((connJson) => ConnectionModel.fromJson(connJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
