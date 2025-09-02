import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/build_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class AddProject extends StatelessWidget {
  const AddProject({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, SupabaseService>(
      builder: (context, provider, suprovider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Create Project',
            style: TextStyle(
              fontFamily: 'Frederik',
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BuildProject(
                icon: PhosphorIconsRegular.plus,
                label: 'Start Blank Project',
                onTap: () async {
                  String output = await provider.createNewProject(context);
                  if (output != 'Workspace created successfully!!') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(output),
                        backgroundColor: Colors.lightGreen,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  context.pop();
                },
                txtColor: suprovider.isDark ? Colors.white : Colors.black,
                borderColor: suprovider.isDark ? Colors.white : Colors.black,
              ),
              SizedBox(height: 16),
              BuildProject(
                icon: PhosphorIconsRegular.fileArrowDown,
                label: 'Import Existing Project',
                onTap: () async {
                  context.pop();
                  provider.importExistingProject(context);
                },
                txtColor: suprovider.isDark ? Colors.white : Colors.black,
                borderColor: suprovider.isDark ? Colors.white : Colors.black,
              ),
            ],
          ),
        );
      },
    );
  }
}
