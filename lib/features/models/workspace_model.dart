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
}
