import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/features/dashboard/widgets/upgrade_plan.dart';
import 'package:cookethflow/features/dashboard/widgets/edit_profile.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    rh.DeviceType device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: device == rh.DeviceType.desktop ? 72.w : 80.w, // Slightly larger for tab
                              height: device == rh.DeviceType.desktop ? 72.h : 80.h,
                              child: Image.asset(
                                'assets/images/pfp.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: device == rh.DeviceType.desktop ? 8.w : 24.w,), // Reduced spacing for tab
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Antara Paul',
                                  style: TextStyle(
                                    fontFamily: 'Fredrik',
                                    fontSize: device == rh.DeviceType.desktop ? 24.sp : 36.sp, // Reduced for tab
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '@antara_paul',
                                  style: TextStyle(
                                    fontFamily: 'Fredrik',
                                    fontSize: device == rh.DeviceType.desktop ? 16.sp : 24.sp, // Reduced for tab
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: device == rh.DeviceType.desktop ? 30.h : 16.h), // Adjusted for tab
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const ProfileSettingsWidget(),
                              );
                            },
                            icon: Icon(
                              PhosphorIcons.pencilSimple(),
                              color: primaryColor,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: device == rh.DeviceType.desktop ? 28.w : 28.w, // Adjusted for tab
                                vertical: device == rh.DeviceType.desktop ? 24.h : 20.h, // Adjusted for tab
                              ),
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: primaryColor),
                              minimumSize: Size(0, device == rh.DeviceType.desktop ? 48.h : 40.h), // Adjusted for tab
                            ),
                            label: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontFamily: 'Fredrik',
                                fontSize: device == rh.DeviceType.desktop ? 16.sp : 24.sp, // Reduced for tab
                                color: primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              PhosphorIcons.signOut(),
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: device == rh.DeviceType.desktop ? 28.w : 28.w, // Adjusted for tab
                                vertical: device == rh.DeviceType.desktop ? 24.h : 20.h, // Adjusted for tab
                              ),
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              backgroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              minimumSize: Size(0, device == rh.DeviceType.desktop ? 48.h : 40.h), // Adjusted for tab
                            ),
                            label: Text(
                              'Log Out',
                              style: TextStyle(
                                fontFamily: 'Fredrik',
                                fontSize: device == rh.DeviceType.desktop ? 16.sp : 24.sp, // Reduced for tab
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: device == rh.DeviceType.desktop ? 15.h : 10.h), // Adjusted for tab
                  Visibility(visible: provider.isDrawerOpen, child: Divider(color: Colors.grey, thickness: 0.5)),
                  // Column for lower items (vertical tabs)
                  Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: provider.tabItems.length,
                      itemBuilder: (context, index) {
                        final isSelected = provider.tabIndex == index;
                        return InkWell(
                          onTap: () {
                            provider.toggleTab(index);
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: device == rh.DeviceType.desktop ? 12.w : 16.w, // Adjusted for tab
                              vertical: device == rh.DeviceType.desktop ? 12.h : 16.h, // Adjusted for tab
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconTheme(
                                  data: IconThemeData(
                                    color: isSelected ? secondaryColors[6] : Colors.black,
                                    size: device == rh.DeviceType.desktop ? 26.sp : 30.sp, // Adjusted for tab
                                  ),
                                  child: provider.tabItems[index]['icon'],
                                ),
                                SizedBox(width: device == rh.DeviceType.desktop ? 12.w : 10.w), // Reduced for tab
                                Text(
                                  provider.tabItems[index]['label'],
                                  style: TextStyle(
                                    fontFamily: 'Fredrik',
                                    fontSize: device == rh.DeviceType.desktop ? 18.sp : 16.sp, // Reduced for tab
                                    color: isSelected ? Colors.blue : Colors.black,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Spacer(),
                  const UpgradeCard()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}