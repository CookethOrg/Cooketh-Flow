class UserModel {
  String uid;
  String userName;
  String fullName;
  String email;
  dynamic pfp;

  UserModel({
    required this.uid,
    required this.userName,
    required this.fullName,
    required this.email,
    this.pfp,
  });

  // Import from json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = UserModel(
      uid: json["id"],
      userName: json["raw_user_meta_data"]["userName"],
      fullName:
          json["raw_user_meta_data"]["name"] ??
          json["raw_user_meta_data"]["userName"],
      email: json["email"],
    );
    return user;
  }

  // Export user data
  Map<String, dynamic> exportUser() => {
    'id': uid,
    'userName': userName,
    'full_name': fullName,
    'email': email,
  };

  UserModel copyWith() {
    UserModel newUser = UserModel(
      uid: uid,
      userName: userName,
      fullName: fullName,
      email: email,
    );
    return newUser;
  }
}
