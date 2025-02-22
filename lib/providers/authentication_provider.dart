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
  // final db = Supabase.instance.client.from('User').select();

  AuthenticationProvider()
      : supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "Url",
        supabaseApiKey = dotenv.env["SUPABASE_KEY"] ?? "your_api_key",
        super() {
    supabase = SupabaseClient(supabaseUrl, supabaseApiKey,
        authOptions: AuthClientOptions(authFlowType: AuthFlowType.implicit));
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

  Future<String> createNewUser({
    required String userName,
    required String email,
    required String password,
  }) async {
    setLoading(true);
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty && userName.isNotEmpty && password.isNotEmpty) {
        // 1️⃣ Sign up the user
        final AuthResponse authResponse =
            await supabase.auth.signUp(email: email, password: password);

        final user = authResponse.user;
        if (user == null) {
          throw Exception("User signup failed.");
        }
        print(user);
        print(user.id);
        // 2️⃣ Use the same ID from auth.users
        final String userId = user.id;

        // var file = File('path/to/your/file');
        // var u = await supabase.storage.from('users').upload(userId, file);
        // Create an empty file
        await supabase.from('User').insert({
          'id': userId,
          'userName': userName,
          'email': email,
          'flowList': {}
        });
        res = "Signed Up Successfully";
      }
    } catch (e) {
      res = e.toString();
    } finally {
      setLoading(false);
    }

    return res;
  }
}
