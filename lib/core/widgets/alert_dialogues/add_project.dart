import 'package:cookethflow/core/widgets/buttons/build_project.dart';
import 'package:cookethflow/app/providers/flowmanage_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class AddProject extends StatelessWidget {
  const AddProject({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowmanageProvider>(builder: (context, provider, child) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Create Project',
          style: TextStyle(fontFamily: 'Frederik', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BuildProject(
              icon: PhosphorIconsRegular.plus,
              label: 'Start New Project',
              onTap: () async {
                context.pop();
                provider.createNewProject(context);
              },
            ),
            SizedBox(height: 16),
            BuildProject(
              icon: PhosphorIconsRegular.fileArrowDown,
              label: 'Import Existing Project',
              onTap: () async {
                context.pop();
                provider.importExistingProject(context);
              },
            ),
          ],
        ),
      );
    });
  }
}
