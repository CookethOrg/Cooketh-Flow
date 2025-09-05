import 'dart:async';
import 'dart:io'; // For File operations in non-web platforms
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/models/user_model.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart'; // For getTemporaryDirectory in desktop
import 'package:http/http.dart' as http; // For fetching network images to XFile

class SupabaseService extends StateHandler {
  late final SupabaseClient supabase;

  SupabaseService(this.supabase) {
    // Listen for auth state changes to update user data
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final User? user = data.session?.user;

      if (user != null) {
        // Handle OAuth sign-in flow
        if (event == AuthChangeEvent.signedIn) {
          await _handleOAuthSignIn(user);
        }
        await _fetchCurrentUserDetails(
          user,
        ); // Fetch details on sign-in/refresh
      } else {
        // Clear user data on sign-out
        _currentUser = null;
      }
      notifyListeners(); // Notify listeners of auth state change
    });
    // Initial fetch if user is already logged in (e.g., app restart)
    _initializeUserData();
    _loadTheme();
  }

  CurrentUser? _currentUser; // Holds the consolidated user data
  bool _isDark = false;

  bool get isDark => _isDark;
  CurrentUser? get currentUser => _currentUser;
  String get defaultPfpPath => _defaultPfpPath;

  // --- Theme Management ---
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDark);
    notifyListeners();
  }

  // --- User Data Management (Internal & Public) ---

  Future<void> _handleOAuthSignIn(User user) async {
    // Check if it's a first-time sign-up via OAuth
    final providerData = user.appMetadata;
    final isOAuth = providerData['provider'] != null;
    final String? currentAvatarUrl = user.userMetadata!['profile_picture_url'];
    final String? currentName = user.userMetadata!['name'];

    // If it's an OAuth user and they don't have our custom metadata fields,
    // it's their first time.
    if (isOAuth && (currentAvatarUrl == null || currentName == null)) {
      final String? name = user.userMetadata!['full_name'] as String? ?? user.userMetadata!['name'] as String?;
      final String? avatarUrl = user.userMetadata!['avatar_url'] as String?;

      final Map<String, dynamic> updatedData = {};
      if (name != null) {
        updatedData['name'] = name;
        updatedData['username'] = name.toLowerCase().replaceAll(' ', '');
      }

      // If an avatar URL is available from the provider, download and upload it
      if (avatarUrl != null) {
        try {
          final xFile = await fetchUserProfilePictureFile(avatarUrl);
          if (xFile != null) {
            final publicUrl = await uploadUserProfilePicture(xFile);
            updatedData['profile_picture_url'] = publicUrl;
          }
        } catch (e) {
          print("Error handling initial PFP upload: $e");
        }
      }
      if (updatedData.isNotEmpty) {
        await supabase.auth.updateUser(UserAttributes(data: updatedData));
      }
    }
  }

  // Called initially and on auth state changes to populate _currentUser
  Future<void> _fetchCurrentUserDetails(User? user) async {
    if (user == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      // Re-fetch the latest user data including metadata
      final UserResponse response = await supabase.auth.getUser();
      if (response.user != null) {
        _currentUser = CurrentUser.fromSupabaseUser(response.user!);
        print(
          "User data fetched: ${_currentUser?.name} (@${_currentUser?.username})",
        );
      }
    } catch (e) {
      print("Error fetching user details: $e");
      _currentUser = null; // Clear if there's an error fetching
    }
    notifyListeners();
  }

  // Initial check for existing session and data load
  Future<void> _initializeUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null && _currentUser == null) {
      // Only fetch if not already set
      await _fetchCurrentUserDetails(user);
    }
  }

  // --- Authentication Methods ---

  Future<String> createNewUser({
    required String name, // Added name for email signup
    required String userName,
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && userName.isNotEmpty && password.isNotEmpty) {
        final AuthResponse authResponse = await supabase.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: null,
          data: {
            'name': name,
            'userName': userName,
          }, // Store name and username in user_metadata
        );
        final user = authResponse.user;
        if (user == null) throw Exception("User signup failed.");

        await _fetchCurrentUserDetails(
          user,
        ); // Populate _currentUser after signup

        res = "Signed Up Successfully";
      }
    } on AuthException catch (e) {
      res = 'Authentication error: ${e.message}';
      print("❌ AuthException: ${e.message}");
    } catch (e) {
      res = e.toString();
      print("❌ Unexpected error: ${e.toString()}");
    }
    return res;
  }

  Future<String> googleAuthenticate() async {
    try {
      // const webClientId = 'YOUR_WEB_CLIENT_ID_HERE'; // TODO: Replace with your actual Web Client ID from Supabase
      // Make sure you have a scheme set up for mobile, e.g., 'myapp://login-callback/'
      // and added to your Supabase Auth Providers -> Google -> Redirect URIs
      // For desktop, usually 'http://localhost:port' or similar is used.
      final String? redirectUrl =
          kIsWeb ?
              kReleaseMode ? 'http://cookethflow.cookethcompany.xyz/dashboard' : 'http://localhost:3000/dashboard'
              : (Platform.isAndroid || Platform.isIOS
                  ? 'myapp://login-callback/'
                  : null); // For mobile/desktop

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode:
            kIsWeb ? LaunchMode.inAppWebView : LaunchMode.externalApplication,
      );

      // Auth state listener handles populating _currentUser after successful sign-in
      return 'Google Sign-In initiated. Waiting for callback...';
    } on AuthException catch (e) {
      return 'Authentication error: ${e.message}';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> signInWithGithub() async {
    try {
      final String? redirectUrl =
          kIsWeb ?
              kReleaseMode ? 'http://cookethflow.cookethcompany.xyz/dashboard' : 'http://localhost:3000/dashboard'
              : (Platform.isAndroid || Platform.isIOS
                  ? 'my.scheme://my-host'
                  : null); // Replace with your actual scheme

      await supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectUrl,
        authScreenLaunchMode:
            kIsWeb
                ? LaunchMode.platformDefault
                : LaunchMode.externalApplication,
      );

      // Auth state listener handles populating _currentUser after successful sign-in
      return 'GitHub Sign-In initiated. Waiting for callback...';
    } on AuthException catch (e) {
      return 'Authentication error: ${e.message}';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        final AuthResponse authResponse = await supabase.auth
            .signInWithPassword(email: email, password: password);
        final user = authResponse.user;
        if (user == null) throw Exception('Login failed: User not found.');

        await _fetchCurrentUserDetails(
          user,
        ); // Populate _currentUser after login

        res = 'Logged in successfully';
        print("✅ Login Successful! User ID: ${user.id}");
      } else {
        res = 'Email and Password cannot be empty';
      }
    } on AuthException catch (e) {
      res = 'Authentication error: ${e.message}';
      print("❌ AuthException: ${e.message}");
    } catch (e) {
      res = 'Unexpected error: ${e.toString()}';
      print("❌ Unexpected error: ${e.toString()}");
    }
    return res;
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      _currentUser = null; // Clear user data
      notifyListeners();
      print("User logged out successfully.");
    } on AuthException catch (e) {
      print("Error during logout: ${e.message}");
      throw Exception('Error logging out: ${e.message}');
    } catch (e) {
      print("Unexpected error during logout: $e");
      throw Exception('Error logging out: ${e.toString()}');
    }
  }

  // --- Profile Updates ---

  Future<String> updateUserName({
    required String newName,
    required String newUsername,
  }) async {
    String res = 'Some error occurred';
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');
      if (newName.trim().isEmpty) throw Exception('Name cannot be empty');
      if (newUsername.trim().isEmpty)
        throw Exception('Username cannot be empty');

      // Update user_metadata directly
      final updatedData = {
        'name': newName,
        'username': newUsername, // Storing custom username in metadata
      };

      await supabase.auth.updateUser(UserAttributes(data: updatedData));

      // Update local _currentUser state
      _currentUser = _currentUser?.copyWith(
        name: newName,
        username: newUsername,
      );
      notifyListeners();

      res = 'Profile updated successfully';
      return res;
    } on AuthException catch (e) {
      res = 'Authentication error: ${e.message}';
      print("❌ AuthException updating profile: ${e.message}");
      throw Exception(res);
    } catch (e) {
      res = e.toString();
      print("❌ Unexpected error updating profile: ${e.toString()}");
      throw Exception(res);
    }
  }

  Future<String> updateUserEmail({required String email}) async {
    String res = 'Some error occurred';
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');
      if (email.trim().isEmpty) throw Exception('Email cannot be empty');
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        throw Exception('Please enter a valid email address');
      }

      await supabase.auth.updateUser(UserAttributes(email: email));

      // Email updates require confirmation, so local state is not updated immediately for email
      res = 'Email update requested. Please check your inbox to confirm.';
      return res;
    } on AuthException catch (e) {
      res = 'Authentication error: ${e.message}';
      print("❌ AuthException updating email: ${e.message}");
      throw Exception(res);
    } catch (e) {
      res = e.toString();
      print("❌ Unexpected error updating email: ${e.toString()}");
      throw Exception(res);
    }
  }

  Future<String> updateUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    String res = 'Some error occurred';
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');
      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Supabase's `updateUser` with password directly updates it if the session is valid.
      // If you need current password verification, it must be done explicitly,
      // e.g., by re-authenticating the user first, or by using a backend function.
      // The provided code tries to signInWithPassword first, which is a good approach.
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      res = 'Password updated successfully';
      return res;
    } on AuthException catch (e) {
      res = 'Current password is incorrect or session invalid.';
      print("❌ AuthException updating password: ${e.message}");
      throw Exception(res);
    } catch (e) {
      res = e.toString();
      print("❌ Unexpected error updating password: ${e.toString()}");
      throw Exception(res);
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Note: Supabase's client-side SDK doesn't directly support deleting a user
      // from `auth.users` table for security reasons. This usually requires a
      // backend function (Edge Function) with service_role key or a direct
      // database operation with row level security.
      // The current `supabase.from('User').delete()` was targeting a custom table.
      // If you intend to truly delete the user from `auth.users`, you'll need
      // an Edge Function or similar.
      // For now, I'll remove the `supabase.from('User').delete()` part
      // as per your instruction to not use the 'User' table.
      // You can add a prompt to the user here to implement an Edge Function if needed.

      await supabase.auth.signOut(); // Sign out the user
      _currentUser = null; // Clear local user data
      notifyListeners();
      print("User account (locally) logged out and data cleared.");
      // Consider adding an Edge Function call here to truly delete the user from Supabase auth.
    } catch (e) {
      print("Error deleting account: $e");
      throw Exception('Error deleting account: ${e.toString()}');
    }
  }

  // --- Profile Picture Management ---
  final String _profileBucketName =
      'profile'; // Renamed bucket for clarity
  final String _defaultPfpPath =
      'assets/images/pfp.png'; // Make sure this asset exists!

  // Helper to get MIME type
  String _getMimeTypeFromExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String> uploadUserProfilePicture(XFile imageFile) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final extension = imageFile.name.split('.').last.toLowerCase();
      final mimeType = _getMimeTypeFromExtension(extension);
      final storagePath =
          '${user.id}/avatar.$extension'; // Consistent file name

      // Attempt to remove old profile picture if it exists to avoid clutter
      try {
        // List files in the user's directory in the bucket
        final files = await supabase.storage
            .from(_profileBucketName)
            .list(path: user.id);
        for (final file in files) {
          if (file.name.startsWith('avatar.')) {
            // Check for previous avatar files
            await supabase.storage.from(_profileBucketName).remove([
              '${user.id}/${file.name}',
            ]);
            print('Removed old profile picture: ${file.name}');
          }
        }
      } catch (e) {
        print('No existing profile picture to remove or error listing: $e');
      }

      final bytes = await imageFile.readAsBytes();

      // Upload the new image
      await supabase.storage
          .from(_profileBucketName)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      // Get the public URL for the uploaded image
      final String publicUrl = supabase.storage
          .from(_profileBucketName)
          .getPublicUrl(storagePath);

      // Update the user's metadata with the new avatar URL
      await supabase.auth.updateUser(
        UserAttributes(data: {'profile_picture_url': publicUrl}),
      );

      // Update the local CurrentUser object with the new avatar URL
      _currentUser = _currentUser?.copyWith(avatarUrl: publicUrl);
      notifyListeners();

      print('Profile picture uploaded and metadata updated: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }

  Future<XFile?> fetchUserProfilePictureFile(String avatarUrl) async {
    if (avatarUrl.isEmpty) return null;
    try {
      final uri = Uri.parse(avatarUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final fileExtension = uri.path.split('.').last.toLowerCase();
        final mimeType = _getMimeTypeFromExtension(fileExtension);
        if (kIsWeb) {
          return XFile.fromData(
            bytes,
            name: 'pfp.$fileExtension',
            mimeType: mimeType,
          );
        } else {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/pfp.$fileExtension');
          await tempFile.writeAsBytes(bytes);
          return XFile(
            tempFile.path,
            name: 'pfp.$fileExtension',
            mimeType: mimeType,
          );
        }
      }
    } catch (e) {
      print('Error fetching profile picture file: $e');
    }
    return null;
  }
}