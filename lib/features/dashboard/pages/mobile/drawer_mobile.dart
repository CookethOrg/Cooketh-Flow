import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/features/dashboard/widgets/upgrade_plan.dart';
import 'package:cookethflow/features/dashboard/widgets/edit_profile.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For network images
import 'package:cookethflow/core/utils/enums.dart' as en;

class DashboardDrawerMob extends StatelessWidget {
  const DashboardDrawerMob({super.key});

  @override
  Widget build(BuildContext context) {
    en.DeviceType device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer2<DashboardProvider, SupabaseService>(
      // Consume both providers
      builder: (context, dashboardProvider, supabaseService, child) {
        // Access both here
        final currentUser =
            supabaseService.currentUser; // Get current user data

        // Default values if user data is not yet loaded or is null
        final String displayName = currentUser?.name ?? 'Guest User';
        final String displayUsername = currentUser?.username ?? '@guest';
        final String displayAvatarUrl =
            currentUser?.avatarUrl ?? ''; // Use empty string if null

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(
              color:
                  supabaseService.isDark
                      ? Colors.grey.shade700
                      : const Color(0xFFD9D9D9),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width:
                                device == en.DeviceType.desktop ? 72.w : 190.w,
                            height:
                                device == en.DeviceType.desktop ? 72.h : 80.h,
                            child:
                                displayAvatarUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                      imageUrl: displayAvatarUrl,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) =>
                                              const CircularProgressIndicator(), // Loading indicator
                                      errorWidget:
                                          (context, url, error) => Image.asset(
                                            supabaseService.defaultPfpPath,
                                            fit: BoxFit.cover,
                                          ), // Fallback to default asset
                                    )
                                    : Image.asset(
                                      supabaseService.defaultPfpPath,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                        SizedBox(
                          width: device == en.DeviceType.desktop ? 8.w : 30.w,
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontFamily: 'Frederik',
                                  fontSize:
                                      device == en.DeviceType.desktop
                                          ? 24.sp
                                          : 75.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                displayUsername,
                                style: TextStyle(
                                  fontFamily: 'Frederik',
                                  fontSize:
                                      device == en.DeviceType.desktop
                                          ? 16.sp
                                          : 58.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => const ProfileSettingsWidget(),
                            );
                          },
                          icon: Icon(
                            PhosphorIcons.pencilSimple(),
                            color: primaryColor,
                            size: 50.sp,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  device == en.DeviceType.desktop ? 28.w : 65.w,
                              vertical:
                                  device == en.DeviceType.desktop ? 24.h : 20.h,
                            ),
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            backgroundColor: Theme.of(context).cardColor,
                            side: BorderSide(color: primaryColor),
                            minimumSize: Size(
                              0,
                              device == en.DeviceType.desktop ? 48.h : 40.h,
                            ),
                          ),
                          label: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontFamily: 'Fredrik',
                              fontSize:
                                  device == en.DeviceType.desktop
                                      ? 16.sp
                                      : 45.sp,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await supabaseService
                                .logout(); // Call logout from SupabaseService
                          },
                          icon: Icon(
                            PhosphorIcons.signOut(),
                            color: Colors.white,
                            size: 50.sp,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  device == en.DeviceType.desktop ? 28.w : 65.w,
                              vertical:
                                  device == en.DeviceType.desktop ? 24.h : 20.h,
                            ),
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            backgroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            minimumSize: Size(
                              0,
                              device == en.DeviceType.desktop ? 48.h : 40.h,
                            ),
                          ),
                          label: Text(
                            'Log Out',
                            style: TextStyle(
                              fontFamily: 'Fredrik',
                              fontSize:
                                  device == en.DeviceType.desktop
                                      ? 16.sp
                                      : 45.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: device == en.DeviceType.desktop ? 15.h : 10.h),
                Visibility(
                  visible: dashboardProvider.isDrawerOpen,
                  child: Divider(color: Colors.grey, thickness: 0.5),
                ),
                // Column for lower items (vertical tabs)
                Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: dashboardProvider.tabItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = dashboardProvider.tabIndex == index;
                      return InkWell(
                        onTap: () {
                          dashboardProvider.toggleTab(index);
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 0.8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                device == en.DeviceType.desktop ? 12.w : 16.w,
                            vertical:
                                device == en.DeviceType.desktop ? 12.h : 10.h,
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
                                  color:
                                      isSelected
                                          ? secondaryColors[6]
                                          : supabaseService.isDark
                                          ? Colors.white
                                          : Colors.black,
                                  size:
                                      device == en.DeviceType.desktop
                                          ? 26.sp
                                          : 100.sp,
                                ),
                                child:
                                    dashboardProvider.tabItems[index]['icon'],
                              ),
                              SizedBox(
                                width:
                                    device == en.DeviceType.desktop
                                        ? 12.w
                                        : 10.w,
                              ),
                              Text(
                                dashboardProvider.tabItems[index]['label'],
                                style: TextStyle(
                                  fontFamily: 'Fredrik',
                                  fontSize:
                                      device == en.DeviceType.desktop
                                          ? 18.sp
                                          : 55.sp,
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : supabaseService.isDark
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w800
                                          : FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Spacer(),
                // Spacer(),
                // UpgradeCard(sv: supabaseService),
              ],
            ),
          ),
        );
      },
    );
  }
}
