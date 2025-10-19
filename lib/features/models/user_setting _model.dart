

// class UserSettingsModel {
//   String userId;
//   Map<String, List<int>> shortcuts; // action -> list of key IDs
//   DateTime? lastUpdated;

//   UserSettingsModel({
//     required this.userId,
//     required this.shortcuts,
//     this.lastUpdated,
//   });

//   UserSettingsModel copyWith({
//     String? userId,
//     Map<String, List<int>>? shortcuts,
//     DateTime? lastUpdated,
//   }) {
//     return UserSettingsModel(
//       userId: userId ?? this.userId,
//       shortcuts: shortcuts ?? Map.from(this.shortcuts),
//       lastUpdated: lastUpdated ?? this.lastUpdated,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> jsonData = {};
//     jsonData['shortcuts'] = shortcuts;

//     return {
//       'id': userId,
//       'owner': userId,
//       'data': jsonData,
//       'last_updated': lastUpdated?.toIso8601String(),
//     };
//   }

//   factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
//     Map<String, List<int>> parsedShortcuts = {};

//     if (json['data'] != null && json['data']['shortcuts'] != null) {
//       try {
//         final shortcutsData = json['data']['shortcuts'] as Map<String, dynamic>;
//         parsedShortcuts = shortcutsData.map((key, value) {
//           return MapEntry(key, List<int>.from(value));
//         });
//       } catch (e) {
//         print('Error parsing shortcuts: $e');
//       }
//     }

//     return UserSettingsModel(
//       userId: json['id'] as String? ?? json['owner'] as String,
//       shortcuts: parsedShortcuts,
//       lastUpdated: json['last_updated'] != null
//           ? DateTime.parse(json['last_updated'] as String)
//           : null,
//     );
//   }
// }