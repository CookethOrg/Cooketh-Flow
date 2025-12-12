import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/utils/enums.dart' as en;

class CustomSnackbar {
  CustomSnackbar._();
  static void showSuccess(
    BuildContext context,
    String message, {
    int duration = 3,
  }) {
    _show(
      context,
      message: message,
      type: en.SnackbarType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    int duration = 3,
  }) {
    _show(
      context,
      message: message,
      type: en.SnackbarType.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    int duration = 3,
  }) {
    _show(
      context,
      message: message,
      type: en.SnackbarType.info,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    int duration = 3,
  }) {
    _show(
      context,
      message: message,
      type: en.SnackbarType.warning,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required en.SnackbarType type,
    required int duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: _SnackbarWidget(
              message: message,
              type: type,
              duration: duration,
              onDismiss: () {
                overlayEntry.remove();
              },
            ),
          ),
    );

    overlay.insert(overlayEntry);
  }
}

class _SnackbarWidget extends StatefulWidget {
  final String message;
  final en.SnackbarType type;
  final int duration;
  final VoidCallback onDismiss;

  const _SnackbarWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(Duration(seconds: widget.duration), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case en.SnackbarType.success:
        return secondaryColors[0]; // Green for successfull events
      case en.SnackbarType.error:
        return secondaryColors[1]; // Red for error
      case en.SnackbarType.info:
        return secondaryColors[6]; // Blue for information
      case en.SnackbarType.warning:
        return secondaryColors[7]; // Orange for warning
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case en.SnackbarType.success:
        return Icons.check_circle_rounded;
      case en.SnackbarType.error:
        return Icons.error_rounded;
      case en.SnackbarType.info:
        return Icons.info_rounded;
      case en.SnackbarType.warning:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    en.DeviceType deviceType = rh.ResponsiveLayoutHelper.getDeviceType(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = deviceType == en.DeviceType.desktop;
    final isTablet = deviceType == en.DeviceType.tab;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: GestureDetector(
            onTap: () {
              _controller.reverse().then((_) {
                if (mounted) widget.onDismiss();
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth:
                      isDesktop
                          ? 400
                          : isTablet
                          ? 350
                          : screenWidth * 0.9,
                  minHeight: isDesktop ? 60 : 70,
                ),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 16,
                  vertical: isDesktop ? 16 : 14,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: isDesktop ? 28 : 32,
                    ),
                    SizedBox(width: isDesktop ? 12 : 14),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _controller.reverse().then((_) {
                          if (mounted) widget.onDismiss();
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.9),
                        size: isDesktop ? 20 : 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
