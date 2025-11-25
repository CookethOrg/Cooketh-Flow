import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/dashboard/pages/desktop/short_cut_setting.dart';
import 'package:cookethflow/features/dashboard/pages/mobile/drawer_mobile.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/project_card.dart';
import 'package:cookethflow/features/dashboard/widgets/start_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/utils/enums.dart' as en;

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({super.key});

  @override
  State<DashboardMobile> createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    en.DeviceType deviceType = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer2<DashboardProvider, SupabaseService>(
      builder: (context, provider, suprovider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: EdgeInsets.only(left: 20, right: 16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    suprovider.isDark
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              child: Icon(Icons.menu, size: 30),
                            ),
                          ),
                          Visibility(
                            visible: provider.tabIndex <= 1,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: const StartProject(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Expanded(
                        // NEW: Conditionally build the main content area
                        child: _buildMainContent(provider, suprovider),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isVisible,
                    child: Positioned(
                      top: 90.h,
                      left: 8.w,
                      child: AnimatedContainer(
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 500),
                        height: provider.isDrawerOpen ? 0.8.sh : 0.185.sh,
                        width:
                            deviceType == en.DeviceType.desktop
                                ? 400.w
                                : 0.70.sw,
                        child: const DashboardDrawerMob(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // NEW: Helper widget to build content based on the selected tab
  Widget _buildMainContent(DashboardProvider provider, SupabaseService su) {
    switch (provider.tabIndex) {
      case 2: // Trash Tab
        return Center(
          child: Text(
            'Feature Coming Soon',
            style: TextStyle(
              fontFamily: 'Fredrik',
              fontSize: 45.sp,
              fontWeight: FontWeight.w600,
              color: su.isDark ? Colors.white : Colors.grey[600],
            ),
          ),
        );
      case 3: // About Us Tab
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
          child: Text(
            "Cooketh Flow is an open-source, powerful visual thinking tool designed for teams and individuals to brainstorm, sketch, and organize ideas effortlessly. Whether you're mapping out ideas, designing user flows, or organizing tasks, Cooketh Flow provides an intuitive drag-and-drop interface that makes building and refining workflows effortless.\n\nWith features like customizable nodes and cloud sync with Supabase, Cooketh Flow is built to streamline complex processes and enhance productivity. Developed with Flutter for cross-platform support, it offers a fast, responsive, and visually engaging experience.\n\nAs an open-source project, Cooketh Flow is community-driven and extensible, inviting developers and creators to contribute, innovate, and shape the future of workflow automation.",
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Fredrik',
              fontSize: 40.sp,
              height: 1.6,
              color: su.isDark ? Colors.white : Colors.black.withOpacity(0.75),
            ),
          ),
        );
      case 4:
        return ShortcutSettingsPage();
      default: // All and Starred Tabs
        final displayedWorkspaces = provider.displayedWorkspaces;

        // Show a message if the "Starred" tab is empty
        if (displayedWorkspaces.isEmpty && provider.tabIndex == 1) {
          return Center(
            child: Text(
              'No starred workspaces yet!',
              style: TextStyle(
                fontFamily: 'Fredrik',
                fontSize: 45.sp,
                fontWeight: FontWeight.w600,
                color: su.isDark ? Colors.white : Colors.grey[600],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          itemCount: displayedWorkspaces.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 20.w,
            mainAxisSpacing: 20.h,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, index) {
            final workspace = displayedWorkspaces[index];
            return ProjectCard(workspaceId: workspace.id, su: su);
          },
        );
    }
  }
}
