import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider extends StateHandler {
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // LoadingProvider loadingProvider = LoadingProvider();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  TextEditingController get userNameController => _userNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  late final SupabaseService supabaseService;

  AuthenticationProvider(this.supabaseService) : super();

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<String> googleAuth() async {
    try {
      String res = await supabaseService.googleAuthenticate();
      return res;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> createNewUser({
    required String userName,
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty && userName.isNotEmpty && password.isNotEmpty) {
        // Start loading with initial estimate
        // loadingProvider.startLoading();
        // loadingProvider.updateProgress(0.3);

        res = await supabaseService.createNewUser(
          userName: userName,
          email: email,
          password: password,
        );

        // loadingProvider.updateProgress(0.6);
        // loadingProvider.updateProgress(1.0);
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    setLoading(true);
    String res = 'Some error occurred';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        res = await supabaseService.loginUser(email: email, password: password);
      } else {
        res = 'Email and Password cannot be empty';
      }
    } catch (e) {
      res = 'Unexpected error: ${e.toString()}';
      print("❌ Unexpected error during login: ${e.toString()}");
    } finally {
      setLoading(false);
    }

    return res;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }
}
