import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/core/widgets/buttons/export_option_widget.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ExportOptions extends StatelessWidget {
  const ExportOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, workProvider, child) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Export Workspace',
            style:
                TextStyle(fontFamily: 'Frederik', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExportOptionWidget(
                icon: PhosphorIconsRegular.fileCode,
                label: 'Export as JSON',
                onTap: () async {
                  try {
                    await workProvider.exportWorkspace(
                        exportType: ExportType.json);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('JSON file exported successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error exporting JSON: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                  Navigator.pop(context); // Pop after SnackBar
                },
              ),
              const SizedBox(height: 8),
              ExportOptionWidget(
                icon: PhosphorIconsRegular.fileImage,
                label: 'Export as PNG',
                onTap: () async {
                  try {
                    await workProvider.exportWorkspace(
                        exportType: ExportType.png);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PNG file exported successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error exporting PNG: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                  Navigator.pop(context); // Pop after SnackBar
                },
              ),
              const SizedBox(height: 8),
              ExportOptionWidget(
                icon: PhosphorIconsRegular.fileSvg,
                label: 'Export as SVG',
                onTap: () async {
                  try {
                    await workProvider.exportWorkspace(
                        exportType: ExportType.svg);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SVG file exported successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error exporting SVG: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                  Navigator.pop(context); // Pop after SnackBar
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
