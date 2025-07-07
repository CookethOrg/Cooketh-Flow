import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardDesktop extends StatelessWidget {
  const DashboardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context,provider,child) {
        return Scaffold(
          // appBar: AppBar(backgroundColor: Color.fromRGBO(248, 248, 248, 1),),
          // drawer: AnimatedContainer(duration: Duration(seconds: 3),child: DashboardDrawer(),),
          body: LayoutBuilder(
            builder:
                (context, constraints) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 1500),
                      width: provider.isDrawerOpen ? 400 : 200,
                      child: provider.isDrawerOpen ? DashboardDrawer() : ElevatedButton(onPressed: provider.toggleDrawer, child: Text('Open')),
                    ),
                  ],
                ),
          ),
        );
      }
    );
  }
}
