import 'package:cookethflow/core/helpers/input_validators.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart'
    as responsive_helper;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/auth/providers/auth_provider.dart';
import 'package:cookethflow/features/dashboard/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        responsive_helper.ResponsiveLayoutHelper.getDeviceType(context) ==
        en.DeviceType.mobile;
    final isDesktop =
        responsive_helper.ResponsiveLayoutHelper.getDeviceType(context) ==
        en.DeviceType.desktop;

    return Consumer2<AuthenticationProvider, SupabaseService>(
      builder: (context, authProvider, supabaseService, child) {
        if (supabaseService.currentUser != null &&
            GoRouter.of(context).routerDelegate.currentConfiguration.fullPath !=
                RoutesPath.dashboard) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check if current route is not already dashboard to prevent loop
            context.go(RoutesPath.dashboard);
            // context.goNamed(RouteName.dashboard,pathParameters: {'username': supabaseService.currentUser!.name!});
            authProvider.setLoading(false);
          });
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Log In",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 75.sp : 40.sp,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Log in to your existing account",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w300,
                fontSize: isMobile ? 50.sp : 25.sp,
                color: const Color(0xFF4B4B4B),
              ),
            ),
            SizedBox(height: 40.h),
            const Text(
              "Email address",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF000000),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: authProvider.emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => validateEmail(value),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                hintText: 'Enter your email address',
                hintStyle: TextStyle(
                  fontFamily: 'Frederik',
                  fontWeight: FontWeight.normal,
                  fontSize: isMobile ? 13 : 16,
                  color: const Color(0xFF4B4B4B),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
              "Password",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF000000),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => validatePassword(value),
              controller: authProvider.passwordController,
              obscureText: authProvider.obscurePassword,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                hintText: 'Enter your password',
                hintStyle: TextStyle(
                  fontFamily: 'Frederik',
                  fontWeight: FontWeight.normal,
                  fontSize: isMobile ? 13 : 16,
                  color: const Color(0xFF4B4B4B),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  color: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  icon: Icon(
                    authProvider.obscurePassword
                        ? PhosphorIconsRegular.eye
                        : PhosphorIconsRegular.eyeSlash,
                    size: isMobile ? 45.sp : 24.sp,
                  ),
                  onPressed: authProvider.toggleObscurePassword,
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Center(
              child:
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 16.h : 32.h,
                            horizontal:
                                isMobile
                                    ? 100.w
                                    : isDesktop
                                    ? 80.w
                                    : 150.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          String? passwordValidationCheck = validatePassword(
                            authProvider.passwordController.text,
                          );
                          if (passwordValidationCheck == null) {
                            String res = await authProvider.loginUser(
                              email: authProvider.emailController.text,
                              password: authProvider.passwordController.text,
                            );
                            if (res != "Logged in successfully") {
                              CustomSnackbar.showError(context, res);
                            }
                          } else {
                            CustomSnackbar.showError(
                              context,
                              passwordValidationCheck,
                            );
                          }
                          // Navigation handled by the Consumer2's listener
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(
                            fontFamily: 'Frederik',
                            fontWeight: FontWeight.w700,
                            fontSize:
                                isMobile
                                    ? 60.sp
                                    : isDesktop
                                    ? 25.sp
                                    : 30.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),
            SizedBox(height: 24.h),
            Column(
              children: [
                const Text(
                  'OR',
                  style: TextStyle(
                    fontFamily: 'Frederik',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 12.h),
                isMobile
                    ? Column(
                      children: [
                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                vertical: 32.h,
                                horizontal: 32.w,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                color: Color(0xFFD9D9D9),
                                width: 1,
                              ),
                            ),
                            onPressed: () async {
                              // Call void method, loading handled by provider
                              await authProvider.googleAuth();
                              CustomSnackbar.showInfo(
                                context,
                                "Initiating Google Sign-In...",
                              );
                              // Navigation handled by the Consumer2's listener
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(PhosphorIconsRegular.googleLogo, size: 15),
                                SizedBox(width: 8.w),
                                Text(
                                  "Login with Google",
                                  style: TextStyle(
                                    fontFamily: 'Frederik',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // GitHub Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                vertical: 32.h,
                                horizontal: 32.w,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                color: Color(0xFFD9D9D9),
                                width: 1,
                              ),
                            ),
                            onPressed: () async {
                              // Call void method, loading handled by provider
                              await authProvider.githubSignin();
                              CustomSnackbar.showInfo(
                                context,
                                "Initiating GitHub Sign-In...",
                              );
                              // Navigation handled by the Consumer2's listener
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(PhosphorIconsRegular.githubLogo, size: 15),
                                SizedBox(width: 8.w),
                                Text(
                                  "Login with GitHub",
                                  style: TextStyle(
                                    fontFamily: 'Frederik',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        final maxButtonWidth =
                            (constraints.maxWidth - 16.w) / 2;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: maxButtonWidth,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 24.h, // Increased padding
                                      horizontal: 24.w, // Increased padding
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(
                                      color: Color(0xFFD9D9D9),
                                      width: 1,
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Call void method, loading handled by provider
                                    await authProvider.googleAuth();
                                    CustomSnackbar.showInfo(
                                      context,
                                      "Initiating Google Sign-In...",
                                    );
                                    // Navigation handled by the Consumer2's listener
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        PhosphorIconsRegular.googleLogo,
                                        size: isDesktop ? 25.sp : 35.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "Login with Google",
                                        style: TextStyle(
                                          fontFamily: 'Frederik',
                                          fontWeight: FontWeight.w500,
                                          fontSize: isDesktop ? 20.sp : 28.sp,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: maxButtonWidth,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 24.h,
                                      horizontal: 24.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(
                                      color: Color(0xFFD9D9D9),
                                      width: 1,
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Call void method, loading handled by provider
                                    await authProvider.githubSignin();
                                    CustomSnackbar.showInfo(
                                      context,
                                      "Initiating GitHub Sign-In...",
                                    );
                                    // Navigation handled by the Consumer2's listener
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        PhosphorIconsRegular.githubLogo,
                                        size: isDesktop ? 25.sp : 35.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "Login with GitHub",
                                        style: TextStyle(
                                          fontFamily: 'Frederik',
                                          fontWeight: FontWeight.w500,
                                          fontSize: isDesktop ? 20.sp : 28.sp,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontFamily: 'Frederik',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF000000),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushReplacement(RoutesPath.signUpScreen);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                      ),
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          fontFamily: 'Frederik',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: secondaryColors[6],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
