import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Node extends StatelessWidget {
  const Node(
      {super.key,
      required this.id,
      this.type = NodeType.rectangular,
      required this.onDrag,
      required this.position});
  final String id;
  final NodeType type;
  final Function(Offset) onDrag;
  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, wp, child) {
        return GestureDetector(
          onTap: wp.changeSelected,
          onPanUpdate: (details) {
            onDrag(Offset(
              // During ondrag, there are no more connection box just selection box
              details.globalPosition.dx - (wp.width / 2),
              details.globalPosition.dy - (wp.height / 2),
            ));
          },
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  width: wp.width,
                  height: wp.height,
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 18),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD8A8), // Change color when selected
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: wp.isSelected
                          ? Colors.blue
                          : Colors.black, // Blue border when selected
                      width: wp.isSelected ? 2.5 : 1.0, // Border width
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: wp.nodeList[id]!.data,
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
              ),
              if (wp.isSelected) ...wp.buildSelectionBoxes(),
              // if (wp.isSelected) ...con.connectionPointBuilder(),
            ],
          ),
        );
      },
    );
  }
}
