class UserModel {
  final String userId;
  final String fullName;
  final String location;
  final String phoneNumber;
  final String email;
  final String photoUrl;

  const UserModel({
    required this.userId,
    required this.fullName,
    required this.location,
    required this.phoneNumber,
    required this.email,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'fullName': fullName,
      'location': location,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      location: json['location'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }
}
