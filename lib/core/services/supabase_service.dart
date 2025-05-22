import 'dart:io';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/utils/ui_helper.dart';
import 'package:cookethflow/data/models/flow_manager.dart';
import 'package:cookethflow/data/models/flow_node.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends StateHandler {
  late final SupabaseClient supabase;
  SupabaseService(this.supabase) {
    _initializeUserData();
  }

  late AuthResponse _userData;
  bool _userDataSet = false;
  XFile? _userPfp;
  String? _userName;
  String? _email;
  bool _isDark = false;

  bool get isDark => _isDark;
  AuthResponse get userData => _userData;
  bool get userDataSet => _userDataSet;
  XFile? get userPfp => _userPfp;
  String? get userName => _userName;
  String? get email => _email;
  String get defaultPfpPath => _defaultPfpPath;

  void setTheme(bool val) {
    if (_isDark != val) {
      _isDark = val;
      notifyListeners();
    }
  }

  void setUserData(AuthResponse user) {
    _userData = user;
    _userDataSet = true;
    notifyListeners();
  }

  void setUserPfp(XFile? val) {
    _userPfp = val;
    print('Updated userPfp: ${val?.path}');
    notifyListeners();
  }

  void setUserName(String? name) {
    _userName = name;
    notifyListeners();
  }

  void setEmail(String? email) {
    _email = email;
    notifyListeners();
  }

  String getTruncatedText(String text) {
    return text.length > 12 ? '${text.substring(0, 12)}...' : text;
  }

  Future<void> _initializeUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await fetchCurrentUserDetails();
      await fetchAndSetUserProfilePicture();
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUserName() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('User')
          .select('userName')
          .eq('id', user.id)
          .single();
      setUserName(response['userName']);
      return response;
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUserDetails() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response =
          await supabase.from('User').select().eq('id', user.id).single();
      setUserName(response['userName']);
      setEmail(response['email']);
      return response;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  FlowManager createTemplateWorkspace() {
    double cv = (canvasDimension / 2) - 100;
    String flowId = DateTime.now().millisecondsSinceEpoch.toString();

    FlowManager flowManager = FlowManager(
      flowId: flowId,
      flowName: "Get Started with Cooketh Flow",
    );

    FlowNode startNode = FlowNode(
      id: "node1",
      type: NodeType.rectangular,
      position: Offset(cv + 100, cv + 100),
      colour: const Color(0xffFAD7A0),
    );
    startNode.data.text = "start";

    FlowNode decisionNode = FlowNode(
      id: "node2",
      type: NodeType.parallelogram,
      position: Offset(cv + 300, cv + 150),
      colour: const Color(0xffFAD7A0),
    );
    decisionNode.data.text = "decision node";

    FlowNode pageNode = FlowNode(
      id: "node3",
      type: NodeType.diamond,
      position: Offset(cv + 500, cv + 150),
      colour: const Color(0xffFAD7A0),
    );
    pageNode.data.text = "some page";

    FlowNode dbNode = FlowNode(
      id: "node4",
      type: NodeType.database,
      position: Offset(cv + 700, cv + 100),
      colour: const Color(0xffFAD7A0),
    );
    dbNode.data.text = "database details";

    FlowNode endNode = FlowNode(
      id: "node5",
      type: NodeType.rectangular,
      position: Offset(cv + 900, cv + 150),
      colour: const Color(0xffFAD7A0),
    );
    endNode.data.text = "end";

    flowManager.addNode(startNode);
    flowManager.addNode(decisionNode);
    flowManager.addNode(pageNode);
    flowManager.addNode(dbNode);
    flowManager.addNode(endNode);

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
        final AuthResponse authResponse = await supabase.auth.signUp(
            email: email,
            password: password,
            emailRedirectTo: null,
            data: {'userName': userName});
        final user = authResponse.user;
        setUserData(authResponse);
        if (user == null) throw Exception("User signup failed.");

        FlowManager templateWorkspace = createTemplateWorkspace();
        Map<String, dynamic> flowData = templateWorkspace.exportFlow();
        Map<String, dynamic> flowListMap = {
          templateWorkspace.flowId: {
            ...flowData,
            'createdAt': DateTime.now().toIso8601String(),
          }
        };

        await supabase.from('User').insert({
          'id': user.id,
          'userName': userName,
          'email': email,
          'flowList': flowListMap
        });

        setUserName(userName);
        setEmail(email);
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
        final AuthResponse authResponse =
            await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = authResponse.user;
        if (user == null) throw Exception('Login failed: User not found.');

        setUserData(authResponse);
        await fetchCurrentUserDetails();
        await fetchAndSetUserProfilePicture();

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
      _userName = null;
      _email = null;
      _userPfp = null; // Set to null to use asset in UI
      _userDataSet = false;
      notifyListeners();
    } catch (e) {
      throw Exception('Error logging out: ${e.toString()}');
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      await supabase.from('User').delete().eq('id', user.id);
      await supabase.auth.signOut();
      _userName = null;
      _email = null;
      _userPfp = null; // Set to null to use asset in UI
      _userDataSet = false;
      notifyListeners();
    } catch (e) {
      print("Error deleting account: $e");
      throw Exception('Error deleting account: ${e.toString()}');
    }
  }

  Future<bool> checkUserSession() async {
    final user = supabase.auth.currentUser;
    if (user != null && !_userDataSet) {
      await fetchCurrentUserDetails();
      await fetchAndSetUserProfilePicture();
    }
    return user != null;
  }

  Future<String> updateUserName({required String userName}) async {
    String res = 'Some error occurred';
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');
      if (userName.trim().isEmpty) throw Exception('Username cannot be empty');

      await supabase.auth
          .updateUser(UserAttributes(data: {'userName': userName}));
      await supabase
          .from('User')
          .update({'userName': userName}).eq('id', user.id);
      setUserName(userName);
      res = 'Username updated successfully';
      return res;
    } catch (e) {
      res = e.toString();
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
      await supabase.from('User').update({'email': email}).eq('id', user.id);
      setEmail(email);
      res = 'Email update requested. Please check your inbox to confirm.';
      return res;
    } catch (e) {
      res = e.toString();
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

      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      res = 'Password updated successfully';
      return res;
    } catch (AuthException) {
      res = 'Current password is incorrect';
      throw Exception(res);
    }
  }

  final String _profileBucketName = 'profile';
  final String _defaultPfpPath = 'assets/Frame 271.png';

  Future<String> uploadUserProfilePicture(XFile imageFile) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final extension = imageFile.name.split('.').last.toLowerCase();
      final mimeType = _getMimeTypeFromExtension(extension);
      final storagePath = '${user.id}/pfp.$extension';

      try {
        await supabase.storage
            .from(_profileBucketName)
            .remove(['${user.id}/pfp']);
      } catch (e) {
        print('No existing profile picture to remove: $e');
      }

      final bytes = await imageFile.readAsBytes();

      await supabase.storage.from(_profileBucketName).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      final String publicUrl =
          supabase.storage.from(_profileBucketName).getPublicUrl(storagePath);

      await supabase
          .from('User')
          .update({'profile_picture_url': publicUrl}).eq('id', user.id);

      setUserPfp(imageFile); // Use the uploaded file directly
      return publicUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }

  Future<void> fetchAndSetUserProfilePicture() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final userData = await supabase
          .from('User')
          .select('profile_picture_url')
          .eq('id', user.id)
          .single();
      final String? pfpUrl = userData['profile_picture_url'];

      if (pfpUrl != null && pfpUrl.isNotEmpty) {
        final uri = Uri.parse(pfpUrl);
        final pathSegments = uri.pathSegments;
        final fileName = pathSegments.last;
        final fileExtension = fileName.split('.').last.toLowerCase();
        const supportedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (supportedExtensions.contains(fileExtension)) {
          if (kIsWeb) {
            // Web: Use XFile.fromData for in-memory bytes
            final bytes = await http.get(uri).then((res) => res.bodyBytes);
            setUserPfp(XFile.fromData(
              bytes,
              name: 'pfp.$fileExtension',
              mimeType: _getMimeTypeFromExtension(fileExtension),
            ));
          } else {
            // Desktop: Save to temporary file
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/pfp.$fileExtension');
            final bytes = await http.get(uri).then((res) => res.bodyBytes);
            await tempFile.writeAsBytes(bytes);
            setUserPfp(XFile(tempFile.path));
          }
          notifyListeners();
          return;
        }
      }
      // Fallback to null (UI should use Image.asset for default)
      setUserPfp(null);
      notifyListeners();
    } catch (e) {
      print('Error fetching profile picture: $e');
      setUserPfp(null);
      notifyListeners();
    }
  }

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
