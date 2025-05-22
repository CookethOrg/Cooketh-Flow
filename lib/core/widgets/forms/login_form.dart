import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/app/providers/authentication_provider.dart';
import 'package:cookethflow/utilities/enums/app_view.dart';
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
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Frederik',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Log in to existing account",
            style: TextStyle(
              fontSize: 20,
              color: gridCol,
              fontFamily: 'Frederik',
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Email Address",
            style: TextStyle(fontSize: 20, fontFamily: 'Frederik'),
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
                color: gridCol,
                fontFamily: 'Frederik',
                fontSize: 16,
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: textColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: selectedItems, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Password",
            style: TextStyle(fontSize: 20, fontFamily: 'Frederik'),
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
              hintText: 'Enter the Password',
              hintStyle: const TextStyle(
                color: gridCol,
                fontFamily: 'Frederik',
                fontSize: 16,
                fontWeight: FontWeight.w100,
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: textColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: selectedItems, width: 2),
                borderRadius: BorderRadius.circular(12),
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
            child: provider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: textColor,
                      foregroundColor: white,
                    ),
                    onPressed: () async {
                      // Validate inputs
                      if (provider.emailController.text.isEmpty ||
                          provider.passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Email and password are required')),
                        );
                        return;
                      }

                      provider.setLoading(true);

                      try {
                        String res = await provider.loginUser(
                          email: provider.emailController.text,
                          password: provider.passwordController.text,
                        );

                        if (res == "Logged in successfully") {
                          context.pushReplacement(AppView.dashboard.path);
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
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Text(
                        "Log in",
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
                "Don't have an account?",
                style: TextStyle(fontFamily: 'Frederik'),
              ),
              TextButton(
                onPressed: () {
                  context.pushReplacement(AppView.signUp.path);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                child: const Text(
                  "Sign up",
                  style:
                      TextStyle(color: selectedItems, fontFamily: 'Frederik'),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
