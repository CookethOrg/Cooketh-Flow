import 'package:cookethflow/core/helpers/input_validators.dart';
import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Log In",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Log in to your existing account",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w300,
                fontSize: 16,
                color: Color(0xFF4B4B4B),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Email address",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: provider.emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => validateEmail(value),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                hintText: 'Enter your email address',
                hintStyle: const TextStyle(
                  fontFamily: 'Frederik',
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Color(0xFF4B4B4B),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFD9D9D9),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true, // Enable filled background
                fillColor: Colors.white, // Set white background
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Password",
              style: TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => validatePassword(value),
              controller: provider.passwordController,
              obscureText: provider.obscurePassword,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                hintText: 'Enter your password',
                hintStyle: const TextStyle(
                  fontFamily: 'Frederik',
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Color(0xFF4B4B4B),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFD9D9D9),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  icon: Icon(
                    provider.obscurePassword
                        ? PhosphorIconsRegular.eye
                        : PhosphorIconsRegular.eyeSlash,
                    size: 24,
                  ),
                  onPressed: provider.toggleObscurePassword,
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child:
                  provider.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          // Validate inputs
                          // if (provider.emailController.text.isEmpty ||
                          //     provider.passwordController.text.isEmpty) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //         content: Text('Email and password are required')),
                          //   );
                          //   return;
                          // }

                          provider.setLoading(true);

                          try {
                            String res = await provider.loginUser(
                              email: provider.emailController.text,
                              password: provider.passwordController.text,
                            );

                            if (res == "Logged in successfully") {
                              context.pushReplacement(RoutesPath.dashboard);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res),
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          } finally {
                            provider.setLoading(false);
                          }
                        },
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            fontFamily: 'Frederik',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 24),
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Color(0xFFD9D9D9),
                          width: 1,
                        ),
                      ),
                      onPressed: () async {
                        provider.setLoading(true);
                        String res = await provider.googleAuth();
                        provider.setLoading(false);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(res)));
                        if (res.contains('User Authenticated')) {
                          context.pushReplacement(RoutesPath.dashboard);
                        }
                        context.pushReplacement(RoutesPath.dashboard);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIconsRegular.googleLogo, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "Login with Google",
                            style: TextStyle(
                              fontFamily: 'Frederik',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Color(0xFFD9D9D9),
                          width: 1,
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIconsRegular.githubLogo, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "Login with GitHub",
                            style: TextStyle(
                              fontFamily: 'Frederik',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      fontFamily: 'Frederik',
                      fontWeight: FontWeight.w500, // Medium
                      fontSize: 16,
                      color: secondaryColors[6], // Secondary color blue
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
