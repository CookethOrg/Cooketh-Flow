import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends StateHandler {
  late final SupabaseClient supabase;
  SupabaseService(this.supabase) : super();
  // late String _userName;
  // late String _email;
  // late String _password;
  late AuthResponse _userData;
  bool _userDataSet = false;

  // String get userName => _userName;
  // String get email => _email;
  // String get password => _password;
  AuthResponse get userData => _userData;
  bool get userDataSet => _userDataSet;

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
    _userDataSet = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchCurrentUserName() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final response = await supabase
          .from('User')
          .select('userName')
          .eq('id', user.id)
          .single();

      print("Fetched user name: $response");
      return response;
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUserDetails() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      final response =
          await supabase.from('User').select().eq('id', user.id).single();

      print("Fetched user details: $response");
      return response;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
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
        // Sign up user
        final AuthResponse authResponse =
            await supabase.auth.signUp(
              email: email,
              password: password,
              emailRedirectTo: null, // Disable email verification redirect
              data: {'userName': userName} // Store username in metadata
            );

        final user = authResponse.user;
        setUserData(authResponse);

        if (user == null) throw Exception("User signup failed.");

        // Insert user data regardless of email confirmation status
        await supabase.from('User').insert({
          'id': user.id,
          'userName': userName,
          'email': email,
          'flowList': {}
        });

        res = "Signed Up Successfully";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
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
    }

    return res;
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error logging out: ${e.toString()}');
    }
  }

Future<void> deleteUserAccount() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    
    // Delete user data from database first
    await supabase.from('User').delete().eq('id', user.id);
    
    // Then delete the auth account
    // await supabase.auth.admin.deleteUser(user.id);
    
    // Sign out
    await supabase.auth.signOut();
  } catch (e) {
    print("Error deleting account: $e");
    throw Exception('Error deleting account: ${e.toString()}');
  }
}
  
  // Check if the user is already logged in
  Future<bool> checkUserSession() async {
    final user = supabase.auth.currentUser;
    return user != null;
  }
}