import 'package:cookethflow/app/theme/colors.dart';
import 'package:cookethflow/presentation/core/alert_dialogues/add_project.dart';
import 'package:cookethflow/presentation/core/drawers/dashboard_drawer.dart';
import 'package:cookethflow/presentation/core/cards/project_card.dart';
import 'package:cookethflow/presentation/core/cards/add_project_card.dart';
import 'package:cookethflow/presentation/dashboard/view_model.dart';
import 'package:cookethflow/app/providers/flowmanage_provider.dart';
import 'package:cookethflow/app/providers/workspace_provider.dart';
import 'package:cookethflow/utilities/enums/app_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  final DashboardViewModel viewModel;
  const DashboardView({super.key, required this.viewModel});

  // Future<void> _createNewProject() async {
  @override
  Widget build(BuildContext context) {
    return Consumer<FlowmanageProvider>(
        builder: (context, flowProvider, child) {
      if (flowProvider.isLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Scaffold(
        backgroundColor: white,
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
                    onRefresh: () => flowProvider.refreshFlowList(),
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
                            style:
                                TextStyle(fontFamily: 'Frederik', fontSize: 40),
                          ),
                          const SizedBox(height: 50),
                          SizedBox(
                            width: constraints.maxWidth - 400,
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
                              itemCount: flowProvider.flowList.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return AddProjectCard(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (context) => AddProject(),
                                    ),
                                  );
                                } else {
                                  final flowId = flowProvider.flowList.keys
                                      .elementAt(index - 1);
                                  return ProjectCard(
                                    flowId: flowId,
                                    onTap: () {
                                      // Initialize the workspace with this flow ID
                                      final workspaceProvider =
                                          Provider.of<WorkspaceProvider>(
                                              context,
                                              listen: false);
                                      workspaceProvider
                                          .initializeWorkspace(flowId);

                                      context.go(
                                          '${AppView.workspace.path}/:$flowId');
                                      // .then((_) =>
                                      //     flowProvider.refreshFlowList());
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
    });
  }
}
