import 'dart:io';

import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/utils/ui_helper.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends StateHandler {
  late final SupabaseClient supabase;
  SupabaseService(this.supabase) : super();
  late AuthResponse _userData;
  bool _userDataSet = false;
  late XFile? _userPfp = XFile('assets/Frame 271.png');

  AuthResponse get userData => _userData;
  bool get userDataSet => _userDataSet;
  XFile? get userPfp => _userPfp;

  void setUserData(AuthResponse user) {
    _userData = user;
    _userDataSet = true;
    notifyListeners();
  }

  void setUserPfp(XFile? val) {
    _userPfp = val;
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

  // Creates a template workspace with predefined nodes
  FlowManager createTemplateWorkspace() {
    double cv = (canvasDimension / 2) - 100;
    String flowId = DateTime.now().millisecondsSinceEpoch.toString();

    // Create flow manager
    FlowManager flowManager = FlowManager(
      flowId: flowId,
      flowName: "Get Started with Cooketh Flow",
    );

    // Create the nodes with correct text and positions
    FlowNode startNode = FlowNode(
      id: "node1",
      type: NodeType.rectangular,
      position: Offset(cv + 100, cv + 100),
      colour: Color(0xffFAD7A0),
    );
    // Set text for start node
    startNode.data.text = "start";

    FlowNode decisionNode = FlowNode(
      id: "node2",
      type: NodeType.parallelogram,
      position: Offset(cv + 300, cv + 150),
      colour: Color(0xffFAD7A0),
    );
    // Set text for decision node
    decisionNode.data.text = "decision node";

    FlowNode pageNode = FlowNode(
      id: "node3",
      type: NodeType.diamond,
      position: Offset(cv + 500, cv + 150),
      colour: Color(0xffFAD7A0),
    );
    // Set text for page node
    pageNode.data.text = "some page";

    FlowNode dbNode = FlowNode(
      id: "node4",
      type: NodeType.database,
      position: Offset(cv + 700, cv + 100),
      colour: Color(0xffFAD7A0),
    );
    // Set text for database node
    dbNode.data.text = "database details";

    FlowNode endNode = FlowNode(
      id: "node5",
      type: NodeType.rectangular,
      position: Offset(cv + 900, cv + 150),
      colour: Color(0xffFAD7A0),
    );
    // Set text for end node
    endNode.data.text = "end";

    // Add nodes to flow manager
    flowManager.addNode(startNode);
    flowManager.addNode(decisionNode);
    flowManager.addNode(pageNode);
    flowManager.addNode(dbNode);
    flowManager.addNode(endNode);

    // Create connections between nodes
    flowManager.connectNodes(
      sourceNodeId: "node1",
      targetNodeId: "node2",
      sourcePoint: ConnectionPoint.bottom,
      targetPoint: ConnectionPoint.top,
    );

    flowManager.connectNodes(
      sourceNodeId: "node2",
      targetNodeId: "node3",
      sourcePoint: ConnectionPoint.bottom,
      targetPoint: ConnectionPoint.top,
    );

    flowManager.connectNodes(
      sourceNodeId: "node3",
      targetNodeId: "node4",
      sourcePoint: ConnectionPoint.bottom,
      targetPoint: ConnectionPoint.top,
    );

    flowManager.connectNodes(
      sourceNodeId: "node4",
      targetNodeId: "node5",
      sourcePoint: ConnectionPoint.bottom,
      targetPoint: ConnectionPoint.top,
    );

    return flowManager;
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
        final AuthResponse authResponse = await supabase.auth.signUp(
            email: email,
            password: password,
            emailRedirectTo: null, // Disable email verification redirect
            data: {'userName': userName} // Store username in metadata
            );

        final user = authResponse.user;
        setUserData(authResponse);

        if (user == null) throw Exception("User signup failed.");

        // Create template workspace for the new user
        FlowManager templateWorkspace = createTemplateWorkspace();

        // Export the flow to JSON
        Map<String, dynamic> flowData = templateWorkspace.exportFlow();

        // Create flowList with the template workspace
        Map<String, dynamic> flowListMap = {
          templateWorkspace.flowId: {
            ...flowData,
            'createdAt': DateTime.now().toIso8601String(),
          }
        };

        // Insert user data with the template workspace
        await supabase.from('User').insert({
          'id': user.id,
          'userName': userName,
          'email': email,
          'flowList': flowListMap
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
        fetchAndSetUserProfilePicture();

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

  // Update user name in both Auth and User table
  Future<String> updateUserName({required String userName}) async {
    String res = 'Some error occurred';

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Input validation
      if (userName.trim().isEmpty) {
        throw Exception('Username cannot be empty');
      }

      // Update username in Auth metadata
      await supabase.auth
          .updateUser(UserAttributes(data: {'userName': userName}));

      // Also update username in User table
      await supabase
          .from('User')
          .update({'userName': userName}).eq('id', user.id);

      res = 'Username updated successfully';
      notifyListeners(); // Notify listeners of the change
      return res;
    } catch (e) {
      res = e.toString();
      throw Exception(res);
    }
  }

  // Update user email (would typically require email verification)
  Future<String> updateUserEmail({required String email}) async {
    String res = 'Some error occurred';

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Input validation
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      // Basic email validation regex
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        throw Exception('Please enter a valid email address');
      }

      // Update email in Auth
      // Note: This would typically send a confirmation email
      await supabase.auth.updateUser(UserAttributes(email: email));

      // Also update email in User table
      await supabase.from('User').update({'email': email}).eq('id', user.id);

      res = 'Email update requested. Please check your inbox to confirm.';
      notifyListeners();
      return res;
    } catch (e) {
      res = e.toString();
      throw Exception(res);
    }
  }

  // Update user password
  Future<String> updateUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    String res = 'Some error occurred';

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Input validation
      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Verify current password by attempting to sign in
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Update the password
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      res = 'Password updated successfully';
      return res;
    } catch (AuthException) {
      res = 'Current password is incorrect';
      throw Exception(res);
    } catch (e) {
      res = e.toString();
      throw Exception(res);
    }
  }

  // Add these constants at the top of your file
  final String _profileBucketName = 'profile';
  final String _defaultPfpPath = 'assets/Frame 271.png';

// Add these methods to your SupabaseService class

  /// Uploads user profile picture to Supabase storage
  Future<String> uploadUserProfilePicture(XFile imageFile) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get file bytes and extension
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeTypeFromExtension(extension);

      // Create storage path: userId/pfp.extension
      final storagePath = '${user.id}/pfp.$extension';

      // First try to remove existing pfp if any
      try {
        await supabase.storage
            .from(_profileBucketName)
            .remove(['${user.id}/pfp']);
      } catch (e) {
        print('No existing profile picture to remove');
      }

      // Upload to Supabase storage
      final uploadResponse =
          await supabase.storage.from(_profileBucketName).upload(
                storagePath,
                File(imageFile.path),
                fileOptions: FileOptions(contentType: mimeType, upsert: true),
              );

      // Get public URL
      final String publicUrl =
          supabase.storage.from(_profileBucketName).getPublicUrl(storagePath);

      // Update user data with the new pfp URL
      await supabase
          .from('User')
          .update({'profile_picture_url': publicUrl}).eq('id', user.id);

      // Update local state
      setUserPfp(imageFile);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }

  /// Fetches and sets user profile picture on login
  Future<void> fetchAndSetUserProfilePicture() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Get user data including profile picture URL
      final userData = await supabase
          .from('User')
          .select('profile_picture_url')
          .eq('id', user.id)
          .single();

      final String? pfpUrl = userData['profile_picture_url'];

      if (pfpUrl != null && pfpUrl.isNotEmpty) {
        // Extract file extension from URL
        final uri = Uri.parse(pfpUrl);
        final pathSegments = uri.pathSegments;
        final fileName = pathSegments.last;
        final fileExtension = fileName.split('.').last.toLowerCase();

        // List of supported extensions
        const supportedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (supportedExtensions.contains(fileExtension)) {
          try {
            // Download the image with proper extension
            final response = await supabase.storage
                .from(_profileBucketName)
                .download('${user.id}/pfp.$fileExtension');

            // Create temporary file with proper extension
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/pfp_${user.id}.$fileExtension');
            await file.writeAsBytes(response);

            // Set as XFile
            setUserPfp(XFile(file.path));
            return;
          } catch (e) {
            print('Error downloading profile picture: $e');
          }
        }
      }

      // Fallback to default if any step fails
      setUserPfp(XFile(_defaultPfpPath));
    } catch (e) {
      print('Error fetching profile picture: $e');
      setUserPfp(XFile(_defaultPfpPath));
    }
  }

  /// Helper function to get MIME type from file extension
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
}
