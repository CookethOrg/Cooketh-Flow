import 'package:cookethflow/models/flow_manager.dart';

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
}
