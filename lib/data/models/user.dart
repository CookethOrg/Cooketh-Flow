import 'package:cookethflow/data/models/flow_manager.dart';

class UserModel {
  String username;
  String email;
  String password;
  Map<String, FlowManager> flowList;

  UserModel(
      {this.username = 'Cooketh Sapien',
      this.email = 'Cooketh@sapien.com',
      this.password = 'xyz'})
      : flowList = {};

  void createFlow(FlowManager flow) {
    flowList[flow.flowId] = flow;
  }

  Map<String, dynamic> exportUser() => {
        'username': username,
        'email': email,
        'flowList': flowList.map((flowId, flowManager) => MapEntry(
              flowId,
              {
                'flowId': flowManager.flowId,
                'flowName': flowManager.flowName,
                'nodes': flowManager.nodes.map((nodeId, node) => MapEntry(
                      nodeId,
                      node.toJson(),
                    )),
                'connections': flowManager.connections
                    .map((connection) => connection.toJson())
                    .toList(),
              },
            )),
      };

  // Optional: Add a method to import from JSON if needed
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = UserModel(
      username: json['username'] ?? 'Cooketh Sapien',
      email: json['email'] ?? 'Cooketh@sapien.com',
      password: json['password'] ?? 'xyz',
    );

    final flowListJson = json['flowList'] as Map<String, dynamic>?;
    if (flowListJson != null) {
      flowListJson.forEach((flowId, flowData) {
        final flowManager = FlowManager(flowId: flowId);
        // You would need to implement the node and connection creation logic here
        // based on your FlowNode and Connection classes
        user.flowList[flowId] = flowManager;
      });
    }

    return user;
  }
}
