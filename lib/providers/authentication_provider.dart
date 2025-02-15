import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationProvider extends StateHandler {
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String supabaseUrl;
  String supabaseApiKey;
  late AuthResponse userData;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final SupabaseClient supabase;

  AuthenticationProvider()
      : supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "Url",
        supabaseApiKey = dotenv.env["SUPABASE_KEY"] ?? "your_api_key",
        super() {
    supabase = SupabaseClient(supabaseUrl, supabaseApiKey);
  }

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  TextEditingController get userNameController => _userNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

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

  Future<String> createNewUser(
      {String userName = "TeeWrath",
      required String email,
      required String password,
      required String confirmPwd}) async {
    setLoading(true);
    String res = "Some error occured";
    try {
      if (email.isNotEmpty || userName.isNotEmpty || password.isNotEmpty) {
        final AuthResponse data =
            await supabase.auth.signUp(email: email, password: password);
        userData = data;
        print(data);
        res = "Signed Up Succesfully";
      }
    } catch (e) {
      res = e.toString();
    } finally {
      setLoading(false);
    }
    return res;
  }
}
