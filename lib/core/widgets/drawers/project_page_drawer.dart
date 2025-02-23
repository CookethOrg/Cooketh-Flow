import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
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
                    : 81,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Column(
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
                                    },
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
                                          color: Colors.black,
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
                              color: Colors.black,
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
                              return ListTile(
                                title: Text(node.data.text),
                              );
                            })
                          ],
                        ),
                      ),
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
