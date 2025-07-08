import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashboardDesktop extends StatelessWidget {
  const DashboardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context,provider,child) {
        return LayoutBuilder(
            builder:
                (context, constraints) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 1500),
                      height: provider.isDrawerOpen ? constraints.maxHeight : 0.412.sh,
                      width: 400,
                      child: DashboardDrawer(),
                    ),
                  ],
                ),
        );
      }
    );
  }
}
