import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/providers/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationProvider extends StateHandler {
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  LoadingProvider loadingProvider = LoadingProvider();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final SupabaseService supabaseService;

  AuthenticationProvider(this.supabaseService) : super();

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  TextEditingController get userNameController => _userNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

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

  Future<Map<String, dynamic>?> fetchCurrentUserName() async {
    return await supabaseService.fetchCurrentUserName();
  }

  Future<Map<String, dynamic>?> fetchCurrentUserDetails() async {
    return await supabaseService.fetchCurrentUserDetails();
  }

  // Check if user is already authenticated
  Future<bool> isAuthenticated() async {
    return await supabaseService.checkUserSession();
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
        loadingProvider.startLoading();
        loadingProvider.updateProgress(0.3);

        res = await supabaseService.createNewUser(
            userName: userName, email: email, password: password);

        loadingProvider.updateProgress(0.6);
        loadingProvider.updateProgress(1.0);
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
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

  Future<void> deleteUserAccount() async {
    try {
      await supabaseService.deleteUserAccount();
    } catch (e) {
      print("Error in AuthProvider - deleteUserAccount: $e");
      rethrow;
    }
  }

  // Update user profile methods
  Future<String> updateUserName(String userName) async {
    try {
      return await supabaseService.updateUserName(userName: userName);
    } catch (e) {
      print("Error in AuthProvider - updateUserName: $e");
      rethrow;
    }
  }

  Future<String> updateUserEmail(String email) async {
    try {
      return await supabaseService.updateUserEmail(email: email);
    } catch (e) {
      print("Error in AuthProvider - updateUserEmail: $e");
      rethrow;
    }
  }

  Future<String> updateUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await supabaseService.updateUserPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      print("Error in AuthProvider - updateUserPassword: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}