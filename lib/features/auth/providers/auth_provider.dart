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
}
