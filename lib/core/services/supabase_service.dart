import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends StateHandler {
  late final SupabaseClient supabase;
  SupabaseService(this.supabase) : super();
  // late String _userName;
  // late String _email;
  // late String _password;
  late AuthResponse _userData;

  // String get userName => _userName;
  // String get email => _email;
  // String get password => _password;
  AuthResponse get userData => _userData;

  // void setUserName(String val) {
  //   _userName = val;
  //   notifyListeners();
  // }

  // void setEmail(String val) {
  //   _email = val;
  //   notifyListeners();
  // }

  // void setPassword(String val) {
  //   _password = val;
  //   notifyListeners();
  // }

  void setUserData(AuthResponse user) {
    _userData = user;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchCurrentUserName() async {
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

  Future<Map<String, dynamic>?> fetchCurrentUserDetails() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response =
        await supabase.from('User').select().eq('id', user.id).single();

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
        // loadingProvider.startLoading();

        // Update progress for auth signup start (30%)
        // loadingProvider.updateProgress(0.3);
        final AuthResponse authResponse =
            await supabase.auth.signUp(email: email, password: password);

        final user = authResponse.user;
        setUserData(authResponse);

        if (user == null) throw Exception("User signup failed.");

        // Update progress for auth signup completion (60%)
        // loadingProvider.updateProgress(0.6);

        // Insert user data
        await supabase.from('User').insert({
          'id': user.id,
          'userName': userName,
          'email': email,
          'flowList': {}
        });

        // Update progress for database insertion completion (100%)
        // loadingProvider.updateProgress(1.0);

        res = "Signed Up Successfully";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    // setLoading(true);
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
        // print(fetchCurrentUserName());

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
      // setLoading(false);
    }

    return res;
  }
}
