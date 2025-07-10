import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    rh.DeviceType device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Drawer(
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
          child:  Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child:  Column(
              children: [
                // Column for upper items
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width:  device == rh.DeviceType.desktop ? 60.w : device == rh.DeviceType.tab ? 100.w : 220.w,
                            height: device == rh.DeviceType.desktop ? 60.h : device == rh.DeviceType.tab ? 55.h : 60.h,
                            child: Image.asset(
                              'assets/images/Frame 402.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Antara Paul',
                              style: TextStyle(
                                fontFamily: 'Fredrik',
                                fontSize: device == rh.DeviceType.desktop ? 21.sp : 32.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '@antara_paul',
                              style: TextStyle(
                                fontFamily: 'Fredrik',
                                fontSize: device == rh.DeviceType.desktop ? 15.sp : 26.sp,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            provider.toggleDrawer();
                          },
                          icon: Icon(PhosphorIcons.sidebarSimple(),),
                        ),
                      ],
                    ),
                    SizedBox(height: device == rh.DeviceType.desktop ?30.h: 10.h),
                    // Row for edit profile and logout button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              PhosphorIcons.pencilSimple(),
                              color: primaryColor,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: device == rh.DeviceType.desktop ? 16.w : 10.w,
                                vertical: device == rh.DeviceType.desktop ?12.h : 6.h,
                              ),
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: primaryColor),
                              minimumSize: Size(0,device == rh.DeviceType.desktop ? 48.h : 38.h),
                            ),
                            label: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontFamily: 'Fredrik',
                                fontSize: device == rh.DeviceType.tab ? 26.sp : 19.sp,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              PhosphorIcons.signOut(),
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: device == rh.DeviceType.desktop ? 16.w : 10.w,
                                vertical: device == rh.DeviceType.desktop ? 12.h : 6.h,
                              ),
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              backgroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              minimumSize: Size(0, device == rh.DeviceType.desktop ?48.h:38.h),
                            ),
                            label: Text(
                              'Log Out',
                              style: TextStyle(
                                fontFamily: 'Fredrik',
                                fontSize: device == rh.DeviceType.tab ? 26.sp : 19.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height:device == rh.DeviceType.desktop ? 15.h : 0.h),
                Visibility(visible: provider.isDrawerOpen,child: Divider(color: Colors.grey, thickness: 0.5)),
                // Column for lower items (vertical tabs)
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: provider.tabItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = provider.tabIndex == index;
                      return InkWell(
                        onTap: () {
                          provider.toggleTab(index);
                          // Add navigation logic here if needed
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: device == rh.DeviceType.desktop ? 12.w: 20.w,
                            vertical: device == rh.DeviceType.desktop ? 12.h: 20.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                            // border: isSelected
                            //     ? Border.all(color: primaryColor, width: 1.w)
                            //     : null,
                          ),
                          child: Row(
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
                                  size: device == rh.DeviceType.desktop ? 26.sp: 55.sp,
                                ),
                                child: provider.tabItems[index]['icon'],
                              ),
                              SizedBox(width: device == rh.DeviceType.desktop ? 12.w: 18.w),
                              Text(
                                provider.tabItems[index]['label'],
                                style: TextStyle(
                                  fontFamily: 'Fredrik',
                                  fontSize: device == rh.DeviceType.desktop ?18.sp:26.sp,
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // if(provider.isDrawerOpen || device == rh.DeviceType.mobile || device == rh.DeviceType.tab) AnimatedContainer(
                //   duration: Duration(seconds: 4),
                //   child: Container(
                //     margin: EdgeInsets.only(top: 15.h),
                //     padding: EdgeInsets.all(30.w),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(8.r),
                //       border: Border.all(color: Colors.grey, width: 1.w),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Icon(
                //               PhosphorIcons.sparkle(),
                //               color: Colors.black,
                //               size: 28.sp,
                //             ),
                //             SizedBox(width: 8.w),
                //             Text(
                //               'Upgrade Your Plan',
                //               style: TextStyle(
                //                 fontFamily: 'Fredrik',
                //                 fontSize: 18.sp,
                //                 fontWeight: FontWeight.w600,
                //                 color: Colors.black,
                //               ),
                //             ),
                //           ],
                //         ),
                //         SizedBox(height: 8.h),
                //         Text(
                //           'Get more with CookethFlow Pro – Access exclusive features like [feature 1], [feature 2], and [feature 3]. Cancel anytime, no strings attached.',
                //           style: TextStyle(
                //             fontFamily: 'Fredrik',
                //             fontSize: 14.sp,
                //             color: Colors.black,
                //             fontWeight: FontWeight.w400,
                //           ),
                //         ),
                //         SizedBox(height: 12.h),
                //         SizedBox(
                //           width: double.infinity,
                //           child: ElevatedButton(
                //             onPressed: () {
                //               // Add navigation to subscription page or upgrade logic here
                //             },
                //             style: ElevatedButton.styleFrom(
                //               padding: EdgeInsets.symmetric(
                //                 horizontal: 12.w,
                //                 vertical: 20.h,
                //               ),
                //               backgroundColor: primaryColor,
                //               foregroundColor: Colors.white,
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(8.r),
                //               ),
                //               minimumSize: Size(0, 44.h),
                //             ),
                //             child: Text(
                //               'Explore',
                //               style: TextStyle(
                //                 fontFamily: 'Fredrik',
                //                 fontSize: 16.sp,
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.w600,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
