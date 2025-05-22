import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/app/providers/workspace_provider.dart';
import 'package:cookethflow/utilities/enums/node_type.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class FloatingDrawer extends StatefulWidget {
  const FloatingDrawer({super.key, required this.flowId});
  final String flowId;

  @override
  State<FloatingDrawer> createState() => _FloatingDrawerState();
}

class _FloatingDrawerState extends State<FloatingDrawer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(builder: (context, pv, child) {
      return Stack(
        children: [
          // Main Floating Drawer
          AnimatedPositioned(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            top: 24,
            left: 24,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: 250,
                height: pv.isOpen
                    ? 3.5 * (MediaQuery.of(context).size.height / 4)
                    : 91,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textColor, width: 1),
                ),
                child: Column(
                  // mainAxisAlignment: pv.isOpen ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: pv.isOpen && pv.isEditing
                                ? TextField(
                                    controller: pv.flowNameController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    autofocus: true,
                                    onSubmitted: (_) {
                                      pv.onSubmit();
                                      print('onsubmit called');
                                    },
                                  )
                                : pv.isOpen
                                    ? MouseRegion(
                                        cursor: SystemMouseCursors.text,
                                        onEnter: (event) => pv.setHovered(true),
                                        onExit: (event) => pv.setHovered(false),
                                        child: GestureDetector(
                                          onDoubleTap: () {
                                            if (pv.isOpen) {
                                              pv.setEdit();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 9),
                                            child: Text(
                                              pv.getTruncatedTitle(),
                                              style: TextStyle(
                                                fontFamily: 'Frederik',
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: pv.isHovered
                                                    ? const Color.fromARGB(
                                                        255, 81, 81, 81)
                                                    : textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onDoubleTap: () {
                                          if (pv.isOpen) {
                                            pv.setEdit();
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 9),
                                          child: Text(
                                            pv.getTruncatedTitle(),
                                            style: TextStyle(
                                              fontFamily: 'Frederik',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: pv.isHovered
                                                  ? const Color.fromARGB(
                                                      255, 61, 61, 61)
                                                  : textColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                          ),
                          SizedBox(width: 12),
                          GestureDetector(
                            onTap: pv.toggleDrawer,
                            child: Icon(
                              pv.isOpen
                                  ? PhosphorIconsRegular.sidebarSimple
                                  : PhosphorIconsFill.sidebarSimple,
                              color: textColor,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pv.isOpen)
                      Expanded(
                        child: ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            ...pv.nodeList.entries.map((entry) {
                              var id = entry.key;
                              var node = entry.value;
                              var type = node.type;
                              IconData getIcon(NodeType type) {
                                if (type == NodeType.rectangular) {
                                  return PhosphorIconsRegular.square;
                                } else if (type == NodeType.diamond) {
                                  return PhosphorIconsRegular.diamond;
                                } else if (type == NodeType.database) {
                                  return PhosphorIconsRegular.database;
                                }
                                return PhosphorIconsRegular.parallelogram;
                              }

                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: pv.nodeList[id]!.isSelected
                                      ? Colors.blue.shade50
                                      : white,
                                  border: Border.all(
                                      color: pv.nodeList[id]!.isSelected
                                          ? Colors.blue
                                          : textColor,
                                      width:
                                          pv.nodeList[id]!.isSelected ? 2 : 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  // tileColor: Colors.red,
                                  onTap: () => pv.changeSelected(id),
                                  leading: Icon(
                                    getIcon(type),
                                    color: pv.nodeList[id]!.isSelected
                                        ? Colors.blue
                                        : textColor,
                                  ),
                                  title: TextField(
                                    style: TextStyle(
                                        color: pv.nodeList[id]!.isSelected
                                            ? Colors.blue
                                            : textColor),
                                    controller: pv.nodeList[id]!.data,
                                    onSubmitted: (value) =>
                                        pv.updateFlowManager(),
                                    showCursor: true,
                                    decoration: InputDecoration(
                                        border: InputBorder.none),
                                  ),
                                ),
                              );
                            })
                          ],
                        ),
                      ),
                    if (pv.isOpen)
                      SizedBox(
                        height: 10,
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
