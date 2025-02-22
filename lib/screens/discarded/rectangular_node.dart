// import 'package:cookethflow/providers/connection_provider.dart';
import 'package:cookethflow/screens/discarded/node_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RectangularNode extends StatelessWidget {
  final Function(Offset) onDrag;
  final Function(int) onConnect;
  final int nodeIndex;

  const RectangularNode({
    super.key,
    required this.onDrag,
    required this.onConnect,
    required this.nodeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NodeProvider>(
      builder: (context, nodeProvider, child) {
        return GestureDetector(
          onTap: nodeProvider.changeSelected,
          onPanUpdate: (details) {
            onDrag(Offset(
              // During ondrag, there are no more connection box just selection box
              details.globalPosition.dx - (nodeProvider.width / 2),
              details.globalPosition.dy - (nodeProvider.height / 2),
            ));
          },
          // onDoubleTap: () {
          //   onConnect(nodeIndex + 1);
          // },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: nodeProvider.width,
                  height: nodeProvider.height,
                  padding: const EdgeInsets.fromLTRB(15,12,15,18),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD8A8), // Change color when selected
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: nodeProvider.isSelected
                          ? Colors.blue
                          : Colors.black, // Blue border when selected
                      width: nodeProvider.isSelected ? 2.5 : 1.0, // Border width
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: nodeProvider.textController,
                    maxLines: null, // Allows text to wrap
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                        color: Colors.white, fontWeight: FontWeight.bold),
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
              // if(nodeProvider.isHovered) ...nodeProvider.buildConnectionPoints(),
              if (nodeProvider.isSelected) ...nodeProvider.buildSelectionBoxes(),
              // if (nodeProvider.isSelected) ...connectionProvider.connectionPointBuilder(),
            ],
          ),
        );
      },
    );
  }
}
