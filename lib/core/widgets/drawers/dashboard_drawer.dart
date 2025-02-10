import 'package:cookethflow/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
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
                height: provider.isOpen ? 630 : 81,
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
                            child: provider.isOpen && provider.isEditing
                                ? TextField(
                                    controller: provider.controller,
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
                                  )
                                : GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 9),
                                      child: Text(
                                        provider.getTruncatedTitle(),
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
                            onTap: provider.toggleDrawer,
                            child: Icon(
                              provider.isOpen
                                  ? PhosphorIconsRegular.sidebarSimple
                                  : PhosphorIconsFill.sidebarSimple,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (provider.isOpen)
                      Expanded(
                        child: ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            ListTile(title: Text('Option 1')),
                            ListTile(title: Text('Option 2')),
                            ListTile(title: Text('Option 3')),
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
      },
    );
  }
}
