// WorkspaceModel.dart (Ensuring correct key names for toJson and fromJson)
class WorkspaceModel {
  String id;
  String owner;
  String name;
  List<String> editorIdList;
  List<String> viewerIdList;
  DateTime? lastEdited;

  WorkspaceModel({
    required this.id,
    required this.owner,
    required this.name,
    required this.editorIdList,
    required this.viewerIdList,
    required this.lastEdited,
  });

  WorkspaceModel copyWith({
    String? id,
    String? owner,
    String? name,
    List<String>? editorIdList,
    List<String>? viewerIdList,
    DateTime? lastEdited,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      editorIdList: editorIdList ?? List.from(this.editorIdList),
      viewerIdList: viewerIdList ?? List.from(this.viewerIdList),
      lastEdited: lastEdited ?? this.lastEdited,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'name': name,
      // Ensure these keys match your Supabase table column names exactly
      'editorId': editorIdList,
      'viewerId': viewerIdList,
      'last edited': lastEdited?.toIso8601String(),
    };
  }

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      owner: json['owner'] as String,
      name: json['name'] as String,
      // Ensure these keys match your Supabase table column names exactly
      editorIdList: List<String>.from(json['editorId'] ?? []), // Handle potential null if not always present
      viewerIdList: List<String>.from(json['viewerId'] ?? []), // Handle potential null if not always present
      lastEdited: json['last edited'] != null 
          ? DateTime.parse(json['last edited'] as String) 
          : null, // Handle potential null for 'last edited'
    );
  }
}