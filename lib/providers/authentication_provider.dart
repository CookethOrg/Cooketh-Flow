import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/providers/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationProvider extends StateHandler {
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String supabaseUrl;
  String supabaseApiKey;
  LoadingProvider loadingProvider = LoadingProvider();
  late AuthResponse _userData;
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

  void setUserData(AuthResponse d) {
    _userData = d;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await supabase
        .from('User')
        .select('userName')
        .eq('id', user.id)
        .single();

    print(response);

    return response;
  }

  Future<Map<String,dynamic>?> fetchCurrentUserDetails() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await supabase
        .from('User')
        .select()
        .eq('id', user.id).single();

    // print(response);

    return response;
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
        final AuthResponse authResponse =
            await supabase.auth.signUp(email: email, password: password);

        final user = authResponse.user;
        setUserData(authResponse);

        if (user == null) throw Exception("User signup failed.");

        // Update progress for auth signup completion (60%)
        loadingProvider.updateProgress(0.6);

        // Insert user data
        await supabase.from('User').insert({
          'id': user.id,
          'userName': userName,
          'email': email,
          'flowList': {}
        });

        // Update progress for database insertion completion (100%)
        loadingProvider.updateProgress(1.0);

        res = "Signed Up Successfully";
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
        final AuthResponse authResponse =
            await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final user = authResponse.user;
        print(fetchCurrentUser());

        if (user == null) {
          throw Exception('Login failed: User not found.');
        }

        // ✅ Store user data for future use
        setUserData(authResponse);

        res = 'Logged in successfully';
        print("✅ Login Successful! User ID: ${user.id}");
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
