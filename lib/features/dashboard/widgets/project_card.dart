import 'package:cookethflow/core/helpers/date_time_helper.dart';
import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/workspace_options_dialog.dart';
import 'package:cookethflow/features/models/workspace_model.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    DateTimeHelper dth = DateTimeHelper();
    return Consumer2<DashboardProvider, WorkspaceProvider>(
      builder: (context, provider, workspaceProvider, child) {
        // Get the specific workspace model to access its properties
        final WorkspaceModel? workspace = provider.workspaceList[workspaceId];
        if (workspace == null) {
          // Return an empty container or a placeholder if the workspace is not found
          return Container();
        }

        return GestureDetector(
          onTap: () {
            workspaceProvider.setWorkspace(workspaceId);
            context.goNamed(
              RouteName.workspace,
              pathParameters: {'workspace_id': workspaceId},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    // Use the workspace background color for the thumbnail
                    decoration: BoxDecoration(
                      color: workspace.backgroundColor ?? const Color(0xFFD3D3D3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12.h,
                          right: 12.w,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => WorkspaceOptionsDialog(
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();
                                      await provider.deleteWorkspace(workspaceId);
                                    },
                                  ),
                                );
                              },
                              icon: Icon(
                                PhosphorIconsRegular.dotsThree,
                                size: 32.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                workspace.name,
                                style: TextStyle(
                                  fontFamily: 'Fredrik',
                                  fontSize: 20.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                dth.formatLastEdited(workspace.lastEdited),
                                style: TextStyle(
                                  fontFamily: 'Fredrik',
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // UPDATED: Star IconButton
                        IconButton(
                          onPressed: () {
                            // Call the provider method to toggle the star status
                            provider.toggleStar(workspaceId);
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Icon(
                              // Conditionally show filled or regular star
                              workspace.isStarred ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                              // Use a key to help AnimatedSwitcher differentiate between the two icons
                              key: ValueKey<bool>(workspace.isStarred),
                              size: 32.sp,
                              color: workspace.isStarred ? Colors.amber : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}