import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UpgradeCard extends StatefulWidget {
  final SupabaseService sv;
  const UpgradeCard({super.key, required this.sv});

  @override
  State<UpgradeCard> createState() => _UpgradeCardState();
}

class _UpgradeCardState extends State<UpgradeCard> {
  @override
  Widget build(BuildContext context) {
    rh.DeviceType device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.symmetric(
        horizontal:
            device == rh.DeviceType.desktop
                ? 24.w
                : device == rh.DeviceType.tab
                ? 24.w
                : 30.w,
        vertical:
            device == rh.DeviceType.desktop
                ? 20.w
                : device == rh.DeviceType.tab
                ? 20.w
                : 30.w,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.sv.isDark ? Colors.grey.shade700 : Color(0xFFD9D9D9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.sparkle,
                color: widget.sv.isDark ? Colors.white : Colors.black,
                size:
                    device == rh.DeviceType.desktop
                        ? 24.sp
                        : device == rh.DeviceType.tab
                        ? 28.sp
                        : 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Upgrade your Plan',
                style: TextStyle(
                  fontFamily: 'Fredrik',
                  fontSize:
                      device == rh.DeviceType.desktop
                          ? 20.sp
                          : device == rh.DeviceType.tab
                          ? 24.sp
                          : 45.sp,
                  fontWeight: FontWeight.w600,
                  color: widget.sv.isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Get more with CookethFlow Pro – Access exclusive features like [feature 1], [feature 2], and [feature 3]. Cancel anytime, no strings attached.',
            style: TextStyle(
              fontFamily: 'Fredrik',
              fontSize:
                  device == rh.DeviceType.desktop
                      ? 16.sp
                      : device == rh.DeviceType.tab
                      ? 20.sp
                      : 45.sp,
              color: widget.sv.isDark?Colors.white: Color(0xFF4B4B4B),
              height: 2,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Add upgrade logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical:
                      device == rh.DeviceType.desktop
                          ? 12.h
                          : device == rh.DeviceType.tab
                          ? 16.h
                          : 0.8.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Explore',
                style: TextStyle(
                  fontFamily: 'Fredrik',
                  fontSize:
                      device == rh.DeviceType.desktop
                          ? 14.sp
                          : device == rh.DeviceType.tab
                          ? 18.sp
                          : 45.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
