import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPickerWidget({
    Key? key,
    this.initialColor = Colors.red,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color currentColor;
  double hueValue = 0.0;
  double opacityValue = 1.0;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
    hueValue = HSVColor.fromColor(currentColor).hue;
    opacityValue = currentColor.opacity;
  }

  void _updateColor() {
    final hsvColor = HSVColor.fromAHSV(opacityValue, hueValue, 1.0, 1.0);
    setState(() {
      currentColor = hsvColor.toColor();
    });
    widget.onColorChanged(currentColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450.w, // Increased width for a larger widget
      padding: EdgeInsets.all(24.r), // Increased padding for better spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 8.r),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Color Picker Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.paintBucket,
                    size: 28.sp,
                    color: Colors.black87,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Background Colour',
                    style: TextStyle(
                      fontSize: 24.sp, // Larger font
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(PhosphorIconsRegular.x, size: 28.sp), // Larger close icon
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Color Picker Area (Static Gradient with Draggable Circle)
          Container(
            height: 250.h, // Increased height for better visibility
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Colors.red],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 3.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Hue Slider with Rounded Edges
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r), // Rounded edges
            child: Container(
              height: 40.h, // Increased height for better interaction
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple],
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Slider(
                value: hueValue,
                min: 0,
                max: 360,
                onChanged: (value) {
                  setState(() {
                    hueValue = value;
                    _updateColor();
                  });
                },
                activeColor: Colors.transparent,
                inactiveColor: Colors.transparent,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Opacity Slider with Rounded Edges
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r), // Rounded edges
            child: Container(
              height: 40.h, // Increased height for better interaction
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, currentColor],
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Slider(
                value: opacityValue,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    opacityValue = value;
                    _updateColor();
                  });
                },
                activeColor: Colors.transparent,
                inactiveColor: Colors.transparent,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Color Info
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'HEX',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp, // Larger font
                  ),
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
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp, // Larger font
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${(opacityValue * 100).round()}%',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp, // Larger font
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // On this page
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'On this page',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp, // Larger font
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                  size: 20.sp, // Larger icon
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          
          // Color Palette
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              for (var color in [
                Colors.green,
                Colors.red,
                Colors.orange,
                Colors.purple,
                Colors.pink[100]!,
                Colors.green[100]!,
                Colors.purple[100]!
              ])
                Container(
                  width: 60.w, // Increased size for better visibility
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Updated ToolBar to use the new ColorPickerWidget
class ColorToolBar extends StatelessWidget {
  const ColorToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Container(
      margin: EdgeInsets.only(right: 20.w),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toolIcon(PhosphorIconsRegular.paintBucket, device, onTap: () {
            _showColorPicker(context);
          }),
          _horizontaldivider(),
          _toolIcon(PhosphorIconsRegular.circlesThreePlus, device),
          _toolIcon(
            PhosphorIconsFill.circle,
            device,
            iconColor: tertiaryColors[3],
          ),
          _horizontaldivider(),
          _toolIcon(PhosphorIconsRegular.handGrabbing, device),
          _toolIcon(PhosphorIconsRegular.textT, device),
          _toolIcon(PhosphorIconsRegular.image, device),
          _toolIcon(
            PhosphorIconsFill.noteBlank,
            device,
            iconColor: tertiaryColors[6],
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ColorPickerWidget(
          initialColor: Colors.red,
          onColorChanged: (color) {
            print('Selected color: $color');
          },
        ),
      ),
    );
  }

  Widget _toolIcon(
    IconData iconData,
    rh.DeviceType device, {
    Color iconColor = Colors.black87,
    Color backgroundColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IconButton(
        onPressed: onTap ?? () {},
        icon: Icon(
          iconData,
          size: 32.sp,
          color: iconColor,
        ),
        splashRadius: 28.r,
      ),
    );
  }

  Widget _horizontaldivider() {
    return Container(
      width: 24.w,
      height: 1.2.h,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(vertical: 8.h),
    );
  }
}
