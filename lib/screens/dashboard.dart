import 'package:cookethflow/core/widgets/drawers/dashboard_drawer.dart';
import 'package:cookethflow/core/widgets/project_card.dart';
import 'package:cookethflow/core/widgets/add_project_card.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/screens/workspace.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAndRefresh();
  }

  Future<void> _initializeAndRefresh() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final flowProvider = Provider.of<FlowmanageProvider>(context, listen: false);
      // Initialize the provider first
      await flowProvider.initialize();
      // Then refresh the flow list
      await flowProvider.refreshFlowList();
    } catch (e) {
      print("Error initializing flow provider: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load projects: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowmanageProvider>(
      builder: (context, flowProvider, child) {
        if (_isLoading) {
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
                                itemCount: flowProvider.flowList.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return AddProjectCard(
                                      onTap: () async {
                                        try {
                                          String newFlowId = await flowProvider.addFlow();
                                          
                                          if (context.mounted) {
                                            // Create a new instance of WorkspaceProvider just for this flow
                                            final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);
                                            // Initialize the workspace with the new flow ID
                                            workspaceProvider.initializeWorkspace(newFlowId);
                                            
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => Workspace(flowId: newFlowId),
                                              ),
                                            ).then((_) => flowProvider.refreshFlowList());
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to create project: $e')),
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    final flowId = flowProvider.flowList.keys.elementAt(index - 1);
                                    return ProjectCard(
                                      flowId: flowId,
                                      onTap: () {
                                        // Initialize the workspace with this flow ID
                                        final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);
                                        workspaceProvider.initializeWorkspace(flowId);
                                        
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Workspace(flowId: flowId),
                                          ),
                                        ).then((_) => flowProvider.refreshFlowList());
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