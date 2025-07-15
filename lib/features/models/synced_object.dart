import 'package:cookethflow/features/models/canvas_object.dart';
import 'package:cookethflow/features/models/user_cursor.dart';

abstract class SyncedObject {
  final String id;
  factory SyncedObject.fromJson(Map<String, dynamic> json) {
    final objectType = json["object_type"];
    if (objectType == UserCursor.type) {
      return UserCursor.fromJson(json);
    } else {
      return CanvasObject.fromJson(json);
    }
  }

  SyncedObject({required this.id});

  Map<String, dynamic> toJson();
}
