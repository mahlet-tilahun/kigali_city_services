// Represents the user profile stored in Firestore under /users/{uid}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final bool notificationsEnabled; // local preference stored in Firestore

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.notificationsEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      notificationsEnabled: map['notificationsEnabled'] ?? false,
    );
  }

  UserModel copyWith({bool? notificationsEnabled}) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
