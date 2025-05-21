import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DeleteWorkspace extends StatelessWidget {
  final String flowId;
  const DeleteWorkspace({super.key, required this.flowId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowmanageProvider>(
        builder: (context, flowProvider, child) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Workspace',
          style: TextStyle(fontFamily: 'Frederik', fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this workspace? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Frederik'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await flowProvider.deleteWorkspace(flowId);

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Workspace deleted successfully')));

                context.pop(); // Return to dashboard
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error deleting workspace: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ));
              }
              context.pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    });
  }
}
