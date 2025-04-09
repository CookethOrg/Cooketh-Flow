import 'package:cookethflow/core/utils/update_manager.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/dashboard.dart';
import 'package:cookethflow/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UpdateManager _updateManager = UpdateManager();
  bool _hasCheckedForUpdates = false;
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserSession();
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    if (!_hasCheckedForUpdates) {
      _hasCheckedForUpdates = true;
      // Wait a short time to let the app finish initializing
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _updateManager.checkAndPromptForUpdate(context);
      }
    }
  }

  Future<void> _checkUserSession() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final isAuthenticated = await authProvider.isAuthenticated();

    if (!mounted) return;

    if (isAuthenticated) {
      
      // Navigate to Dashboard (initialization will happen in Dashboard's initState)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Dashboard()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SignupPage()),
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
              'assets/Frame 267.png', // Replace with your app logo
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 30),
            const Text(
              'Welcome to Cooketh Flow',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20,),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}