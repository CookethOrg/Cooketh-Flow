import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase related classes

class AuthenticationProvider extends StateHandler {
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Added for confirm password

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  TextEditingController get userNameController => _userNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;

  final SupabaseService supabaseService; // Made final as it's initialized in constructor

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

  /// Initiates Google authentication flow.
  /// No longer returns a String directly, as `supabaseService.googleAuthenticate`
  /// initiates an external flow and the app relies on the `onAuthStateChange` listener.
  Future<void> googleAuth() async {
    setLoading(true);
    try {
      await supabaseService.googleAuthenticate();
      // The actual navigation/state update will happen via SupabaseService's
      // onAuthStateChange listener which updates currentUser and notifies.
      // You might show a loading indicator until the dashboard page loads.
    } catch (e) {
      print("Google Auth error: $e");
      // Optionally show a snackbar here, but the primary response is via listener
    } finally {
      // setLoading(false); // Do not set false immediately, as navigation might still be pending
    }
  }

  /// Initiates GitHub authentication flow.
  /// Similar to Google Auth, relies on `onAuthStateChange` listener.
  Future<void> githubSignin() async {
    setLoading(true);
    try {
      await supabaseService.signInWithGithub();
    } catch (e) {
      print("GitHub Auth error: $e");
    } finally {
      // setLoading(false);
    }
  }

  /// Creates a new user with email and password.
  /// `name` parameter added for email sign-ups to populate user metadata.
  Future<String> createNewUser({
    required String name, // Added 'name' here
    required String userName,
    required String email,
    required String password,
  }) async {
    setLoading(true); // Start loading
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty && userName.isNotEmpty && password.isNotEmpty) {
        res = await supabaseService.createNewUser(
          name: name, // Pass name to createNewUser in SupabaseService
          userName: userName,
          email: email,
          password: password,
        );
      } else {
        res = "Please fill all fields";
      }
    } on AuthException catch (e) {
      res = e.message;
    } catch (e) {
      res = e.toString();
    } finally {
      setLoading(false); // End loading
    }
    return res;
  }

  /// Logs in an existing user with email and password.
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    setLoading(true); // Start loading
    String res = 'Some error occurred';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        res = await supabaseService.loginUser(email: email, password: password);
      } else {
        res = 'Email and Password cannot be empty';
      }
    } on AuthException catch (e) {
      res = e.message;
    } catch (e) {
      res = 'Unexpected error: ${e.toString()}';
      print("❌ Unexpected error during login: ${e.toString()}");
    } finally {
      setLoading(false); // End loading
    }
    return res;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    _confirmPasswordController.dispose(); // Dispose new controller
    super.dispose();
  }
}