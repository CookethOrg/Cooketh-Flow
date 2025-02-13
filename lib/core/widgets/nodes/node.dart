import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/node_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Node extends StatelessWidget {
  const Node(
      {super.key,
      required this.id,
      this.data = 'New Node',
      this.type = NodeType.rectangular,
      required this.position});
  final String id;
  final String data;
  final NodeType type;
  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Consumer<NodeProvider>(
      builder: (context, nodeProvider, child) {
        return GestureDetector(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  width: nodeProvider.width,
                  height: nodeProvider.height,
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 18),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD8A8), // Change color when selected
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: nodeProvider.isSelected
                          ? Colors.blue
                          : Colors.black, // Blue border when selected
                      width:
                          nodeProvider.isSelected ? 2.5 : 1.0, // Border width
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: nodeProvider.textController,
                    maxLines: null, // Allows text to wrap
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
