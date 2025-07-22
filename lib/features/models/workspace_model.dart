// import 'package:cookethflow/features/models/connection_model.dart';
// import 'package:cookethflow/features/models/node_model.dart';

class WorkspaceModel {
  String id;
  String owner;
  String name;
  List<String> editorIdList;
  List<String> viewerIdList;
  DateTime? lastEdited;
  // List<NodeModel> nodeList;
  // List<ConnectionModel> connectionList;

  WorkspaceModel({
    required this.id,
    required this.owner,
    required this.name,
    required this.editorIdList,
    required this.viewerIdList,
    required this.lastEdited,
    // this.nodeList = const [],
    // this.connectionList = const [],
  });

  WorkspaceModel copyWith({
    String? id,
    String? owner,
    String? name,
    List<String>? editorIdList,
    List<String>? viewerIdList,
    DateTime? lastEdited,
    // List<NodeModel>? nodeList,
    // List<ConnectionModel>? connectionList,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      editorIdList: editorIdList ?? List.from(this.editorIdList),
      viewerIdList: viewerIdList ?? List.from(this.viewerIdList),
      lastEdited: lastEdited ?? this.lastEdited,
      // nodeList: nodeList ?? List.from(this.nodeList),
      // connectionList: connectionList ?? List.from(this.connectionList),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'name': name,
      'editorIdList': editorIdList,
      'viewerIdList': viewerIdList,
      'lastEdited': lastEdited?.toIso8601String(),
      // 'nodeList': nodeList.map((node) => node.toJson()).toList(),
      // 'connectionList': connectionList.map((conn) => conn.toJson()).toList(),
    };
  }

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      owner: json['owner'] as String,
      name: json['name'] as String,
      editorIdList: List<String>.from(json['editorIdList']),
      viewerIdList: List<String>.from(json['viewerIdList']),
      lastEdited: DateTime.parse(json['lastEdited'] as String),
      // nodeList:
      //     (json['nodeList'] as List<dynamic>)
      //         .map(
      //           (nodeJson) =>
      //               NodeModel.fromJson(nodeJson as Map<String, dynamic>),
      //         )
      //         .toList(),
      // connectionList:
      //     (json['connectionList'] as List<dynamic>)
      //         .map(
      //           (connJson) =>
      //               ConnectionModel.fromJson(connJson as Map<String, dynamic>),
      //         )
      //         .toList(),
    );
  }
}
