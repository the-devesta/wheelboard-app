class AppliedUserProfile {
  final String userId;
  final String profileName;
  final String email;
  final String phone;
  final String address;
  final String profileImage;
  final String profileType;

  AppliedUserProfile({
    required this.userId,
    required this.profileName,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.profileType,
  });

  factory AppliedUserProfile.fromJson(Map<String, dynamic> json) {
    return AppliedUserProfile(
      userId: json['userId']?.toString() ?? '',
      profileName: json['profileName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ?? '',
      profileType: json['profileType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileName': profileName,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'profileType': profileType,
    };
  }
}
