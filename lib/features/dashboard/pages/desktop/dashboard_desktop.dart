import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class DashboardDesktop extends StatelessWidget {
  const DashboardDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    rh.DeviceType devideviceType = rh.ResponsiveLayoutHelper.getDeviceType(
      context,
    );
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder:
              (context, constraints) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: 800),
                    height:
                        provider.isDrawerOpen ? constraints.maxHeight : 0.18.sh,
                    width: devideviceType == rh.DeviceType.desktop ? 400.w : 600.w ,
                    child: DashboardDrawer(),
                  ),
                ],
              ),
        );
      },
    );
  }
}
