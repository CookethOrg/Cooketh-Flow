import 'package:cookethflow/core/utils/enums.dart';
import 'package:flutter/widgets.dart';

class NodeModel {
  String id;
  NodeType nodeType;
  Size size;
  int color;
  String data;
  Offset position;
  List<String> connectionId;

  NodeModel({
    required this.id,
    required this.nodeType,
    this.size = const Size(150, 75),
    this.color = 2,
    required this.data,
    required this.position,
  }) : connectionId = <String>[];

  NodeModel copyWith() {
    NodeModel newNode = NodeModel(
      id: id,
      nodeType: nodeType,
      color: color,
      size: Size(size.width, size.height),
      data: data,
      position: Offset(position.dx, position.dy),
    );
    newNode.connectionId = connectionId;
    return newNode;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nodeType": nodeType.index,
      "data": data,
      "position": {"dx": position.dx, "dy": position.dy},
      "color": color,
      "size": {"width": size.width, "height": size.height},
      "connectionId": connectionId,
    };
  }

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    NodeModel node = NodeModel(
      id: json["id"],
      nodeType: NodeType.values[json["nodeType"]],
      data: json["data"],
      position: Offset(
        json["position"]["dx"].toDouble(),
        json["position"]["dy"].toDouble(),
      ),
      color: json["color"],
      size: Size(
        json["size"]["width"].toDouble(),
        json["size"]["height"].toDouble(),
      ),
    );

    if (json["connectionId"] != null) {
      node.connectionId = List<String>.from(json["connectionId"]);
    }

    return node;
  }
}
