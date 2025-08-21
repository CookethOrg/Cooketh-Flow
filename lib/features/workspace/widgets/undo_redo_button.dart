import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/workspace/widgets/vertical_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UndoRedoButton extends StatelessWidget {
  final SupabaseService su;
  const UndoRedoButton({super.key,required this.su});

  @override
  Widget build(BuildContext context) {
    bool isDesktop =
        rh.ResponsiveLayoutHelper.getDeviceType(context) ==
        rh.DeviceType.desktop;

    bool isTab =
        rh.ResponsiveLayoutHelper.getDeviceType(context) == rh.DeviceType.tab;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            isDesktop
                ? 24.w
                : isTab
                ? 20.w
                : 15.w,
        vertical:
            isDesktop
                ? 17.h
                : isTab
                ? 13.h
                : 8.h,
      ),
      decoration: BoxDecoration(
        color: su.isDark ?  Color.fromRGBO(48, 48, 48, 1): Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color:su.isDark ?Color.fromRGBO(75, 75, 75, 1): const Color(0xFFD9D9D9), width: 1.2),
      ),
      child: SizedBox(
        height:
            isDesktop
                ? 56.h
                : isTab
                ? 56.h
                : 40.h, // Fixed height for consistency
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: Icon(
                  PhosphorIconsRegular.arrowArcLeft,
                  size:
                      isDesktop
                          ? 32.sp
                          : isTab
                          ? 55.sp
                          : 100.sp,
                  color: su.isDark ? Colors.white : Colors.black,
                ),
              ),
              VerticalCustomDivider(), // Custom divider
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: Icon(
                  PhosphorIconsRegular.arrowArcRight,
                  size:
                      isDesktop
                          ? 32.sp
                          : isTab
                          ? 55.sp
                          : 100.sp,
                  color: su.isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
