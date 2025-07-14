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
    required this.size,
    required this.color,
    required this.data,
    required this.position,
    required this.connectionId,
  });
}
