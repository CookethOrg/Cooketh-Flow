import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/screens/dashboard.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserSession();
    });
  }

  Future<void> _checkUserSession() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final isAuthenticated = await authProvider.isAuthenticated();

    if (!mounted) return;

    if (isAuthenticated) {
      // Initialize flow provider but outside of the build phase
      final flowProvider = Provider.of<FlowmanageProvider>(context, listen: false);
      
      // Navigate to Dashboard (initialization will happen in Dashboard's initState)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Dashboard()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or app name
            Image.asset(
              'assets/pic1.png', // Replace with your app logo
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            const Text(
              'CookethFlow',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}