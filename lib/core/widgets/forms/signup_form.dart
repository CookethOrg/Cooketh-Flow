import 'package:cookethflow/core/routes/app_route_const.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/dashboard_screens/dashboard.dart';
import 'package:cookethflow/screens/auth_screens/log_in.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final double fontSize = isSmallScreen ? 24 : 32;
    final double subtitleFontSize = isSmallScreen ? 16 : 20;
    final double labelFontSize = isSmallScreen ? 16 : 20;
    return Consumer<AuthenticationProvider>(
        builder: (context, provider, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sign Up",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Frederik',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create a new account",
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: Colors.grey,
              fontFamily: 'Frederik',
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Username",
            style: TextStyle(fontSize: labelFontSize, fontFamily: 'Frederik'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: provider.userNameController,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'Enter your Username',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: 'Frederik',
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Email Address",
            style: TextStyle(fontSize: labelFontSize, fontFamily: 'Frederik'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: provider.emailController,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'Enter your Email Address',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: 'Frederik',
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Password",
            style: TextStyle(fontSize: labelFontSize, fontFamily: 'Frederik'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: provider.passwordController,
            obscureText: provider.obscurePassword,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'Enter your Password',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: 'Frederik',
                fontSize: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(provider.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: provider.toggleObscurePassword,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                provider.setLoading(true);
                String res = await provider.createNewUser(
                  userName: provider.userNameController.text,
                  email: provider.emailController.text,
                  password: provider.passwordController.text,
                );
                provider.setLoading(false);

                if (res == "Signed Up Successfully") {
                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account created successfully!'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // Navigate to dashboard
                  context.pushReplacement(RoutesPath.dashboard);
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $res'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Text(
                  "Sign up",
                  style: TextStyle(fontSize: 16, fontFamily: 'Frederik'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account?",
                style: TextStyle(fontFamily: 'Frederik'),
              ),
              TextButton(
                onPressed: () {
                  context.pushReplacement(RoutesPath.loginScreen);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                child: const Text(
                  "Log in",
                  style: TextStyle(color: Colors.blue, fontFamily: 'Frederik'),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
