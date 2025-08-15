import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class WorkspaceColorPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const WorkspaceColorPicker({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _WorkspaceColorPickerState createState() => _WorkspaceColorPickerState();
}

class _WorkspaceColorPickerState extends State<WorkspaceColorPicker> {
  late Color currentColor;
  late HSVColor currentHsvColor;

  // State for the color picker box
  Offset pickerPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
    currentHsvColor = HSVColor.fromColor(currentColor);
    // Note: A fully functional picker would initialize pickerPosition based on saturation/value.
    // For simplicity, we'll start it in a default location.
  }

  void _updateColorFromHsv() {
    setState(() {
      currentColor = currentHsvColor.toColor();
    });
    widget.onColorChanged(currentColor);
  }

  void _handlePickerDrag(Offset localPosition, Size pickerSize) {
    double saturation = (localPosition.dx.clamp(0, pickerSize.width) / pickerSize.width);
    double value = 1.0 - (localPosition.dy.clamp(0, pickerSize.height) / pickerSize.height);

    setState(() {
      currentHsvColor = currentHsvColor.withSaturation(saturation).withValue(value);
      pickerPosition = localPosition;
    });
    _updateColorFromHsv();
  }

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Container(
      width:device == rh.DeviceType.desktop ?  350.w : device == rh.DeviceType.tab ? 350.w : 850.w,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12.r,
            offset: Offset(0, 6.r),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Background Colour',
                style: TextStyle(fontSize:device == rh.DeviceType.desktop ?  20.sp : device == rh.DeviceType.tab ? 20.sp : 50.sp, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(PhosphorIconsRegular.x, size:device == rh.DeviceType.desktop ? 24.sp : device == rh.DeviceType.tab ? 24.sp : 55.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final pickerSize = Size(constraints.maxWidth, 180.h);
              // Calculate position from HSV
              pickerPosition = Offset(
                currentHsvColor.saturation * pickerSize.width,
                (1.0 - currentHsvColor.value) * pickerSize.height,
              );

              return GestureDetector(
                onPanUpdate: (details) => _handlePickerDrag(details.localPosition, pickerSize),
                onPanDown: (details) => _handlePickerDrag(details.localPosition, pickerSize),
                child: Stack(
                  children: [
                    Container(
                      width: pickerSize.width,
                      height: pickerSize.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: LinearGradient(
                          colors: [Colors.white, HSVColor.fromAHSV(1.0, currentHsvColor.hue, 1.0, 1.0).toColor()],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(12.r),
                           gradient: LinearGradient(
                             colors: [Colors.transparent, Colors.black],
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                           ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: pickerPosition.dx - 12.w,
                      top: pickerPosition.dy - 12.h,
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: currentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5.r),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          
          _buildHueSlider(),
          SizedBox(height: 20.h),
          _buildOpacitySlider(),
          SizedBox(height: 20.h),
          
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade300)
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '#${currentColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize:device == rh.DeviceType.desktop ? 16.sp : device == rh.DeviceType.tab ? 16.sp : 40.sp,
                      fontFamily: 'monospace'
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHueSlider() {
    return Container(
      height: 25.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00), Color(0xFF00FFFF),
            Color(0xFF0000FF), Color(0xFFFF00FF), Color(0xFFFF0000)
          ],
        ),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 25.h,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(
          value: currentHsvColor.hue,
          min: 0,
          max: 360,
          onChanged: (value) {
            setState(() {
              currentHsvColor = currentHsvColor.withHue(value);
            });
            _updateColorFromHsv();
          },
          activeColor: Colors.transparent,
          inactiveColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildOpacitySlider() {
    return Container(
      height: 25.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: LinearGradient(
          colors: [currentColor.withOpacity(0), currentColor.withOpacity(1)],
        ),
      ),
      child: SliderTheme(
         data: SliderTheme.of(context).copyWith(
          trackHeight: 25.h,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(
          value: currentHsvColor.alpha,
          min: 0,
          max: 1,
          onChanged: (value) {
            setState(() {
              currentHsvColor = currentHsvColor.withAlpha(value);
            });
            _updateColorFromHsv();
          },
          activeColor: Colors.transparent,
          inactiveColor: Colors.transparent,
        ),
      ),
    );
  }
}