import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SelectNode extends StatefulWidget {
  final IconData selectedNode;
  final Function(IconData) onNodeSelected;

  const SelectNode({
    super.key,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  @override
  State<SelectNode> createState() => _SelectNodeWidgetState();
}

class _SelectNodeWidgetState extends State<SelectNode> {
  final List<IconData> nodes = [
    PhosphorIconsRegular.square,
    PhosphorIconsRegular.diamond,
    PhosphorIconsRegular.parallelogram,
    PhosphorIconsRegular.database,
    // PhosphorIconsRegular.circle,
  ];

  IconData? _tempSelectedNode;

  @override
  void initState() {
    super.initState();
    _tempSelectedNode = widget.selectedNode;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<IconData>(
      onSelected: (node) {},
      tooltip: "Change node type",
      padding: EdgeInsets.zero,
      shadowColor: Colors.transparent,
      offset: Offset(0, 50),
      menuPadding: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      color: Colors.white,
      itemBuilder: (context) {
        return [
          PopupMenuItem<IconData>(
            enabled: false,
            child: StatefulBuilder(
              builder: (context, setStatePopup) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: nodes.map((node) {
                    return GestureDetector(
                      onTap: () {
                        setStatePopup(() {
                          _tempSelectedNode = node;
                        });
                        widget.onNodeSelected(node);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          node,
                          size: 28,
                          color: _tempSelectedNode == node ? Colors.blue : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ];
      },
      child: Row(
        children: [
          Icon(_tempSelectedNode, size: 24, color: Colors.black),
          SizedBox(width: 4),
          Icon(PhosphorIconsRegular.caretDown, color: Colors.black, size: 16),
        ],
      ),
    );
  }
}
