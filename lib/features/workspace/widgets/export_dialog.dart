import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/utils/enums.dart' as en;

class ExportDialog extends StatefulWidget {
  final SupabaseService su;
  final WorkspaceProvider wp;

  const ExportDialog({super.key, required this.su, required this.wp});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _selectedFormat = 'PNG';
  final List<String> _formats = ['PNG', 'JSON', 'SVG'];

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color:
              widget.su.isDark
                  ? const Color.fromRGBO(48, 48, 48, 1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
                  'Export',
                  style: TextStyle(
                    fontSize:
                        device == en.DeviceType.desktop
                            ? 22.sp
                            : device == en.DeviceType.tab
                            ? 22.sp
                            : 60.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        widget.su.isDark
                            ? Colors.white
                            : const Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    PhosphorIconsRegular.x,
                    size:
                        device == en.DeviceType.desktop
                            ? 24.sp
                            : device == en.DeviceType.tab
                            ? 24.sp
                            : 55.sp,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: widget.su.isDark ? Colors.white : Colors.black,
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Export as',
                  style: TextStyle(
                    fontSize:
                        device == en.DeviceType.desktop
                            ? 16.sp
                            : device == en.DeviceType.tab
                            ? 16.sp
                            : 45.sp,
                    color: widget.su.isDark ? Colors.white : Colors.grey[700],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFormat,
                    underline: const SizedBox.shrink(),
                    icon: Icon(
                      PhosphorIconsRegular.caretDown,
                      size:
                          device == en.DeviceType.desktop
                              ? 16.sp
                              : device == en.DeviceType.tab
                              ? 16.sp
                              : 45.sp,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFormat = newValue;
                        });
                      }
                    },
                    items:
                        _formats.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize:
                                    device == en.DeviceType.desktop
                                        ? 16.sp
                                        : device == en.DeviceType.tab
                                        ? 16.sp
                                        : 45.sp,
                                color:
                                    widget.su.isDark
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedFormat == 'JSON') {
                    widget.wp.exportWorkspaceAsJson();
                  } else if (_selectedFormat == 'PNG') {
                    widget.wp.exportWorkspaceAsPng();
                  } else if (_selectedFormat == 'SVG') {
                    print('Exporting as SVG is not implemented yet.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Coming soon!'),
                        backgroundColor: primaryColor,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Export Flowchart',
                  style: TextStyle(
                    fontSize:
                        device == en.DeviceType.desktop
                            ? 16.sp
                            : device == en.DeviceType.tab
                            ? 16.sp
                            : 45.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
