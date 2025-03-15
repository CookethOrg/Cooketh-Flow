import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends StateHandler {
  late final SupabaseClient supabase;
  SupabaseService(this.supabase) : super();
  late AuthResponse _userData;
  bool _userDataSet = false;

  AuthResponse get userData => _userData;
  bool get userDataSet => _userDataSet;

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

  // Creates a template workspace with predefined nodes
  FlowManager createTemplateWorkspace() {
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
      position: Offset(100, 100),
    );
    // Set text for start node
    startNode.data.text = "start";

    FlowNode decisionNode = FlowNode(
      id: "node2",
      type: NodeType.parallelogram,
      position: Offset(300, 150),
    );
    // Set text for decision node
    decisionNode.data.text = "decision node";

    FlowNode pageNode = FlowNode(
      id: "node3",
      type: NodeType.diamond,
      position: Offset(500, 150),
    );
    // Set text for page node
    pageNode.data.text = "some page";

    FlowNode dbNode = FlowNode(
      id: "node4",
      type: NodeType.database,
      position: Offset(700, 100),
    );
    // Set text for database node
    dbNode.data.text = "database details";

    FlowNode endNode = FlowNode(
      id: "node5",
      type: NodeType.rectangular,
      position: Offset(900, 150),
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

  Future<String> updateUserName({required String userName}) async {
    String res = 'some error occured';
    try {
      UserResponse user = await supabase.auth
          .updateUser(UserAttributes(data: {'userName': userName}));

      res = 'User Name Updated succesfully';
      return res;
    } catch (e) {
      return e.toString();
    }
  }
}
