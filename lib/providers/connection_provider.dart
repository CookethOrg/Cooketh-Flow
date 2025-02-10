import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/widgets/nodes/connection_box.dart';
import 'package:cookethflow/providers/node_provider.dart';
import 'package:flutter/material.dart';

class ConnectionProvider extends StateHandler {
  ConnectionProvider() : super();
  List<Map<Map<int, int>, Map<int, int>>> connections = [];
  NodeProvider node = NodeProvider(ProviderState.loaded);

  List<Widget> connectionPointBuilder() {
    return [
      ConnectionBox(
        icon: Icons.arrow_drop_up,
        height: node.height,
        width: node.width,
        left: 0,
        right: 0,
        bottom: 0,
        top: -85,
        // offset: Offset(-node.width / 2, -node.height / 2 - 70),
      ), // Top
      ConnectionBox(
        icon: Icons.arrow_drop_down,
        height: node.height,
        width: node.width,
        left: 0,
        right: 0,
        bottom: -85,
        top: 0,
        // offset: Offset(node.width / 2, -node.height / 2),
      ), // Bottom
      ConnectionBox(
        icon: Icons.arrow_left,
        height: node.height,
        width: node.width,
        left: -130,
        right: 0,
        bottom: 0,
        top: 0,
        // offset: Offset(-node.width / 2, node.height / 2),
      ), // left
      ConnectionBox(
        icon: Icons.arrow_right,
        height: node.height,
        width: node.width,
        left: 0,
        right: -130,
        bottom: 0,
        top: 0,
        // offset: Offset(node.width / 2, node.height / 2),
      ), // Right
    ];
  }
}
