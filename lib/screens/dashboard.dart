import 'package:cookethflow/core/services/file_services.dart';
import 'package:cookethflow/core/widgets/drawers/dashboard_drawer.dart';
import 'package:cookethflow/core/widgets/project_card.dart';
import 'package:cookethflow/core/widgets/add_project_card.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/screens/workspace.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
// import 'package:file_picker/file_picker.dart';

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

  void _showAddProjectOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Create Project',
            style: TextStyle(fontFamily: 'Frederik', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProjectOption(
                context: context,
                icon: PhosphorIconsRegular.plus,
                label: 'Start New Project',
                onTap: () async {
                  Navigator.pop(context);
                  _createNewProject();
                },
              ),
              SizedBox(height: 16),
              _buildProjectOption(
                context: context,
                icon: PhosphorIconsRegular.fileArrowDown,
                label: 'Import Existing Project',
                onTap: () async {
                  Navigator.pop(context);
                  _importExistingProject();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Frederik',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewProject() async {
    try {
      final flowProvider = Provider.of<FlowmanageProvider>(context, listen: false);
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create project: $e')),
        );
      }
    }
  }

  Future<void> _importExistingProject() async {
  try {
    // Show a loading indicator while preparing
    setState(() {
      _isLoading = true;
    });
    
    // Use our new file service instead of FilePicker
    final fileServices = FileServices();
    final fileData = await fileServices.pickAndReadJsonFile();
    
    if (fileData == null) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No file selected or file could not be read')),
        );
      }
      return;
    }
    
    final flowProvider = Provider.of<FlowmanageProvider>(context, listen: false);
    
    // Import the workspace
    String newFlowId = await flowProvider.importWorkspace(
      fileData['bytes'],
      fileData['name'],
    );
    
    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });
    
    if (context.mounted) {
      // Create a new instance of WorkspaceProvider just for this flow
      final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);
      // Initialize the workspace with the new flow ID
      workspaceProvider.initializeWorkspace(newFlowId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project imported successfully!')),
      );
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Workspace(flowId: newFlowId),
        ),
      ).then((_) => flowProvider.refreshFlowList());
    }
  } catch (e) {
    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing project: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                                      onTap: () => _showAddProjectOptions(context),
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