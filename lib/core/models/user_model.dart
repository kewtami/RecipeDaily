class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  // Convert from Firebase/Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
    );
  }

  // Convert to Firebase/Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}