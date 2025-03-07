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
                      Text(
                        "Log In",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Frederik'),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Log in to existing account",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontFamily: 'Frederik',
                            fontWeight: FontWeight.w200),
                      ),
                      SizedBox(height: 24),
                      Text("Username / Email Address",
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Frederik')),
                      SizedBox(height: 8),
                      TextField(
                        controller: provider.emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'Enter your Username / Email Address',
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Frederik',
                              fontSize: 16),
                          disabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text("Password",
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Frederik')),
                      SizedBox(height: 8),
                      TextField(
                        controller: provider.passwordController,
                        obscureText: provider.obscurePassword,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'Enter the Password',
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Frederik',
                              fontSize: 16,
                              fontWeight: FontWeight.w100),
                          disabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(provider.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: provider.toggleObscurePassword,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      _isLoading 
                      ? Center(child: CircularProgressIndicator())
                      : Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            // Validate inputs
                            if (provider.emailController.text.isEmpty || 
                                provider.passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Email and password are required'))
                              );
                              return;
                            }
                            
                            setState(() {
                              _isLoading = true;
                            });
                            
                            try {
                              String res = await provider.loginUser(
                                  email: provider.emailController.text,
                                  password: provider.passwordController.text);
                                  
                              if (res == "Logged in successfully") {
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => Dashboard(),
                                ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res),
                                    duration: Duration(seconds: 5),
                                  )
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  duration: Duration(seconds: 5),
                                )
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 8),
                            child: Text("Log in",
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Frederik')),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",
                              style: TextStyle(fontFamily: 'Frederik')),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ));
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                            ),
                            child: Text("Sign up",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: 'Frederik')),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(flex: 1, child: SliderStart()),
            ],
          ),
        );
      },
    );
  }
}