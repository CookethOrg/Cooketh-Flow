
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:cookethflow/features/dashboard/widgets/project_card.dart';
import 'package:cookethflow/features/dashboard/widgets/start_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class DashboardDesktop extends StatelessWidget {
  const DashboardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    rh.DeviceType deviceType = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer2<DashboardProvider,SupabaseService>(
      builder: (context, provider,supabaseprovider, child) {
        return LayoutBuilder(
          builder:
              (context, constraints) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    height:
                        provider.isDrawerOpen
                            ? constraints.maxHeight
                            : 0.185.sh,
                    width: deviceType == rh.DeviceType.desktop ? 0.24.sw : deviceType == rh.DeviceType.tab ? 0.257.sw : 600.w,
                    child: const DashboardDrawer(),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: const StartProject(),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            // NEW: Conditionally build the main content area
                            child: _buildMainContent(provider,context,supabaseprovider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  // NEW: Helper widget to build content based on the selected tab
  Widget _buildMainContent(DashboardProvider provider,BuildContext context,SupabaseService su) {
    switch (provider.tabIndex) {
      case 2: // Trash Tab
        return Center(
          child: Text(
            'Feature Coming Soon',
            style: TextStyle(
              fontFamily: 'Fredrik',
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: su.isDark?Colors.white: Colors.grey[600],
            ),
          ),
        );
      case 3: // About Us Tab
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
          child: Text(
            "Cooketh Flow is an open-source, powerful visual thinking and unified productivity tool designed for teams and individuals to brainstorm, sketch, and organize ideas effortlessly. Whether you're mapping out ideas, designing user flows, organizing tasks or simply just taking notes, Cooketh Flow provides an intuitive interface for organizing and executing tasks effortlessly.\n\nWith features like customizable nodes and cloud sync with Supabase, Cooketh Flow is built to streamline complex processes and enhance productivity. Developed with Flutter for cross-platform support, it offers a fast, responsive, and visually engaging experience.\n\nAs an open-source project, Cooketh Flow is community-driven and extensible, inviting developers and creators to contribute, innovate, and shape the future of productivity tools.",
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Fredrik',
              fontSize: 18.sp,
              height: 1.6,
              color: su.isDark?Colors.white: Colors.black.withOpacity(0.75),
            ),
          ),
        );
      default: // All and Starred Tabs
        final displayedWorkspaces = provider.displayedWorkspaces;
        
        // Show a message if the "Starred" tab is empty
        if (displayedWorkspaces.isEmpty && provider.tabIndex == 1) {
           return Center(
            child: Text(
              'No starred workspaces yet!',
              style: TextStyle(
                fontFamily: 'Fredrik',
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color:su.isDark?Colors.white: Colors.grey[600],
              ),
            ),
          );
        }
        rh.DeviceType deviceType = rh.ResponsiveLayoutHelper.getDeviceType(context);
        return GridView.builder(
          shrinkWrap: true,
          itemCount: displayedWorkspaces.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20.w,
                mainAxisSpacing: 20.h,
                childAspectRatio: deviceType == rh.DeviceType.desktop ? 4.0/3 :  3.2/ 3,
              ),
          itemBuilder: (context, index) {
            final workspace = displayedWorkspaces[index];
            return ProjectCard(workspaceId: workspace.id,su: su,);
          },
        );
    }
  }
}