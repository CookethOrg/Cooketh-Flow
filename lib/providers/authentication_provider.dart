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
  late AuthResponse _userData;
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
  AuthResponse get userData => _userData;

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

  void setUserData() {
    _userData = supabaseService.userData;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchCurrentUserName() async {
    final user = supabaseService.fetchCurrentUserName();

    if (user == null) {
      return null;
    }

    // final response = await supabase
    //     .from('User')
    //     .select('userName')
    //     .eq('id', user.id)
    //     .single();

    print(user);

    return user;
  }

  Future<Map<String, dynamic>?> fetchCurrentUserDetails() async {
    final user = supabaseService.fetchCurrentUserDetails();

    if (user == null) {
      return null;
    }

    // final response =
    //     await supabase.from('User').select().eq('id', user.id).single();

    // print(response);

    return user;
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

        // Update progress for auth signup start (30%)
        loadingProvider.updateProgress(0.3);
        res = await supabaseService.createNewUser(
            userName: userName, email: email, password: password);

        // final user = authResponse.user;
        // setUserData(authResponse);

        // if (user == null) throw Exception("User signup failed.");

        // Update progress for auth signup completion (60%)
        loadingProvider.updateProgress(0.6);

        // Insert user data
        // await supabase.from('User').insert({
        //   'id': user.id,
        //   'userName': userName,
        //   'email': email,
        //   'flowList': {}
        // });

        // Update progress for database insertion completion (100%)
        loadingProvider.updateProgress(1.0);

        // res = "Signed Up Successfully";
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
        // 🛠 Attempt login
        res = await supabaseService.loginUser(email: email, password: password);

        // final user = authResponse.user;
        // print(fetchCurrentUser());

        // if (user == null) {
        //   throw Exception('Login failed: User not found.');
        // }

        // ✅ Store user data for future use
        // setUserData(authResponse);

        // res = 'Logged in successfully';
        // print("✅ Login Successful! User ID: ${user.id}");
      } else {
        res = 'Email and Password cannot be empty';
      }
    } on AuthException catch (e) {
      res = 'Authentication error: ${e.message}';
      print("❌ AuthException: ${e.message}");
    } on PostgrestException catch (e) {
      res = 'Database error: ${e.message}';
      print("❌ PostgrestException: ${e.message}");
    } catch (e) {
      res = 'Unexpected error: ${e.toString()}';
      print("❌ Unexpected error: ${e.toString()}");
    } finally {
      setLoading(false);
    }

    return res;
  }
}
