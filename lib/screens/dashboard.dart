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
        if (pv.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 400,
                    height: constraints.maxHeight,
                    child: const DashboardDrawer(),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => pv.refreshFlowList(),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Projects',
                              style: TextStyle(
                                  fontFamily: 'Frederik', fontSize: 40),
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              width: constraints.maxWidth - 440,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 30,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: pv.flowList.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return AddProjectCard(
                                      onTap: () async {
                                        await pv.addFlow();
                                        if (context.mounted) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => Workspace(
                                                  flowId: pv.newFlowId),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    final flowId =
                                        pv.flowList.keys.elementAt(index - 1);
                                    return ProjectCard(
                                      flowId: flowId,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Workspace(flowId: flowId),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
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
          ),
        );
      },
    );
  }
}
