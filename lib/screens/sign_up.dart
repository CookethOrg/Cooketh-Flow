import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/dashboard.dart';
import 'package:cookethflow/screens/loading.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:cookethflow/screens/slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Frederik',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Create a new account",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontFamily: 'Frederik',
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Username",
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Frederik')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: provider.userNameController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'Enter your Username',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Frederik',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Email Address",
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Frederik')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: provider.emailController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'Enter your Email Address',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Frederik',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Password",
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Frederik')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: provider.passwordController,
                        obscureText: provider.obscurePassword,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const Dashboard()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  padding: const EdgeInsets.all(50),
                                  duration: const Duration(seconds: 10),
                                  content: Text(res),
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 8),
                            child: Text("Sign up",
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Frederik')),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?",
                              style: TextStyle(fontFamily: 'Frederik')),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                            ),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                  color: Colors.blue, fontFamily: 'Frederik'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                Expanded(
                  flex: 1,
                  child: ChangeNotifierProvider.value(
                    value: provider.loadingProvider,
                    child: const LoadingScreen(),
                  ),
                )
              else
                Expanded(flex: 1, child: SliderStart()),
            ],
          ),
        );
      },
    );
  }
}
