import 'package:cookethflow/core/helpers/date_time_helper.dart';
import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/workspace_options_dialog.dart';
import 'package:cookethflow/features/workspace/pages/workspace.dart';
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3D3D3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Center(
                        //   child: Image.asset(
                        //     'assets/images/Frame 400.png',
                        //     fit: BoxFit.cover,
                        //   ),
                        // ),
                        Positioned(
                          top: 12.h,
                          right: 12.w,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => WorkspaceOptionsDialog( // Use dialogContext to pop the dialog
                                    onPressed: () async { // Make onPressed async
                                      Navigator.of(dialogContext).pop(); // Dismiss the dialog first
                                      await provider.deleteWorkspace(workspaceId); // Then delete from DB
                                      // No need to call refreshDashboard here as deleteWorkspace already calls it
                                    },
                                  ),
                                );
                                // Removed .then(context.pop) here
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
                                provider.workspaceList[workspaceId]?.name ??
                                    "Name not fetched",
                                style: TextStyle(
                                  fontFamily: 'Fredrik',
                                  fontSize: 20.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                dth.formatLastEdited(
                                  provider
                                      .workspaceList[workspaceId]
                                      ?.lastEdited,
                                ),
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
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            PhosphorIconsRegular.star,
                            size: 32.sp,
                            color: Colors.black54,
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