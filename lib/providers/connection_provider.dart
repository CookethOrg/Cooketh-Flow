import 'package:cookethflow/core/utils/state_handler.dart';

class ConnectionProvider extends StateHandler {
  ConnectionProvider() : super();
  List<Map<Map<int,int>, Map<int,int>>> connections = [];

}
