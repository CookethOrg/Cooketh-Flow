import 'package:cookethflow/core/widgets/drawers/dashboard_drawer.dart';
import 'package:cookethflow/core/widgets/project_card.dart';
import 'package:cookethflow/core/widgets/add_project_card.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/screens/workspace.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowmanageProvider>(
      builder: (context, pv, child) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Stack(
            children: [
              DashboardDrawer(),
              Positioned(
                left: 420,
                top: 50,
                child: Text(
                  'Your Projects',
                  style: TextStyle(fontFamily: 'Frederik', fontSize: 40),
                ),
              ),
              Positioned(
                left: 420,
                top: 150,
                child: Row(
                  children: [
                    AddProjectCard(
                      onTap: () {
                        pv.addFlow();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Workspace(
                                  flowId: pv.newFlowId,
                                )));
                      },
                    ),
                    SizedBox(width: 80),
                    ProjectCard(flowId: "1",onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Workspace(flowId: "1"),));
                    },),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
