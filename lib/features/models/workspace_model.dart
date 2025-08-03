import 'dart:ui';

class WorkspaceModel {
  String id;
  String owner;
  String name;
  List<String> editorIdList;
  List<String> viewerIdList;
  DateTime? lastEdited;
  // NEW: Property for background color
  Color? backgroundColor;

  WorkspaceModel({
    required this.id,
    required this.owner,
    required this.name,
    required this.editorIdList,
    required this.viewerIdList,
    required this.lastEdited,
    this.backgroundColor, // Add to constructor
  });

  WorkspaceModel copyWith({
    String? id,
    String? owner,
    String? name,
    List<String>? editorIdList,
    List<String>? viewerIdList,
    DateTime? lastEdited,
    Color? backgroundColor, // Add to copyWith
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      editorIdList: editorIdList ?? List.from(this.editorIdList),
      viewerIdList: viewerIdList ?? List.from(this.viewerIdList),
      lastEdited: lastEdited ?? this.lastEdited,
      backgroundColor: backgroundColor ?? this.backgroundColor, // Add to copyWith
    );
  }

  Map<String, dynamic> toJson() {
    // NEW: Prepare the 'data' jsonb field
    final Map<String, dynamic> jsonData = {};
    if (backgroundColor != null) {
      // Store color as an #AARRGGBB hex string
      jsonData['backgroundColor'] = '#${backgroundColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }

    return {
      'id': id,
      'owner': owner,
      'name': name,
      'editorId': editorIdList,
      'viewerId': viewerIdList,
      'last edited': lastEdited?.toIso8601String(),
      'data': jsonData, // Add data field to JSON
    };
  }

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    // NEW: Parse the background color from the 'data' field
    Color? bgColor;
    if (json['data'] != null && json['data']['backgroundColor'] != null) {
      try {
        final colorString = json['data']['backgroundColor'] as String;
        final hexCode = colorString.replaceAll('#', '');
        // Handle both RRGGBB and AARRGGBB formats
        final fullHexCode = hexCode.length == 6 ? 'FF$hexCode' : hexCode;
        bgColor = Color(int.parse(fullHexCode, radix: 16));
      } catch (e) {
        print('Error parsing background color: $e');
        bgColor = null; // Default to null on error
      }
    }

    return WorkspaceModel(
      id: json['id'] as String,
      owner: json['owner'] as String,
      name: json['name'] as String,
      editorIdList: List<String>.from(json['editorId'] ?? []),
      viewerIdList: List<String>.from(json['viewerId'] ?? []),
      lastEdited: json['last edited'] != null 
          ? DateTime.parse(json['last edited'] as String) 
          : null,
      backgroundColor: bgColor, // Assign parsed color
    );
  }
}