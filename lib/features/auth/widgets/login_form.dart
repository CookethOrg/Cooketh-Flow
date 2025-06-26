import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Color(0xFF4B4B4B),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Username/Email address",
            style: TextStyle(
              fontFamily: 'Frederik',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: 'Enter your username/email address',
              hintStyle: const TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Color(0xFF4B4B4B),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF000000), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Password",
            style: TextStyle(
              fontFamily: 'Frederik',
              fontWeight: FontWeight.w500, // Medium
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: provider.passwordController,
            obscureText: provider.obscurePassword,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: 'Enter your password',
              hintStyle: const TextStyle(
                fontFamily: 'Frederik',
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Color(0xFF4B4B4B),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF000000), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(provider.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: provider.toggleObscurePassword,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: provider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 32),
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

                      // provider.setLoading(true);

                      // try {
                      //   String res = await provider.loginUser(
                      //     email: provider.emailController.text,
                      //     password: provider.passwordController.text,
                      //   );

                      //   if (res == "Logged in successfully") {
                      //     context.pushReplacement(RoutesPath.dashboard);
                      //   } else {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(
                      //         content: Text(res),
                      //         duration: const Duration(seconds: 5),
                      //       ),
                      //     );
                      //   }
                      // } catch (e) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text('Error: ${e.toString()}'),
                      //       duration: const Duration(seconds: 5),
                      //     ),
                      //   );
                      // } finally {
                      //   provider.setLoading(false);
                      // }
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        fontFamily: 'Frederik',
                        fontWeight: FontWeight.w700, // Demibold
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                child: const Text(
                  "Sign up",
                  style: TextStyle(
                    fontFamily: 'Frederik',
                    fontWeight: FontWeight.w500, // Medium
                    fontSize: 16,
                    color: Color(0xFF3B82F6), // Secondary color blue
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}