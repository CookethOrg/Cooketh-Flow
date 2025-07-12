import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:cookethflow/features/dashboard/widgets/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class DashboardDesktop extends StatelessWidget {
  const DashboardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    rh.DeviceType deviceType = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 500),
                height: provider.isDrawerOpen ? constraints.maxHeight : 0.185.sh,
                width: deviceType == rh.DeviceType.desktop ? 400.w : 600.w,
                child: DashboardDrawer(),
              ),
              
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(
                              vertical: 32.h,
                              horizontal: 24.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            PhosphorIconsRegular.plus,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          label: Text(
                            'Start a new Project',
                            style: TextStyle(
                              fontFamily: 'Fredrik',
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32,),
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: 5,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20.w,
                            mainAxisSpacing: 20.h,
                            childAspectRatio: 4.5/3,
                          ),
                          itemBuilder: (context, index) {
                            return ProjectCard(idx: index.toString());
                          },
                        ),
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
}