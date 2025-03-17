import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/dashboard.dart';
import 'package:cookethflow/screens/loading.dart';
import 'package:cookethflow/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/screens/slider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 800;
    
    return Consumer<AuthenticationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: isSmallScreen 
            ? _buildMobileLayout(context, provider)
            : _buildDesktopLayout(context, provider),
        );
      },
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context, AuthenticationProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 64,
                ),
                child: _buildLoginForm(context, provider),
              ),
            ),
          ),
        ),
        Expanded(flex: 1, child: SliderStart()),
      ],
    );
  }
  
  Widget _buildMobileLayout(BuildContext context, AuthenticationProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: SliderStart(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: _buildLoginForm(context, provider),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginForm(BuildContext context, AuthenticationProvider provider) {
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
            color: Colors.grey,
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
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter your Email Address',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Frederik',
              fontSize: 16,
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter the Password',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Frederik',
              fontSize: 16,
              fontWeight: FontWeight.w100,
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
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
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // Validate inputs
                    if (provider.emailController.text.isEmpty ||
                        provider.passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email and password are required')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      String res = await provider.loginUser(
                        email: provider.emailController.text,
                        password: provider.passwordController.text,
                      );

                      if (res == "Logged in successfully") {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Dashboard(),
                          ),
                        );
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
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SignupPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5),
              ),
              child: const Text(
                "Sign up",
                style: TextStyle(color: Colors.blue, fontFamily: 'Frederik'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}