import 'dart:ui';
import 'package:flutter/material.dart';

class WorkspaceModel {
  String id;
  String owner;
  String name;
  List<String> editorIdList;
  List<String> viewerIdList;
  DateTime? lastEdited;
  Color? backgroundColor;
  bool isStarred;

  WorkspaceModel({
    required this.id,
    required this.owner,
    required this.name,
    required this.editorIdList,
    required this.viewerIdList,
    required this.lastEdited,
    this.backgroundColor,
    this.isStarred = false,
  });

  WorkspaceModel copyWith({
    String? id,
    String? owner,
    String? name,
    List<String>? editorIdList,
    List<String>? viewerIdList,
    DateTime? lastEdited,
    Color? backgroundColor,
    bool? isStarred, // Add to copyWith
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      editorIdList: editorIdList ?? List.from(this.editorIdList),
      viewerIdList: viewerIdList ?? List.from(this.viewerIdList),
      lastEdited: lastEdited ?? this.lastEdited,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isStarred: isStarred ?? this.isStarred, // Add to copyWith
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (backgroundColor != null) {
      jsonData['backgroundColor'] = '#${backgroundColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    jsonData['isStarred'] = isStarred;

    return {
      'id': id,
      'owner': owner,
      'name': name,
      'editorId': editorIdList,
      'viewerId': viewerIdList,
      'last edited': lastEdited?.toIso8601String(),
      'data': jsonData,
    };
  }

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    Color? bgColor;
    bool isStarredFlag = false;

    if (json['data'] != null) {
      // Parse background color
      if (json['data']['backgroundColor'] != null) {
        try {
          final colorString = json['data']['backgroundColor'] as String;
          final hexCode = colorString.replaceAll('#', '');
          final fullHexCode = hexCode.length == 6 ? 'FF$hexCode' : hexCode;
          bgColor = Color(int.parse(fullHexCode, radix: 16));
        } catch (e) {
          print('Error parsing background color: $e');
          bgColor = null;
        }
      }
      // Parse isStarred
      if (json['data']['isStarred'] is bool) {
        isStarredFlag = json['data']['isStarred'];
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
      backgroundColor: bgColor,
      isStarred: isStarredFlag, // Assign parsed value
    );
  }
}